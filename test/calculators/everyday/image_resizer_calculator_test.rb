require "test_helper"

class Everyday::ImageResizerCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "returns valid configuration with basic inputs" do
    result = Everyday::ImageResizerCalculator.new(width: 800, height: 600).call
    assert result[:valid]
    assert_equal 800, result[:width]
    assert_equal 600, result[:height]
    assert_equal "png", result[:format]
    assert_equal 92, result[:quality]
    assert result[:maintain_aspect_ratio]
  end

  test "returns correct dimensions without aspect ratio" do
    result = Everyday::ImageResizerCalculator.new(
      width: 400, height: 300, maintain_aspect_ratio: false
    ).call
    assert result[:valid]
    assert_equal 400, result[:width]
    assert_equal 300, result[:height]
    assert_equal false, result[:maintain_aspect_ratio]
  end

  test "maintains aspect ratio from original dimensions (width-based)" do
    result = Everyday::ImageResizerCalculator.new(
      width: 400, height: 400, maintain_aspect_ratio: true,
      original_width: 1920, original_height: 1080
    ).call
    assert result[:valid]
    # 1920:1080 = 16:9, so 400px wide should be ~225px tall
    assert_equal 400, result[:width]
    assert_equal 225, result[:height]
  end

  test "maintains aspect ratio from original dimensions (height-based)" do
    result = Everyday::ImageResizerCalculator.new(
      width: 800, height: 300, maintain_aspect_ratio: true,
      original_width: 1920, original_height: 1080
    ).call
    assert result[:valid]
    # Should fit within 800x300 maintaining 16:9 ratio
    assert result[:width] <= 800
    assert result[:height] <= 300
  end

  test "accepts jpeg format" do
    result = Everyday::ImageResizerCalculator.new(
      width: 100, height: 100, format: "jpeg"
    ).call
    assert result[:valid]
    assert_equal "jpeg", result[:format]
  end

  test "accepts webp format" do
    result = Everyday::ImageResizerCalculator.new(
      width: 100, height: 100, format: "webp"
    ).call
    assert result[:valid]
    assert_equal "webp", result[:format]
  end

  test "clamps quality between 1 and 100" do
    result = Everyday::ImageResizerCalculator.new(
      width: 100, height: 100, quality: 150
    ).call
    assert result[:valid]
    assert_equal 100, result[:quality]

    result2 = Everyday::ImageResizerCalculator.new(
      width: 100, height: 100, quality: 0
    ).call
    assert result2[:valid]
    assert_equal 1, result2[:quality]
  end

  test "calculates scale factors when original dimensions provided" do
    result = Everyday::ImageResizerCalculator.new(
      width: 960, height: 540, maintain_aspect_ratio: false,
      original_width: 1920, original_height: 1080
    ).call
    assert result[:valid]
    assert_equal 0.5, result[:scale_x]
    assert_equal 0.5, result[:scale_y]
  end

  test "scale factors are nil when no original dimensions" do
    result = Everyday::ImageResizerCalculator.new(width: 400, height: 300).call
    assert result[:valid]
    assert_nil result[:scale_x]
    assert_nil result[:scale_y]
  end

  # --- Validation errors ---

  test "error when width is 0" do
    result = Everyday::ImageResizerCalculator.new(width: 0, height: 100).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Width") }
  end

  test "error when height is negative" do
    result = Everyday::ImageResizerCalculator.new(width: 100, height: -5).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Height") }
  end

  test "error when width exceeds maximum" do
    result = Everyday::ImageResizerCalculator.new(width: 20000, height: 100).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Width") }
  end

  test "error when format is invalid" do
    result = Everyday::ImageResizerCalculator.new(
      width: 100, height: 100, format: "bmp"
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Format") }
  end

  test "string coercion works for dimensions" do
    result = Everyday::ImageResizerCalculator.new(width: "800", height: "600").call
    assert result[:valid]
    assert_equal 800, result[:width]
    assert_equal 600, result[:height]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::ImageResizerCalculator.new(width: 100, height: 100)
    assert_equal [], calc.errors
  end
end
