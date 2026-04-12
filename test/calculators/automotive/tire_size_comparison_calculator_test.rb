require "test_helper"

class Automotive::TireSizeComparisonCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: same tires ---

  test "identical tires show zero difference" do
    result = Automotive::TireSizeComparisonCalculator.new(
      tire1_width: 225, tire1_aspect: 45, tire1_rim: 17,
      tire2_width: 225, tire2_aspect: 45, tire2_rim: 17
    ).call
    assert result[:valid]
    assert_in_delta 0.0, result[:diameter_difference_inches], 0.01
    assert_in_delta 0.0, result[:speedometer_difference_pct], 0.01
    assert_in_delta 60.0, result[:actual_speed_at_60], 0.1
  end

  # --- Happy path: 225/45R17 vs 235/40R18 ---

  test "plus-size comparison produces expected values" do
    result = Automotive::TireSizeComparisonCalculator.new(
      tire1_width: 225, tire1_aspect: 45, tire1_rim: 17,
      tire2_width: 235, tire2_aspect: 40, tire2_rim: 18
    ).call
    assert result[:valid]
    # 225/45R17: sidewall = 225*0.45 = 101.25mm = 3.986in, diam = 17 + 2*3.986 = 24.972
    assert_in_delta 24.97, result[:tire1][:overall_diameter_inches], 0.1
    # 235/40R18: sidewall = 235*0.40 = 94mm = 3.701in, diam = 18 + 2*3.701 = 25.402
    assert_in_delta 25.40, result[:tire2][:overall_diameter_inches], 0.1
    assert result[:diameter_difference_inches] > 0
  end

  # --- Speedometer reading ---

  test "larger tire increases actual speed" do
    result = Automotive::TireSizeComparisonCalculator.new(
      tire1_width: 205, tire1_aspect: 55, tire1_rim: 16,
      tire2_width: 225, tire2_aspect: 55, tire2_rim: 17
    ).call
    assert result[:valid]
    assert result[:actual_speed_at_60] > 60.0
    assert result[:speedometer_difference_pct] > 0
  end

  # --- Smaller tire ---

  test "smaller tire decreases actual speed" do
    result = Automotive::TireSizeComparisonCalculator.new(
      tire1_width: 235, tire1_aspect: 45, tire1_rim: 18,
      tire2_width: 205, tire2_aspect: 45, tire2_rim: 17
    ).call
    assert result[:valid]
    assert result[:actual_speed_at_60] < 60.0
    assert result[:speedometer_difference_pct] < 0
  end

  # --- Validation errors ---

  test "zero tire1 width returns error" do
    result = Automotive::TireSizeComparisonCalculator.new(
      tire1_width: 0, tire1_aspect: 45, tire1_rim: 17,
      tire2_width: 225, tire2_aspect: 45, tire2_rim: 17
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Tire 1 width must be positive"
  end

  test "zero tire2 rim returns error" do
    result = Automotive::TireSizeComparisonCalculator.new(
      tire1_width: 225, tire1_aspect: 45, tire1_rim: 17,
      tire2_width: 225, tire2_aspect: 45, tire2_rim: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Tire 2 rim diameter must be positive"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Automotive::TireSizeComparisonCalculator.new(
      tire1_width: "225", tire1_aspect: "45", tire1_rim: "17",
      tire2_width: "235", tire2_aspect: "40", tire2_rim: "18"
    ).call
    assert result[:valid]
  end
end
