require "test_helper"

class Physics::ElectricityCostCalculatorTest < ActiveSupport::TestCase
  test "solve for cost" do
    result = Physics::ElectricityCostCalculator.new(power: 2, hours: 5, rate: 0.12).call
    assert result[:valid]
    assert_in_delta 1.2, result[:cost], 0.01
    assert_equal 10.0, result[:kwh]
    assert_equal :cost, result[:solved_for]
  end

  test "solve for power" do
    result = Physics::ElectricityCostCalculator.new(cost: 1.2, hours: 5, rate: 0.12).call
    assert result[:valid]
    assert_in_delta 2.0, result[:power], 0.01
    assert_equal :power, result[:solved_for]
  end

  test "solve for hours" do
    result = Physics::ElectricityCostCalculator.new(cost: 1.2, power: 2, rate: 0.12).call
    assert result[:valid]
    assert_in_delta 5.0, result[:hours], 0.01
    assert_equal :hours, result[:solved_for]
  end

  test "solve for rate" do
    result = Physics::ElectricityCostCalculator.new(cost: 1.2, power: 2, hours: 5).call
    assert result[:valid]
    assert_in_delta 0.12, result[:rate], 0.001
    assert_equal :rate, result[:solved_for]
  end

  test "too few values returns error" do
    result = Physics::ElectricityCostCalculator.new(power: 2, hours: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Provide at least three values"
  end

  test "zero power returns error" do
    result = Physics::ElectricityCostCalculator.new(power: 0, hours: 5, rate: 0.12).call
    refute result[:valid]
  end

  test "errors accessor" do
    calc = Physics::ElectricityCostCalculator.new(power: 2, hours: 5, rate: 0.12)
    assert_equal [], calc.errors
  end
end
