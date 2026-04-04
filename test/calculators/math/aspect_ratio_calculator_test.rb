require "test_helper"

class Math::AspectRatioCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "16:9 aspect ratio from 1920x1080" do
    result = Math::AspectRatioCalculator.new(width: 1920, height: 1080).call
    assert result[:valid]
    assert_equal 16, result[:ratio_width]
    assert_equal 9, result[:ratio_height]
    assert_equal 1920.0, result[:width]
    assert_equal 1080.0, result[:height]
    assert_in_delta 1.7778, result[:decimal_ratio], 0.001
  end

  test "4:3 aspect ratio from 1024x768" do
    result = Math::AspectRatioCalculator.new(width: 1024, height: 768).call
    assert result[:valid]
    assert_equal 4, result[:ratio_width]
    assert_equal 3, result[:ratio_height]
  end

  test "1:1 aspect ratio (square)" do
    result = Math::AspectRatioCalculator.new(width: 500, height: 500).call
    assert result[:valid]
    assert_equal 1, result[:ratio_width]
    assert_equal 1, result[:ratio_height]
    assert_equal 1.0, result[:decimal_ratio]
  end

  test "21:9 ultrawide from 2560x1080" do
    result = Math::AspectRatioCalculator.new(width: 2560, height: 1080).call
    assert result[:valid]
    assert_equal 64, result[:ratio_width]
    assert_equal 27, result[:ratio_height]
  end

  test "portrait orientation" do
    result = Math::AspectRatioCalculator.new(width: 1080, height: 1920).call
    assert result[:valid]
    assert_equal 9, result[:ratio_width]
    assert_equal 16, result[:ratio_height]
    assert result[:decimal_ratio] < 1.0
  end

  # --- Validation errors ---

  test "error when width is missing" do
    result = Math::AspectRatioCalculator.new(height: 1080).call
    refute result[:valid]
    assert_includes result[:errors], "Width is required"
  end

  test "error when height is missing" do
    result = Math::AspectRatioCalculator.new(width: 1920).call
    refute result[:valid]
    assert_includes result[:errors], "Height is required"
  end

  test "error when both are missing" do
    result = Math::AspectRatioCalculator.new.call
    refute result[:valid]
    assert_includes result[:errors], "Width is required"
    assert_includes result[:errors], "Height is required"
  end

  test "error when width is zero" do
    result = Math::AspectRatioCalculator.new(width: 0, height: 1080).call
    refute result[:valid]
    assert_includes result[:errors], "Width must be positive"
  end

  test "error when height is negative" do
    result = Math::AspectRatioCalculator.new(width: 1920, height: -1080).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  test "error when width is negative" do
    result = Math::AspectRatioCalculator.new(width: -1920, height: 1080).call
    refute result[:valid]
    assert_includes result[:errors], "Width must be positive"
  end

  # --- Edge cases ---

  test "prime number dimensions" do
    result = Math::AspectRatioCalculator.new(width: 7, height: 13).call
    assert result[:valid]
    assert_equal 7, result[:ratio_width]
    assert_equal 13, result[:ratio_height]
  end

  test "small dimensions" do
    result = Math::AspectRatioCalculator.new(width: 2, height: 1).call
    assert result[:valid]
    assert_equal 2, result[:ratio_width]
    assert_equal 1, result[:ratio_height]
    assert_equal 2.0, result[:decimal_ratio]
  end

  test "large dimensions" do
    result = Math::AspectRatioCalculator.new(width: 7680, height: 4320).call
    assert result[:valid]
    assert_equal 16, result[:ratio_width]
    assert_equal 9, result[:ratio_height]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::AspectRatioCalculator.new(width: 1920, height: 1080)
    assert_equal [], calc.errors
  end
end
