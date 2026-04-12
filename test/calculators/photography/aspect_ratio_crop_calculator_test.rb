require "test_helper"

class Photography::AspectRatioCropCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "6000x4000 to 1:1 crops to 4000x4000" do
    result = Photography::AspectRatioCropCalculator.new(
      original_width: 6000, original_height: 4000,
      target_ratio_w: 1, target_ratio_h: 1
    ).call
    assert_equal true, result[:valid]
    assert_equal 4000, result[:crop_width]
    assert_equal 4000, result[:crop_height]
  end

  test "6000x4000 to 16:9 crops height" do
    result = Photography::AspectRatioCropCalculator.new(
      original_width: 6000, original_height: 4000,
      target_ratio_w: 16, target_ratio_h: 9
    ).call
    assert_equal true, result[:valid]
    assert_equal 6000, result[:crop_width]
    assert result[:crop_height] < 4000
    assert_in_delta 3375, result[:crop_height], 1  # 6000 / (16/9) = 3375
  end

  test "6000x4000 to 9:16 crops width" do
    result = Photography::AspectRatioCropCalculator.new(
      original_width: 6000, original_height: 4000,
      target_ratio_w: 9, target_ratio_h: 16
    ).call
    assert_equal true, result[:valid]
    assert result[:crop_width] < 6000
    assert_equal 4000, result[:crop_height]
    assert_in_delta 2250, result[:crop_width], 1  # 4000 * (9/16) = 2250
  end

  test "same aspect ratio keeps full image" do
    result = Photography::AspectRatioCropCalculator.new(
      original_width: 6000, original_height: 4000,
      target_ratio_w: 3, target_ratio_h: 2
    ).call
    assert_equal true, result[:valid]
    assert_equal 6000, result[:crop_width]
    assert_equal 4000, result[:crop_height]
    assert_in_delta 100.0, result[:percentage_kept], 0.1
  end

  test "offset is centered" do
    result = Photography::AspectRatioCropCalculator.new(
      original_width: 6000, original_height: 4000,
      target_ratio_w: 1, target_ratio_h: 1
    ).call
    assert_equal true, result[:valid]
    assert_equal 1000, result[:offset_x]  # (6000-4000)/2
    assert_equal 0, result[:offset_y]
  end

  test "percentage kept is between 0 and 100" do
    result = Photography::AspectRatioCropCalculator.new(
      original_width: 6000, original_height: 4000,
      target_ratio_w: 1, target_ratio_h: 1
    ).call
    assert_equal true, result[:valid]
    assert result[:percentage_kept] > 0
    assert result[:percentage_kept] <= 100
  end

  test "megapixels after crop is calculated" do
    result = Photography::AspectRatioCropCalculator.new(
      original_width: 6000, original_height: 4000,
      target_ratio_w: 1, target_ratio_h: 1
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 16.0, result[:megapixels_after], 0.1  # 4000*4000 = 16MP
  end

  # --- Validation errors ---

  test "error when original width is zero" do
    result = Photography::AspectRatioCropCalculator.new(
      original_width: 0, original_height: 4000,
      target_ratio_w: 1, target_ratio_h: 1
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Original width must be positive"
  end

  test "error when target ratio is zero" do
    result = Photography::AspectRatioCropCalculator.new(
      original_width: 6000, original_height: 4000,
      target_ratio_w: 0, target_ratio_h: 1
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Target ratio width must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Photography::AspectRatioCropCalculator.new(
      original_width: 6000, original_height: 4000,
      target_ratio_w: 16, target_ratio_h: 9
    )
    assert_equal [], calc.errors
  end
end
