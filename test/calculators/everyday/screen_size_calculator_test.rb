require "test_helper"

class Everyday::ScreenSizeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "27 inch 16:9 display dimensions" do
    result = Everyday::ScreenSizeCalculator.new(diagonal: 27, aspect_width: 16, aspect_height: 9).call
    assert_nil result[:errors]
    assert_in_delta 23.53, result[:width], 0.1
    assert_in_delta 13.24, result[:height], 0.1
    assert_equal "16:9", result[:aspect_ratio]
  end

  test "24 inch 16:9 with 1920x1080 resolution gives PPI" do
    result = Everyday::ScreenSizeCalculator.new(diagonal: 24, aspect_width: 16, aspect_height: 9, resolution_h: 1920, resolution_v: 1080).call
    assert_nil result[:errors]
    assert_in_delta 91.8, result[:ppi], 0.5
    assert_equal "1920 x 1080", result[:resolution]
    assert_equal 2_073_600, result[:total_pixels]
  end

  test "27 inch 16:9 with 2560x1440 resolution" do
    result = Everyday::ScreenSizeCalculator.new(diagonal: 27, aspect_width: 16, aspect_height: 9, resolution_h: 2560, resolution_v: 1440).call
    assert_nil result[:errors]
    assert_in_delta 108.8, result[:ppi], 0.5
  end

  test "4:3 aspect ratio" do
    result = Everyday::ScreenSizeCalculator.new(diagonal: 15, aspect_width: 4, aspect_height: 3).call
    assert_nil result[:errors]
    assert_in_delta 12.0, result[:width], 0.1
    assert_in_delta 9.0, result[:height], 0.1
  end

  test "area is width times height" do
    result = Everyday::ScreenSizeCalculator.new(diagonal: 27, aspect_width: 16, aspect_height: 9).call
    assert_nil result[:errors]
    assert_in_delta result[:width] * result[:height], result[:area], 0.1
  end

  test "no resolution returns no PPI" do
    result = Everyday::ScreenSizeCalculator.new(diagonal: 27, aspect_width: 16, aspect_height: 9).call
    assert_nil result[:errors]
    assert_nil result[:ppi]
    assert_nil result[:resolution]
  end

  test "ultrawide 21:9 aspect ratio" do
    result = Everyday::ScreenSizeCalculator.new(diagonal: 34, aspect_width: 21, aspect_height: 9).call
    assert_nil result[:errors]
    assert result[:width] > result[:height]
    assert_equal "21:9", result[:aspect_ratio]
  end

  # --- Validation errors ---

  test "error when diagonal is zero" do
    result = Everyday::ScreenSizeCalculator.new(diagonal: 0, aspect_width: 16, aspect_height: 9).call
    assert result[:errors].any?
    assert_includes result[:errors], "Diagonal must be greater than zero"
  end

  test "error when aspect width is zero" do
    result = Everyday::ScreenSizeCalculator.new(diagonal: 27, aspect_width: 0, aspect_height: 9).call
    assert result[:errors].any?
    assert_includes result[:errors], "Aspect width must be greater than zero"
  end

  test "error when aspect height is zero" do
    result = Everyday::ScreenSizeCalculator.new(diagonal: 27, aspect_width: 16, aspect_height: 0).call
    assert result[:errors].any?
    assert_includes result[:errors], "Aspect height must be greater than zero"
  end

  test "string coercion works" do
    result = Everyday::ScreenSizeCalculator.new(diagonal: "27", aspect_width: "16", aspect_height: "9").call
    assert_nil result[:errors]
    assert_in_delta 23.53, result[:width], 0.1
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::ScreenSizeCalculator.new(diagonal: 27, aspect_width: 16, aspect_height: 9)
    assert_equal [], calc.errors
  end
end
