require "test_helper"

class Physics::SpringConstantCalculatorTest < ActiveSupport::TestCase
  test "hookes_law: k = 10 N / 0.05 m = 200 N/m" do
    result = Physics::SpringConstantCalculator.new(
      mode: "hookes_law", force: 10, displacement: 0.05
    ).call
    assert result[:valid]
    assert_in_delta 200.0, result[:spring_constant_n_m], 0.01
    assert_equal "hookes_law", result[:mode]
  end

  test "hookes_law: potential energy PE = 0.5 * k * x^2" do
    result = Physics::SpringConstantCalculator.new(
      mode: "hookes_law", force: 10, displacement: 0.05
    ).call
    assert result[:valid]
    # PE = 0.5 * 200 * 0.05^2 = 0.25 J
    assert_in_delta 0.25, result[:potential_energy_j], 0.001
  end

  test "hookes_law: negative force and displacement give positive k" do
    result = Physics::SpringConstantCalculator.new(
      mode: "hookes_law", force: -15, displacement: -0.03
    ).call
    assert result[:valid]
    # k = |15| / |0.03| = 500
    assert_in_delta 500.0, result[:spring_constant_n_m], 0.01
  end

  test "hookes_law: large force and small displacement" do
    result = Physics::SpringConstantCalculator.new(
      mode: "hookes_law", force: 1000, displacement: 0.001
    ).call
    assert result[:valid]
    assert_in_delta 1_000_000.0, result[:spring_constant_n_m], 1.0
  end

  test "oscillation: k from mass and period" do
    # T = 2*pi*sqrt(m/k) => k = (2*pi/T)^2 * m
    # m = 0.5 kg, T = 1 s => k = (2*pi)^2 * 0.5 = 19.739 N/m
    result = Physics::SpringConstantCalculator.new(
      mode: "oscillation", mass: 0.5, period: 1.0
    ).call
    assert result[:valid]
    expected_k = (2 * Math::PI)**2 * 0.5
    assert_in_delta expected_k, result[:spring_constant_n_m], 0.01
  end

  test "oscillation: frequency is 1/T" do
    result = Physics::SpringConstantCalculator.new(
      mode: "oscillation", mass: 1.0, period: 0.5
    ).call
    assert result[:valid]
    assert_in_delta 2.0, result[:frequency_hz], 0.0001
  end

  test "oscillation: angular frequency is 2*pi*f" do
    result = Physics::SpringConstantCalculator.new(
      mode: "oscillation", mass: 1.0, period: 1.0
    ).call
    assert result[:valid]
    assert_in_delta 2 * Math::PI, result[:angular_frequency_rad_s], 0.01
  end

  test "oscillation: larger mass with same period gives larger k" do
    result1 = Physics::SpringConstantCalculator.new(
      mode: "oscillation", mass: 1.0, period: 1.0
    ).call
    result2 = Physics::SpringConstantCalculator.new(
      mode: "oscillation", mass: 2.0, period: 1.0
    ).call
    assert result1[:valid]
    assert result2[:valid]
    assert result2[:spring_constant_n_m] > result1[:spring_constant_n_m]
  end

  test "hookes_law: zero force returns error" do
    result = Physics::SpringConstantCalculator.new(
      mode: "hookes_law", force: 0, displacement: 0.05
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Force must be non-zero"
  end

  test "hookes_law: zero displacement returns error" do
    result = Physics::SpringConstantCalculator.new(
      mode: "hookes_law", force: 10, displacement: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Displacement must be non-zero"
  end

  test "oscillation: zero mass returns error" do
    result = Physics::SpringConstantCalculator.new(
      mode: "oscillation", mass: 0, period: 1.0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Mass must be a positive number"
  end

  test "oscillation: negative period returns error" do
    result = Physics::SpringConstantCalculator.new(
      mode: "oscillation", mass: 1.0, period: -1.0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Period must be a positive number"
  end

  test "invalid mode returns error" do
    result = Physics::SpringConstantCalculator.new(
      mode: "invalid", force: 10, displacement: 0.05
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Mode must be 'hookes_law' or 'oscillation'"
  end

  test "string coercion for numeric parameters" do
    result = Physics::SpringConstantCalculator.new(
      mode: "hookes_law", force: "10", displacement: "0.05"
    ).call
    assert result[:valid]
    assert_in_delta 200.0, result[:spring_constant_n_m], 0.01
  end

  test "errors accessor starts empty" do
    calc = Physics::SpringConstantCalculator.new(
      mode: "hookes_law", force: 10, displacement: 0.05
    )
    assert_equal [], calc.errors
  end
end
