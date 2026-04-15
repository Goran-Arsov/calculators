require "test_helper"

class Construction::HeatingCostCalculatorTest < ActiveSupport::TestCase
  BASE = {
    heat_loss_btu_hr: 40_000, hdd: 6000, design_dt: 60,
    fuel: "natural_gas", efficiency: 95, fuel_cost: 1.50
  }

  test "natural gas base case" do
    result = Construction::HeatingCostCalculator.new(**BASE).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # Annual output BTU = 40000 × 24 × 6000 / 60 = 96,000,000
    assert_in_delta 96_000_000, result[:annual_output_btu], 1
    # Fuel input = 96M / 0.95 = 101.05M
    # Therms = 101.05M / 100000 = 1010.5
    # Cost = 1010.5 × 1.50 = 1515.75
    assert_in_delta 1515.79, result[:annual_cost], 1
  end

  test "higher HDD means more cost" do
    mild = Construction::HeatingCostCalculator.new(**BASE.merge(hdd: 3000)).call
    cold = Construction::HeatingCostCalculator.new(**BASE.merge(hdd: 8000)).call
    assert cold[:annual_cost] > mild[:annual_cost]
  end

  test "higher efficiency cuts cost" do
    old = Construction::HeatingCostCalculator.new(**BASE.merge(efficiency: 70)).call
    new = Construction::HeatingCostCalculator.new(**BASE.merge(efficiency: 95)).call
    assert new[:annual_cost] < old[:annual_cost]
  end

  test "heat pump with COP 3.0 (300%) is cheap" do
    # 300% efficiency means the HP delivers 3× the electric input as heat
    result = Construction::HeatingCostCalculator.new(
      **BASE.merge(fuel: "electric", efficiency: 300, fuel_cost: 0.15)
    ).call
    # input = 96M/3 = 32M BTU = 9378 kWh × $0.15 = $1406.74
    assert_in_delta 1406, result[:annual_cost], 5
  end

  test "cost per million BTU" do
    result = Construction::HeatingCostCalculator.new(**BASE).call
    # $1515.79 × 1M / 96M ≈ $15.79/million BTU delivered
    assert_in_delta 15.79, result[:cost_per_million_btu], 0.2
  end

  test "wood in cords" do
    result = Construction::HeatingCostCalculator.new(
      **BASE.merge(fuel: "wood", efficiency: 75, fuel_cost: 300)
    ).call
    # 96M / 0.75 = 128M BTU / 24M per cord = 5.33 cords × $300 = $1600
    assert_in_delta 1600, result[:annual_cost], 5
  end

  test "error when heat loss is zero" do
    result = Construction::HeatingCostCalculator.new(**BASE.merge(heat_loss_btu_hr: 0)).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Heat loss must be greater than zero"
  end

  test "error for unknown fuel" do
    result = Construction::HeatingCostCalculator.new(**BASE.merge(fuel: "solar")).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Fuel must") }
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::HeatingCostCalculator.new(**BASE)
    assert_equal [], calc.errors
  end
end
