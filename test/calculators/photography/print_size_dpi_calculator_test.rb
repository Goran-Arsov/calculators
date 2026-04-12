require "test_helper"

class Photography::PrintSizeDpiCalculatorTest < ActiveSupport::TestCase
  # --- Pixels to print ---

  test "6000x4000 at 300dpi prints at 20x13.33 inches" do
    result = Photography::PrintSizeDpiCalculator.new(
      mode: "pixels_to_print", pixel_width: 6000, pixel_height: 4000, dpi: 300
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 20.0, result[:print_width_inches], 0.01
    assert_in_delta 13.33, result[:print_height_inches], 0.01
  end

  test "pixels to print returns megapixels" do
    result = Photography::PrintSizeDpiCalculator.new(
      mode: "pixels_to_print", pixel_width: 6000, pixel_height: 4000, dpi: 300
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 24.0, result[:total_megapixels], 0.1
  end

  test "pixels to print returns cm values" do
    result = Photography::PrintSizeDpiCalculator.new(
      mode: "pixels_to_print", pixel_width: 3000, pixel_height: 2000, dpi: 300
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 25.4, result[:print_width_cm], 0.1  # 10 inches * 2.54
  end

  test "quality label excellent at 300 dpi" do
    result = Photography::PrintSizeDpiCalculator.new(
      mode: "pixels_to_print", pixel_width: 3000, pixel_height: 2000, dpi: 300
    ).call
    assert_equal "Excellent", result[:quality]
  end

  test "quality label low at 72 dpi" do
    result = Photography::PrintSizeDpiCalculator.new(
      mode: "pixels_to_print", pixel_width: 3000, pixel_height: 2000, dpi: 72
    ).call
    assert result[:quality].include?("Low")
  end

  # --- Print to pixels ---

  test "8x10 inches at 300dpi needs 2400x3000 pixels" do
    result = Photography::PrintSizeDpiCalculator.new(
      mode: "print_to_pixels", print_width: 8, print_height: 10, dpi: 300, unit: "inches"
    ).call
    assert_equal true, result[:valid]
    assert_equal 2400, result[:required_pixel_width]
    assert_equal 3000, result[:required_pixel_height]
  end

  test "print to pixels with cm unit" do
    result = Photography::PrintSizeDpiCalculator.new(
      mode: "print_to_pixels", print_width: 20.32, print_height: 25.4, dpi: 300, unit: "cm"
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 2400, result[:required_pixel_width], 5
    assert_in_delta 3000, result[:required_pixel_height], 5
  end

  # --- Find DPI ---

  test "find DPI from pixels and print size" do
    result = Photography::PrintSizeDpiCalculator.new(
      mode: "find_dpi", pixel_width: 3000, pixel_height: 2000,
      print_width: 10, print_height: 8, unit: "inches"
    ).call
    assert_equal true, result[:valid]
    assert_equal 250, result[:effective_dpi]  # min(300, 250) = 250
  end

  # --- Validation errors ---

  test "error when pixel width is zero for pixels_to_print" do
    result = Photography::PrintSizeDpiCalculator.new(
      mode: "pixels_to_print", pixel_width: 0, pixel_height: 4000, dpi: 300
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Pixel width") }
  end

  test "error when DPI is zero" do
    result = Photography::PrintSizeDpiCalculator.new(
      mode: "pixels_to_print", pixel_width: 6000, pixel_height: 4000, dpi: 0
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("DPI") }
  end

  test "errors accessor returns empty array before call" do
    calc = Photography::PrintSizeDpiCalculator.new(
      mode: "pixels_to_print", pixel_width: 6000, pixel_height: 4000, dpi: 300
    )
    assert_equal [], calc.errors
  end
end
