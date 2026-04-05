require "test_helper"

class Construction::StaircaseCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "108 inch rise → reasonable step count" do
    result = Construction::StaircaseCalculator.new(floor_height: 108).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 108 / 7.0 ≈ 15.4 → rounds to 15 risers
    assert_equal 15, result[:num_risers]
    assert_equal 14, result[:num_treads]
  end

  test "rise per step is within code limits" do
    result = Construction::StaircaseCalculator.new(floor_height: 108).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:rise_per_step] <= 7.75
    assert result[:rise_per_step] > 0
  end

  test "treads are one less than risers" do
    result = Construction::StaircaseCalculator.new(floor_height: 96).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal result[:num_risers] - 1, result[:num_treads]
  end

  test "custom run preference is respected" do
    result = Construction::StaircaseCalculator.new(floor_height: 108, run_preference: 11).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_in_delta 11.0, result[:run_per_step], 0.01
  end

  test "auto run uses comfort rule (riser + run ≈ 17.5)" do
    result = Construction::StaircaseCalculator.new(floor_height: 108).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    sum = result[:rise_per_step] + result[:run_per_step]
    # Should be approximately 17.5, but run is clamped to >= 10
    assert sum >= 17.0
    assert sum <= 18.0
  end

  test "stringer length matches pythagorean theorem" do
    result = Construction::StaircaseCalculator.new(floor_height: 108).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    expected = Math.sqrt(108**2 + result[:total_run]**2)
    assert_in_delta expected, result[:stringer_length], 0.1
  end

  test "angle is between 30 and 42 degrees for standard stairs" do
    result = Construction::StaircaseCalculator.new(floor_height: 108).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:angle] >= 30
    assert result[:angle] <= 42
  end

  test "string inputs are coerced" do
    result = Construction::StaircaseCalculator.new(floor_height: "108", run_preference: "11").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 15, result[:num_risers]
  end

  # --- Validation errors ---

  test "error when floor height is zero" do
    result = Construction::StaircaseCalculator.new(floor_height: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Floor height must be greater than zero"
  end

  test "error when run preference is less than 10 inches" do
    result = Construction::StaircaseCalculator.new(floor_height: 108, run_preference: 8).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Run preference must be at least 10.0 inches (IRC minimum)"
  end

  test "error when floor height exceeds 780 inches" do
    result = Construction::StaircaseCalculator.new(floor_height: 781).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Floor height cannot exceed 780.0 inches (65 feet)"
  end

  test "floor height at 780 inches is accepted" do
    result = Construction::StaircaseCalculator.new(floor_height: 780).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:num_risers] > 0
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::StaircaseCalculator.new(floor_height: 108)
    assert_equal [], calc.errors
  end
end
