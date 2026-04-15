require "test_helper"

class Construction::VoltageDropCalculatorTest < ActiveSupport::TestCase
  test "12 AWG copper, 100 ft one-way, 20 A, 120 V single phase" do
    result = Construction::VoltageDropCalculator.new(
      awg: "12", length_ft: 100, amps: 20, voltage: 120, phase: "single", material: "cu"
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # Vd = 2 * 100 * 20 * 1.98 / 1000 = 7.92 V → 6.6%
    assert_in_delta 7.92, result[:vd_volts], 0.01
    assert_in_delta 6.6, result[:vd_pct], 0.01
    assert_equal false, result[:within_branch_3pct]
  end

  test "10 AWG reduces drop" do
    r12 = Construction::VoltageDropCalculator.new(awg: "12", length_ft: 100, amps: 20, voltage: 120).call
    r10 = Construction::VoltageDropCalculator.new(awg: "10", length_ft: 100, amps: 20, voltage: 120).call
    assert r10[:vd_volts] < r12[:vd_volts]
  end

  test "aluminum has higher resistance than copper" do
    cu = Construction::VoltageDropCalculator.new(awg: "6", length_ft: 200, amps: 50, voltage: 240, material: "cu").call
    al = Construction::VoltageDropCalculator.new(awg: "6", length_ft: 200, amps: 50, voltage: 240, material: "al").call
    assert al[:vd_pct] > cu[:vd_pct]
  end

  test "three-phase uses sqrt(3) factor" do
    sp = Construction::VoltageDropCalculator.new(awg: "6", length_ft: 200, amps: 50, voltage: 240, phase: "single").call
    tp = Construction::VoltageDropCalculator.new(awg: "6", length_ft: 200, amps: 50, voltage: 240, phase: "three").call
    # sqrt(3) ≈ 1.732; single uses 2. Three-phase drop ≈ 1.732/2 × single.
    assert_in_delta sp[:vd_volts] * (Math.sqrt(3) / 2), tp[:vd_volts], 0.01
  end

  test "within branch 3% threshold" do
    good = Construction::VoltageDropCalculator.new(awg: "12", length_ft: 30, amps: 15, voltage: 120).call
    assert good[:within_branch_3pct]
    bad = Construction::VoltageDropCalculator.new(awg: "14", length_ft: 200, amps: 15, voltage: 120).call
    assert_equal false, bad[:within_branch_3pct]
  end

  test "end voltage is source minus drop" do
    r = Construction::VoltageDropCalculator.new(awg: "10", length_ft: 100, amps: 20, voltage: 120).call
    assert_in_delta r[:end_volts], 120 - r[:vd_volts], 0.01
  end

  test "error for unknown AWG" do
    result = Construction::VoltageDropCalculator.new(awg: "22", length_ft: 50, amps: 5, voltage: 24).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("AWG must be") }
  end

  test "error when length is zero" do
    result = Construction::VoltageDropCalculator.new(awg: "12", length_ft: 0, amps: 20, voltage: 120).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::VoltageDropCalculator.new(awg: "12", length_ft: 100, amps: 20, voltage: 120)
    assert_equal [], calc.errors
  end
end
