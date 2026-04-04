require "test_helper"

class Finance::SolarSavingsCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic calculation returns annual_production, annual_savings, payback_years" do
    result = Finance::SolarSavingsCalculator.new(
      system_size_kw: 6, electricity_rate: 0.12, sun_hours_per_day: 5, system_cost: 15000
    ).call
    assert result[:valid]
    assert result[:annual_production_kwh] > 0
    assert result[:annual_savings] > 0
    assert result[:payback_years] > 0
  end

  test "annual production equals system_size * sun_hours * 365" do
    result = Finance::SolarSavingsCalculator.new(
      system_size_kw: 10, electricity_rate: 0.10, sun_hours_per_day: 4, system_cost: 20000
    ).call
    assert result[:valid]
    expected_production = 10 * 4 * 365
    assert_equal expected_production.round(4), result[:annual_production_kwh]
  end

  test "25-year savings calculation" do
    result = Finance::SolarSavingsCalculator.new(
      system_size_kw: 8, electricity_rate: 0.15, sun_hours_per_day: 5, system_cost: 18000
    ).call
    assert result[:valid]
    expected_savings_25 = (result[:annual_savings] * 25) - 18000
    assert_in_delta expected_savings_25, result[:savings_25_years], 0.01
  end

  # --- Validation errors ---

  test "error when system size is zero" do
    result = Finance::SolarSavingsCalculator.new(
      system_size_kw: 0, electricity_rate: 0.12, sun_hours_per_day: 5, system_cost: 15000
    ).call
    refute result[:valid]
    assert_includes result[:errors], "System size must be positive"
  end

  test "error when sun hours exceed 24" do
    result = Finance::SolarSavingsCalculator.new(
      system_size_kw: 6, electricity_rate: 0.12, sun_hours_per_day: 25, system_cost: 15000
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Sun hours per day cannot exceed 24"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::SolarSavingsCalculator.new(
      system_size_kw: 6, electricity_rate: 0.12, sun_hours_per_day: 5, system_cost: 15000
    )
    assert_equal [], calc.errors
  end
end
