require "test_helper"

class Finance::CdCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: 1-year CD at 5% APY daily compounding" do
    calc = Finance::CdCalculator.new(principal: 10_000, apy: 5, term_months: 12, compounding: "daily")
    result = calc.call

    assert result[:valid]
    # With 5% APY for 1 year, interest should be $500
    assert_in_delta 10_500.0, result[:maturity_value], 1.0
    assert_in_delta 500.0, result[:interest_earned], 1.0
    assert_equal 12, result[:term_months]
  end

  test "happy path: 6-month CD" do
    calc = Finance::CdCalculator.new(principal: 5_000, apy: 4.5, term_months: 6)
    result = calc.call

    assert result[:valid]
    assert result[:maturity_value] > 5_000
    assert result[:interest_earned] > 0
    # For half a year at 4.5% APY, interest should be roughly $112.50
    assert_in_delta 112.50, result[:interest_earned], 5.0
  end

  test "happy path: 5-year CD" do
    calc = Finance::CdCalculator.new(principal: 25_000, apy: 4, term_months: 60)
    result = calc.call

    assert result[:valid]
    # 5 years at 4% APY: 25000 * (1.04)^5 ≈ 30,416.32
    assert_in_delta 30_416.32, result[:maturity_value], 5.0
    assert_equal 60, result[:term_months]
  end

  # --- Different compounding frequencies ---

  test "monthly compounding produces same APY result" do
    calc = Finance::CdCalculator.new(principal: 10_000, apy: 5, term_months: 12, compounding: "monthly")
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_500.0, result[:maturity_value], 1.0
  end

  test "quarterly compounding produces same APY result" do
    calc = Finance::CdCalculator.new(principal: 10_000, apy: 5, term_months: 12, compounding: "quarterly")
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_500.0, result[:maturity_value], 1.0
  end

  test "annually compounding produces same APY result" do
    calc = Finance::CdCalculator.new(principal: 10_000, apy: 5, term_months: 12, compounding: "annually")
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_500.0, result[:maturity_value], 1.0
  end

  # --- Zero / Negative values ---

  test "zero principal returns error" do
    calc = Finance::CdCalculator.new(principal: 0, apy: 5, term_months: 12)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Principal must be positive"
  end

  test "zero APY returns error" do
    calc = Finance::CdCalculator.new(principal: 10_000, apy: 0, term_months: 12)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "APY must be positive"
  end

  test "zero term returns error" do
    calc = Finance::CdCalculator.new(principal: 10_000, apy: 5, term_months: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Term must be positive"
  end

  test "invalid compounding returns error" do
    calc = Finance::CdCalculator.new(principal: 10_000, apy: 5, term_months: 12, compounding: "hourly")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid compounding frequency"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::CdCalculator.new(principal: "10000", apy: "5", term_months: "12")
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_500.0, result[:maturity_value], 1.0
  end

  # --- Large numbers ---

  test "very large principal still computes" do
    calc = Finance::CdCalculator.new(principal: 10_000_000, apy: 5, term_months: 60)
    result = calc.call

    assert result[:valid]
    assert result[:maturity_value] > 10_000_000
    assert result[:interest_earned] > 0
  end

  # --- Monthly breakdown ---

  test "monthly breakdown has correct number of entries" do
    calc = Finance::CdCalculator.new(principal: 10_000, apy: 5, term_months: 24)
    result = calc.call

    assert result[:valid]
    assert_equal 24, result[:monthly_breakdown].size
    assert_equal 1, result[:monthly_breakdown].first[:month]
    assert_equal 24, result[:monthly_breakdown].last[:month]
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::CdCalculator.new(principal: 0, apy: 0, term_months: 0, compounding: "invalid")
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 3
  end
end
