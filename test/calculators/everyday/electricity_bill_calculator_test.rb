require "test_helper"

class Everyday::ElectricityBillCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "single appliance 100W 8h at $0.12/kWh" do
    result = Everyday::ElectricityBillCalculator.new(watts: "100", hours_per_day: "8", rate_per_kwh: 0.12).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # Daily: 100 * 8 / 1000 = 0.8 kWh
    assert_equal 0.8, result[:total_daily_kwh]
    # Monthly: 0.8 * 30 = 24.0 kWh
    assert_equal 24.0, result[:monthly_kwh]
    # Monthly cost: 24.0 * 0.12 = 2.88
    assert_equal 2.88, result[:monthly_cost]
  end

  test "multiple appliances" do
    result = Everyday::ElectricityBillCalculator.new(watts: "100,200", hours_per_day: "8,4", rate_per_kwh: 0.15).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # Daily: (100*8 + 200*4) / 1000 = 1.6 kWh
    assert_equal 1.6, result[:total_daily_kwh]
    # Monthly: 1.6 * 30 = 48.0 kWh
    assert_equal 48.0, result[:monthly_kwh]
    # Monthly cost: 48.0 * 0.15 = 7.2
    assert_equal 7.2, result[:monthly_cost]
  end

  test "yearly calculations" do
    result = Everyday::ElectricityBillCalculator.new(watts: "1000", hours_per_day: "1", rate_per_kwh: 0.10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # Daily: 1.0 kWh, Yearly: 365.0 kWh, Yearly cost: 36.50
    assert_equal 365.0, result[:yearly_kwh]
    assert_equal 36.5, result[:yearly_cost]
  end

  test "appliance with quantity > 1" do
    result = Everyday::ElectricityBillCalculator.new(watts: "60", hours_per_day: "10", rate_per_kwh: 0.12, quantity: "3").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # Daily: 60 * 10 * 3 / 1000 = 1.8 kWh
    assert_equal 1.8, result[:total_daily_kwh]
  end

  test "appliances array is returned" do
    result = Everyday::ElectricityBillCalculator.new(watts: "100,200", hours_per_day: "8,4", rate_per_kwh: 0.15).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 2, result[:appliances].size
    assert_equal 100.0, result[:appliances][0][:watts]
    assert_equal 0.8, result[:appliances][0][:daily_kwh]
  end

  test "high wattage appliance" do
    result = Everyday::ElectricityBillCalculator.new(watts: "5000", hours_per_day: "2", rate_per_kwh: 0.10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # Daily: 10.0 kWh, Monthly: 300.0 kWh, Monthly cost: 30.00
    assert_equal 10.0, result[:total_daily_kwh]
    assert_equal 300.0, result[:monthly_kwh]
    assert_equal 30.0, result[:monthly_cost]
  end

  # --- Validation errors ---

  test "error when watts are empty" do
    result = Everyday::ElectricityBillCalculator.new(watts: "", hours_per_day: "8", rate_per_kwh: 0.12).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Watts cannot be empty"
  end

  test "error when watts and hours counts differ" do
    result = Everyday::ElectricityBillCalculator.new(watts: "100,200", hours_per_day: "8", rate_per_kwh: 0.12).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Number of wattage entries must match hours entries"
  end

  test "error when rate is zero" do
    result = Everyday::ElectricityBillCalculator.new(watts: "100", hours_per_day: "8", rate_per_kwh: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Rate per kWh must be greater than zero"
  end

  test "error when watts are not positive" do
    result = Everyday::ElectricityBillCalculator.new(watts: "0", hours_per_day: "8", rate_per_kwh: 0.12).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "All wattages must be greater than zero"
  end

  test "error when hours exceed 24" do
    result = Everyday::ElectricityBillCalculator.new(watts: "100", hours_per_day: "25", rate_per_kwh: 0.12).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Hours per day must be between 0 and 24"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::ElectricityBillCalculator.new(watts: "100", hours_per_day: "8", rate_per_kwh: 0.12)
    assert_equal [], calc.errors
  end
end
