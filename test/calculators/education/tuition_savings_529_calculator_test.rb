require "test_helper"

class Education::TuitionSavings529CalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "projects 529 growth over 18 years" do
    calc = Education::TuitionSavings529Calculator.new(
      current_balance: 0, monthly_contribution: 300,
      annual_return: 6.0, years_until_college: 18, state_tax_rate: 5.0
    )
    result = calc.call

    assert result[:valid]
    assert result[:final_balance] > 0
    assert result[:total_contributions] > 0
    assert result[:total_earnings] > 0
    assert result[:tax_free_earnings] > 0
    assert result[:total_tax_deduction] > 0
    assert_equal 18, result[:yearly_projections].size
    assert result[:coverage_percentage] > 0
  end

  test "contributions compound with returns" do
    calc = Education::TuitionSavings529Calculator.new(
      monthly_contribution: 500, annual_return: 7.0, years_until_college: 18
    )
    result = calc.call

    assert result[:valid]
    total_contributed = 500 * 12 * 18
    assert result[:final_balance] > total_contributed
    assert result[:total_earnings] > 0
  end

  # --- Starting balance ---

  test "existing balance grows alongside contributions" do
    without_balance = Education::TuitionSavings529Calculator.new(
      current_balance: 0, monthly_contribution: 300,
      annual_return: 6.0, years_until_college: 10
    )
    with_balance = Education::TuitionSavings529Calculator.new(
      current_balance: 10_000, monthly_contribution: 300,
      annual_return: 6.0, years_until_college: 10
    )

    assert with_balance.call[:final_balance] > without_balance.call[:final_balance]
  end

  # --- Tax benefits ---

  test "state tax deduction calculated correctly" do
    calc = Education::TuitionSavings529Calculator.new(
      monthly_contribution: 500, annual_return: 6.0,
      years_until_college: 18, state_tax_rate: 5.0
    )
    result = calc.call

    expected_deduction = 500 * 12 * 0.05 * 18
    assert_in_delta expected_deduction, result[:total_tax_deduction], 0.01
  end

  test "zero state tax rate gives no deduction" do
    calc = Education::TuitionSavings529Calculator.new(
      monthly_contribution: 500, annual_return: 6.0,
      years_until_college: 18, state_tax_rate: 0.0
    )
    result = calc.call

    assert_equal 0.0, result[:total_tax_deduction]
  end

  # --- Year-by-year projections ---

  test "yearly projections show growth" do
    calc = Education::TuitionSavings529Calculator.new(
      monthly_contribution: 300, annual_return: 6.0, years_until_college: 5
    )
    result = calc.call

    assert result[:valid]
    assert_equal 5, result[:yearly_projections].size

    projections = result[:yearly_projections]
    assert projections.last[:end_balance] > projections.first[:end_balance]
    projections.each do |p|
      assert p[:contributions] > 0
      assert p[:earnings] >= 0
      assert p[:end_balance] > p[:start_balance]
    end
  end

  # --- Zero return ---

  test "zero return means only contributions grow balance" do
    calc = Education::TuitionSavings529Calculator.new(
      monthly_contribution: 100, annual_return: 0.0, years_until_college: 10
    )
    result = calc.call

    assert result[:valid]
    expected = 100 * 12 * 10
    assert_in_delta expected, result[:final_balance], 0.01
    assert_in_delta 0.0, result[:total_earnings], 0.01
  end

  # --- College cost coverage ---

  test "coverage percentage calculated against projected costs" do
    calc = Education::TuitionSavings529Calculator.new(
      monthly_contribution: 1_000, annual_return: 7.0, years_until_college: 18
    )
    result = calc.call

    assert result[:valid]
    assert result[:projected_4_year_cost] > 0
    assert result[:coverage_percentage] > 0
  end

  # --- Validation ---

  test "negative balance returns error" do
    calc = Education::TuitionSavings529Calculator.new(
      current_balance: -1_000, monthly_contribution: 300,
      years_until_college: 18
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Current balance cannot be negative"
  end

  test "zero monthly contribution returns error" do
    calc = Education::TuitionSavings529Calculator.new(
      monthly_contribution: 0, years_until_college: 18
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly contribution must be positive"
  end

  test "zero years returns error" do
    calc = Education::TuitionSavings529Calculator.new(
      monthly_contribution: 300, years_until_college: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Years until college must be between 1 and 25"
  end

  test "negative return rate returns error" do
    calc = Education::TuitionSavings529Calculator.new(
      monthly_contribution: 300, annual_return: -5.0, years_until_college: 18
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual return rate cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    calc = Education::TuitionSavings529Calculator.new(
      monthly_contribution: "300", annual_return: "6",
      years_until_college: "18"
    )
    result = calc.call

    assert result[:valid]
    assert result[:final_balance] > 0
  end
end
