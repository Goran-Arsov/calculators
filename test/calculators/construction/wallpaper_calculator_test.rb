require "test_helper"

class Construction::WallpaperCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "14x12x8 room → rolls > 0" do
    result = Construction::WallpaperCalculator.new(length: 14, width: 12, height: 8).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:rolls_needed] > 0
    assert result[:wall_area] > 0
    assert result[:total_strips] > 0
  end

  test "wall area calculated correctly" do
    result = Construction::WallpaperCalculator.new(length: 14, width: 12, height: 8, doors: 0, windows: 0).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # Perimeter = 2*(14+12) = 52, wall area = 52*8 = 416
    assert_equal 416.0, result[:wall_area]
    assert_equal 416.0, result[:coverable_area]
  end

  test "doors and windows reduce coverable area" do
    no_openings = Construction::WallpaperCalculator.new(length: 14, width: 12, height: 8, doors: 0, windows: 0).call
    with_openings = Construction::WallpaperCalculator.new(length: 14, width: 12, height: 8, doors: 2, windows: 3).call
    assert with_openings[:coverable_area] < no_openings[:coverable_area]
  end

  test "pattern repeat increases rolls needed" do
    no_repeat = Construction::WallpaperCalculator.new(length: 14, width: 12, height: 8, pattern_repeat_in: 0).call
    with_repeat = Construction::WallpaperCalculator.new(length: 14, width: 12, height: 8, pattern_repeat_in: 24).call
    assert with_repeat[:rolls_needed] >= no_repeat[:rolls_needed]
  end

  test "strips per roll decreases with large pattern repeat" do
    no_repeat = Construction::WallpaperCalculator.new(length: 14, width: 12, height: 8, pattern_repeat_in: 0).call
    large_repeat = Construction::WallpaperCalculator.new(length: 14, width: 12, height: 8, pattern_repeat_in: 48).call
    assert large_repeat[:strips_per_roll] <= no_repeat[:strips_per_roll]
  end

  test "perimeter returned correctly" do
    result = Construction::WallpaperCalculator.new(length: 14, width: 12, height: 8).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 52.0, result[:perimeter]
  end

  test "string inputs are coerced" do
    result = Construction::WallpaperCalculator.new(length: "14", width: "12", height: "8", doors: "1", windows: "2").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:rolls_needed] > 0
  end

  # --- Validation errors ---

  test "error when length is zero" do
    result = Construction::WallpaperCalculator.new(length: 0, width: 12, height: 8).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "error when height is negative" do
    result = Construction::WallpaperCalculator.new(length: 14, width: 12, height: -1).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Height must be greater than zero"
  end

  test "error when pattern repeat is negative" do
    result = Construction::WallpaperCalculator.new(length: 14, width: 12, height: 8, pattern_repeat_in: -5).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Pattern repeat cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::WallpaperCalculator.new(length: 14, width: 12, height: 8)
    assert_equal [], calc.errors
  end
end
