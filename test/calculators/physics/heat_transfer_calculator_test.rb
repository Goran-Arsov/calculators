require "test_helper"

class Physics::HeatTransferCalculatorTest < ActiveSupport::TestCase
  test "copper: Q = 401 * 1 * 50 / 0.01 = 2,005,000 W" do
    result = Physics::HeatTransferCalculator.new(
      material: "copper", area: 1.0, thickness: 0.01, temp_difference: 50
    ).call
    assert result[:valid]
    assert_in_delta 2_005_000.0, result[:heat_transfer_rate_w], 1.0
    assert_in_delta 401.0, result[:thermal_conductivity], 0.01
  end

  test "aluminum: Q = 237 * 2 * 30 / 0.05 = 284,400 W" do
    result = Physics::HeatTransferCalculator.new(
      material: "aluminum", area: 2.0, thickness: 0.05, temp_difference: 30
    ).call
    assert result[:valid]
    assert_in_delta 284_400.0, result[:heat_transfer_rate_w], 1.0
  end

  test "styrofoam insulation: very low heat transfer" do
    result = Physics::HeatTransferCalculator.new(
      material: "styrofoam", area: 10.0, thickness: 0.1, temp_difference: 20
    ).call
    assert result[:valid]
    # Q = 0.033 * 10 * 20 / 0.1 = 66 W
    assert_in_delta 66.0, result[:heat_transfer_rate_w], 0.1
  end

  test "BTU/hr conversion factor is approximately 3.41214" do
    result = Physics::HeatTransferCalculator.new(
      material: "copper", area: 1.0, thickness: 1.0, temp_difference: 1
    ).call
    assert result[:valid]
    # Q = 401 W, BTU/hr = 401 * 3.41214
    assert_in_delta 401.0 * 3.41214, result[:heat_transfer_rate_btu_hr], 0.1
  end

  test "thermal resistance calculation: R = d / (k * A)" do
    result = Physics::HeatTransferCalculator.new(
      material: "copper", area: 2.0, thickness: 0.1, temp_difference: 50
    ).call
    assert result[:valid]
    # R = 0.1 / (401 * 2) = 0.000124688
    assert_in_delta 0.000125, result[:thermal_resistance_kw], 0.00001
  end

  test "heat flux calculation: q = Q / A" do
    result = Physics::HeatTransferCalculator.new(
      material: "steel", area: 2.0, thickness: 0.01, temp_difference: 100
    ).call
    assert result[:valid]
    # Q = 50.2 * 2 * 100 / 0.01 = 1_004_000
    # flux = 1_004_000 / 2 = 502_000
    assert_in_delta 502_000.0, result[:heat_flux_w_m2], 1.0
  end

  test "custom material with explicit k value" do
    result = Physics::HeatTransferCalculator.new(
      material: "custom", area: 1.0, thickness: 0.01, temp_difference: 50, custom_k: 100
    ).call
    assert result[:valid]
    # Q = 100 * 1 * 50 / 0.01 = 500,000
    assert_in_delta 500_000.0, result[:heat_transfer_rate_w], 1.0
    assert_equal "Custom", result[:material_name]
  end

  test "custom material without k returns error" do
    result = Physics::HeatTransferCalculator.new(
      material: "custom", area: 1.0, thickness: 0.01, temp_difference: 50
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Custom thermal conductivity must be a positive number"
  end

  test "zero area returns error" do
    result = Physics::HeatTransferCalculator.new(
      material: "copper", area: 0, thickness: 0.01, temp_difference: 50
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Area must be a positive number"
  end

  test "zero thickness returns error" do
    result = Physics::HeatTransferCalculator.new(
      material: "copper", area: 1.0, thickness: 0, temp_difference: 50
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Thickness must be a positive number"
  end

  test "zero temperature difference returns error" do
    result = Physics::HeatTransferCalculator.new(
      material: "copper", area: 1.0, thickness: 0.01, temp_difference: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Temperature difference must be non-zero"
  end

  test "unknown material returns error" do
    result = Physics::HeatTransferCalculator.new(
      material: "unobtanium", area: 1.0, thickness: 0.01, temp_difference: 50
    ).call
    refute result[:valid]
  end

  test "string coercion for numeric parameters" do
    result = Physics::HeatTransferCalculator.new(
      material: "copper", area: "1.0", thickness: "0.01", temp_difference: "50"
    ).call
    assert result[:valid]
    assert_in_delta 2_005_000.0, result[:heat_transfer_rate_w], 1.0
  end

  test "negative temperature difference gives negative heat transfer" do
    result = Physics::HeatTransferCalculator.new(
      material: "copper", area: 1.0, thickness: 0.01, temp_difference: -50
    ).call
    assert result[:valid]
    assert result[:heat_transfer_rate_w] < 0
  end

  test "errors accessor starts empty" do
    calc = Physics::HeatTransferCalculator.new(
      material: "copper", area: 1.0, thickness: 0.01, temp_difference: 50
    )
    assert_equal [], calc.errors
  end
end
