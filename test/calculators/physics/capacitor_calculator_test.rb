require "test_helper"

class Physics::CapacitorCalculatorTest < ActiveSupport::TestCase
  test "basic: C and V given, find Q and E" do
    result = Physics::CapacitorCalculator.new(
      mode: "basic", capacitance: 0.001, voltage: 12
    ).call
    assert result[:valid]
    # Q = CV = 0.001 * 12 = 0.012 C
    assert_in_delta 0.012, result[:charge_c], 0.0001
    # E = 0.5 * C * V^2 = 0.5 * 0.001 * 144 = 0.072 J
    assert_in_delta 0.072, result[:energy_j], 0.0001
  end

  test "basic: Q and V given, find C" do
    result = Physics::CapacitorCalculator.new(
      mode: "basic", charge: 0.012, voltage: 12
    ).call
    assert result[:valid]
    assert_in_delta 0.001, result[:capacitance_f], 0.00001
  end

  test "basic: Q and C given, find V" do
    result = Physics::CapacitorCalculator.new(
      mode: "basic", charge: 0.012, capacitance: 0.001
    ).call
    assert result[:valid]
    assert_in_delta 12.0, result[:voltage_v], 0.01
  end

  test "basic: microfarad conversion" do
    result = Physics::CapacitorCalculator.new(
      mode: "basic", capacitance: 0.001, voltage: 12
    ).call
    assert result[:valid]
    assert_in_delta 1000.0, result[:capacitance_uf], 0.1
  end

  test "series: two equal capacitors" do
    result = Physics::CapacitorCalculator.new(
      mode: "series", capacitances: "0.001, 0.001"
    ).call
    assert result[:valid]
    # Series: 1/Ct = 1/0.001 + 1/0.001 = 2000, Ct = 0.0005
    assert_in_delta 0.0005, result[:total_capacitance_f], 0.00001
    assert_equal 2, result[:count]
  end

  test "series: result is less than smallest" do
    result = Physics::CapacitorCalculator.new(
      mode: "series", capacitances: "0.001, 0.002"
    ).call
    assert result[:valid]
    assert result[:total_capacitance_f] < 0.001
  end

  test "parallel: two capacitors add" do
    result = Physics::CapacitorCalculator.new(
      mode: "parallel", capacitances: "0.001, 0.002"
    ).call
    assert result[:valid]
    assert_in_delta 0.003, result[:total_capacitance_f], 0.00001
    assert_equal 2, result[:count]
  end

  test "parallel: three capacitors" do
    result = Physics::CapacitorCalculator.new(
      mode: "parallel", capacitances: "0.001, 0.002, 0.003"
    ).call
    assert result[:valid]
    assert_in_delta 0.006, result[:total_capacitance_f], 0.00001
    assert_equal 3, result[:count]
  end

  test "basic: only one value returns error" do
    result = Physics::CapacitorCalculator.new(
      mode: "basic", capacitance: 0.001
    ).call
    refute result[:valid]
    assert_includes result[:errors], "At least two of capacitance, voltage, and charge are required"
  end

  test "series: one capacitor returns error" do
    result = Physics::CapacitorCalculator.new(
      mode: "series", capacitances: "0.001"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "At least two capacitance values are required for series calculation"
  end

  test "invalid mode returns error" do
    result = Physics::CapacitorCalculator.new(mode: "invalid").call
    refute result[:valid]
  end

  test "array input for capacitances" do
    result = Physics::CapacitorCalculator.new(
      mode: "parallel", capacitances: [ 0.001, 0.002 ]
    ).call
    assert result[:valid]
    assert_in_delta 0.003, result[:total_capacitance_f], 0.00001
  end

  test "string coercion" do
    result = Physics::CapacitorCalculator.new(
      mode: "basic", capacitance: "0.001", voltage: "12"
    ).call
    assert result[:valid]
  end
end
