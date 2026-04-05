require "test_helper"

class Everyday::CostPerMileCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic cost per mile calculation" do
    result = Everyday::CostPerMileCalculator.new(
      fuel_cost: 2400, insurance_cost: 1500, maintenance_cost: 1000,
      depreciation_cost: 3000, miles_driven: 12000
    ).call
    assert_nil result[:errors]
    total = 2400 + 1500 + 1000 + 3000
    assert_in_delta total / 12000.0, result[:cost_per_mile], 0.001
    assert_equal 7900.0, result[:total_cost]
  end

  test "cost per km is lower than cost per mile" do
    result = Everyday::CostPerMileCalculator.new(
      fuel_cost: 2000, insurance_cost: 1000, maintenance_cost: 500,
      depreciation_cost: 2000, miles_driven: 10000
    ).call
    assert_nil result[:errors]
    assert result[:cost_per_km] < result[:cost_per_mile]
  end

  test "km driven is higher than miles driven" do
    result = Everyday::CostPerMileCalculator.new(
      fuel_cost: 1000, insurance_cost: 500, maintenance_cost: 300,
      depreciation_cost: 1000, miles_driven: 10000
    ).call
    assert_nil result[:errors]
    assert_in_delta 16093.4, result[:km_driven], 0.1
  end

  test "includes other costs" do
    result = Everyday::CostPerMileCalculator.new(
      fuel_cost: 2000, insurance_cost: 1000, maintenance_cost: 500,
      depreciation_cost: 2000, miles_driven: 10000, other_costs: 500
    ).call
    assert_nil result[:errors]
    assert_equal 6000.0, result[:total_cost]
  end

  test "cost breakdown returned" do
    result = Everyday::CostPerMileCalculator.new(
      fuel_cost: 2000, insurance_cost: 1000, maintenance_cost: 500,
      depreciation_cost: 2000, miles_driven: 10000, other_costs: 500
    ).call
    assert_nil result[:errors]
    assert_equal 2000.0, result[:breakdown][:fuel]
    assert_equal 1000.0, result[:breakdown][:insurance]
    assert_equal 500.0, result[:breakdown][:maintenance]
    assert_equal 2000.0, result[:breakdown][:depreciation]
    assert_equal 500.0, result[:breakdown][:other]
  end

  # --- Validation errors ---

  test "error when miles driven is zero" do
    result = Everyday::CostPerMileCalculator.new(
      fuel_cost: 2000, insurance_cost: 1000, maintenance_cost: 500,
      depreciation_cost: 2000, miles_driven: 0
    ).call
    assert result[:errors].any?
    assert_includes result[:errors], "Miles driven must be greater than zero"
  end

  test "error when fuel cost is negative" do
    result = Everyday::CostPerMileCalculator.new(
      fuel_cost: -100, insurance_cost: 1000, maintenance_cost: 500,
      depreciation_cost: 2000, miles_driven: 10000
    ).call
    assert result[:errors].any?
    assert_includes result[:errors], "Fuel cost cannot be negative"
  end

  test "error when all costs are zero" do
    result = Everyday::CostPerMileCalculator.new(
      fuel_cost: 0, insurance_cost: 0, maintenance_cost: 0,
      depreciation_cost: 0, miles_driven: 10000
    ).call
    assert result[:errors].any?
    assert_includes result[:errors], "Total costs must be greater than zero"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::CostPerMileCalculator.new(
      fuel_cost: "2000", insurance_cost: "1000", maintenance_cost: "500",
      depreciation_cost: "2000", miles_driven: "10000"
    ).call
    assert_nil result[:errors]
    assert_equal 5500.0, result[:total_cost]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::CostPerMileCalculator.new(
      fuel_cost: 2000, insurance_cost: 1000, maintenance_cost: 500,
      depreciation_cost: 2000, miles_driven: 10000
    )
    assert_equal [], calc.errors
  end

  test "only fuel cost with no other expenses" do
    result = Everyday::CostPerMileCalculator.new(
      fuel_cost: 2400, insurance_cost: 0, maintenance_cost: 0,
      depreciation_cost: 0, miles_driven: 12000
    ).call
    assert_nil result[:errors]
    assert_equal 0.2, result[:cost_per_mile]
  end

  test "high mileage driver" do
    result = Everyday::CostPerMileCalculator.new(
      fuel_cost: 5000, insurance_cost: 1500, maintenance_cost: 2000,
      depreciation_cost: 4000, miles_driven: 50000
    ).call
    assert_nil result[:errors]
    assert_equal 12500.0, result[:total_cost]
    assert_equal 0.25, result[:cost_per_mile]
  end
end
