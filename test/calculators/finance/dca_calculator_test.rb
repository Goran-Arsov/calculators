require "test_helper"

class Finance::DcaCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "monthly=500, rate=7%, years=10 → future_value > total_invested" do
    result = Finance::DcaCalculator.new(monthly_investment: 500, annual_return: 7, years: 10).call
    assert result[:valid]
    assert_equal 60000.0, result[:total_invested]
    assert result[:future_value] > result[:total_invested]
    assert result[:total_return] > 0
  end

  test "zero return rate: future_value equals total_invested" do
    result = Finance::DcaCalculator.new(monthly_investment: 100, annual_return: 0, years: 5).call
    assert result[:valid]
    assert_equal 6000.0, result[:total_invested]
    assert_equal 6000.0, result[:future_value]
    assert_equal 0.0, result[:total_return]
  end

  test "monthly=1000, rate=10%, years=20 → large future value" do
    result = Finance::DcaCalculator.new(monthly_investment: 1000, annual_return: 10, years: 20).call
    assert result[:valid]
    assert result[:future_value] > 240000
  end

  # --- Validation errors ---

  test "error when monthly investment is zero" do
    result = Finance::DcaCalculator.new(monthly_investment: 0, annual_return: 7, years: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Monthly investment must be positive"
  end

  test "error when years is zero" do
    result = Finance::DcaCalculator.new(monthly_investment: 500, annual_return: 7, years: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Years must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::DcaCalculator.new(monthly_investment: 500, annual_return: 7, years: 10)
    assert_equal [], calc.errors
  end
end
