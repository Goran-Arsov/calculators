require "test_helper"

class Finance::InflationCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "PV=1000, rate=3%, years=10 → future value > 1000" do
    result = Finance::InflationCalculator.new(present_value: 1000, rate: 3, years: 10).call
    assert result[:valid]
    assert result[:future_value] > 1000
    assert_in_delta 1343.9164, result[:future_value], 0.01
  end

  test "zero inflation rate returns same value" do
    result = Finance::InflationCalculator.new(present_value: 1000, rate: 0, years: 10).call
    assert result[:valid]
    assert_equal 1000.0, result[:future_value]
    assert_equal 0.0, result[:purchasing_power_loss]
  end

  test "one year at 5% inflation" do
    result = Finance::InflationCalculator.new(present_value: 100, rate: 5, years: 1).call
    assert result[:valid]
    assert_equal 105.0, result[:future_value]
    assert_equal 5.0, result[:purchasing_power_loss]
  end

  # --- Validation errors ---

  test "error when present value is zero" do
    result = Finance::InflationCalculator.new(present_value: 0, rate: 3, years: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Present value must be positive"
  end

  test "error when rate is negative" do
    result = Finance::InflationCalculator.new(present_value: 1000, rate: -2, years: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Inflation rate cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::InflationCalculator.new(present_value: 1000, rate: 3, years: 10)
    assert_equal [], calc.errors
  end
end
