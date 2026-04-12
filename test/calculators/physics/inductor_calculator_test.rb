require "test_helper"

class Physics::InductorCalculatorTest < ActiveSupport::TestCase
  test "basic: energy stored E = 0.5 * L * I^2" do
    result = Physics::InductorCalculator.new(
      mode: "basic", inductance: 0.01, current: 2
    ).call
    assert result[:valid]
    # E = 0.5 * 0.01 * 4 = 0.02 J
    assert_in_delta 0.02, result[:energy_j], 0.0001
  end

  test "basic: millihenry conversion" do
    result = Physics::InductorCalculator.new(
      mode: "basic", inductance: 0.01, current: 2
    ).call
    assert result[:valid]
    assert_in_delta 10.0, result[:inductance_mh], 0.1
  end

  test "basic: zero current gives zero energy" do
    result = Physics::InductorCalculator.new(
      mode: "basic", inductance: 0.01, current: 0
    ).call
    assert result[:valid]
    assert_in_delta 0.0, result[:energy_j], 0.0001
  end

  test "series: inductances add" do
    result = Physics::InductorCalculator.new(
      mode: "series", inductances: "0.01, 0.02, 0.03"
    ).call
    assert result[:valid]
    assert_in_delta 0.06, result[:total_inductance_h], 0.0001
    assert_equal 3, result[:count]
  end

  test "parallel: reciprocals add" do
    result = Physics::InductorCalculator.new(
      mode: "parallel", inductances: "0.01, 0.01"
    ).call
    assert result[:valid]
    # 1/Lt = 1/0.01 + 1/0.01 = 200, Lt = 0.005
    assert_in_delta 0.005, result[:total_inductance_h], 0.0001
    assert_equal 2, result[:count]
  end

  test "parallel: result is less than smallest" do
    result = Physics::InductorCalculator.new(
      mode: "parallel", inductances: "0.01, 0.02"
    ).call
    assert result[:valid]
    assert result[:total_inductance_h] < 0.01
  end

  test "time_constant: tau = L/R" do
    result = Physics::InductorCalculator.new(
      mode: "time_constant", inductance: 0.1, resistance: 100
    ).call
    assert result[:valid]
    # tau = 0.1 / 100 = 0.001 s
    assert_in_delta 0.001, result[:time_constant_s], 0.00001
    assert_in_delta 1.0, result[:time_constant_ms], 0.01
  end

  test "time_constant: 3 tau and 5 tau" do
    result = Physics::InductorCalculator.new(
      mode: "time_constant", inductance: 0.1, resistance: 100
    ).call
    assert result[:valid]
    assert_in_delta 0.003, result[:time_to_95_percent_s], 0.00001
    assert_in_delta 0.005, result[:time_to_99_percent_s], 0.00001
  end

  test "zero inductance for basic returns error" do
    result = Physics::InductorCalculator.new(
      mode: "basic", inductance: 0, current: 2
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Inductance must be a positive number"
  end

  test "one inductor for series returns error" do
    result = Physics::InductorCalculator.new(
      mode: "series", inductances: "0.01"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "At least two inductance values are required for series calculation"
  end

  test "zero resistance for time_constant returns error" do
    result = Physics::InductorCalculator.new(
      mode: "time_constant", inductance: 0.1, resistance: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Resistance must be a positive number"
  end

  test "invalid mode returns error" do
    result = Physics::InductorCalculator.new(mode: "invalid").call
    refute result[:valid]
  end

  test "array input for inductances" do
    result = Physics::InductorCalculator.new(
      mode: "series", inductances: [ 0.01, 0.02 ]
    ).call
    assert result[:valid]
    assert_in_delta 0.03, result[:total_inductance_h], 0.0001
  end

  test "string coercion" do
    result = Physics::InductorCalculator.new(
      mode: "basic", inductance: "0.01", current: "2"
    ).call
    assert result[:valid]
  end
end
