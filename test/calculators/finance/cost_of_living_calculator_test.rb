require "test_helper"

class Finance::CostOfLivingCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: moving to more expensive city ---

  test "$80k salary from index 85 to index 110" do
    result = Finance::CostOfLivingCalculator.new(
      current_salary: 80_000, current_index: 85, target_index: 110
    ).call

    assert result[:valid]
    # ratio = 110/85 = 1.2941
    assert_in_delta 103_529.41, result[:equivalent_salary], 0.01
    assert_in_delta 23_529.41, result[:salary_difference], 0.01
    assert_in_delta 29.41, result[:percentage_difference], 0.01
  end

  # --- Happy path: moving to cheaper city ---

  test "$80k salary from index 110 to index 85" do
    result = Finance::CostOfLivingCalculator.new(
      current_salary: 80_000, current_index: 110, target_index: 85
    ).call

    assert result[:valid]
    assert result[:equivalent_salary] < 80_000
    assert result[:salary_difference] < 0
    assert result[:percentage_difference] < 0
  end

  # --- Happy path: same city ---

  test "same index returns same salary" do
    result = Finance::CostOfLivingCalculator.new(
      current_salary: 80_000, current_index: 100, target_index: 100
    ).call

    assert result[:valid]
    assert_in_delta 80_000.0, result[:equivalent_salary], 0.01
    assert_in_delta 0.0, result[:salary_difference], 0.01
    assert_in_delta 0.0, result[:percentage_difference], 0.01
  end

  # --- Purchasing power ---

  test "purchasing power decreases when moving to expensive city" do
    result = Finance::CostOfLivingCalculator.new(
      current_salary: 80_000, current_index: 85, target_index: 110
    ).call

    assert result[:valid]
    assert result[:purchasing_power] < 80_000
    assert_in_delta 61_818.18, result[:purchasing_power], 0.01
  end

  test "purchasing power increases when moving to cheaper city" do
    result = Finance::CostOfLivingCalculator.new(
      current_salary: 80_000, current_index: 110, target_index: 85
    ).call

    assert result[:valid]
    assert result[:purchasing_power] > 80_000
  end

  # --- Validation errors ---

  test "error when salary is zero" do
    result = Finance::CostOfLivingCalculator.new(
      current_salary: 0, current_index: 85, target_index: 110
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Current salary must be greater than zero"
  end

  test "error when current index is zero" do
    result = Finance::CostOfLivingCalculator.new(
      current_salary: 80_000, current_index: 0, target_index: 110
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Current city index must be greater than zero"
  end

  test "error when target index is negative" do
    result = Finance::CostOfLivingCalculator.new(
      current_salary: 80_000, current_index: 85, target_index: -10
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Target city index must be greater than zero"
  end

  test "multiple errors at once" do
    result = Finance::CostOfLivingCalculator.new(
      current_salary: 0, current_index: 0, target_index: 0
    ).call

    refute result[:valid]
    assert_equal 3, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Finance::CostOfLivingCalculator.new(
      current_salary: "80000", current_index: "85", target_index: "110"
    ).call

    assert result[:valid]
    assert_in_delta 103_529.41, result[:equivalent_salary], 0.01
  end

  # --- Edge cases ---

  test "cost ratio is correct" do
    result = Finance::CostOfLivingCalculator.new(
      current_salary: 50_000, current_index: 100, target_index: 150
    ).call

    assert result[:valid]
    assert_in_delta 1.5, result[:cost_ratio], 0.001
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::CostOfLivingCalculator.new(
      current_salary: 80_000, current_index: 85, target_index: 110
    )
    assert_equal [], calc.errors
  end
end
