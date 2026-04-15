require "test_helper"

class Construction::RadiatorBtuCalculatorTest < ActiveSupport::TestCase
  test "panel radiator at rated conditions gives rated output" do
    # rated dT for panel = 90 °F. Supply 160, return 110, room 70 → mean 135 → dT 65.
    # Actually let's do the exact rating condition: mean water = 90+room = 160 → supply=170 return=150
    result = Construction::RadiatorBtuCalculator.new(
      rated_btu_hr: 5000, radiator_type: "panel",
      supply_water_f: 180, return_water_f: 140, room_temp_f: 70
    ).call
    assert_equal true, result[:valid]
    # mean = 160, dT = 90, ratio ~1.0
    assert_in_delta 5000, result[:actual_btu_hr], 50
  end

  test "lower water temperature reduces output" do
    hot = Construction::RadiatorBtuCalculator.new(
      rated_btu_hr: 5000, radiator_type: "panel",
      supply_water_f: 180, return_water_f: 160, room_temp_f: 70
    ).call
    cool = Construction::RadiatorBtuCalculator.new(
      rated_btu_hr: 5000, radiator_type: "panel",
      supply_water_f: 120, return_water_f: 100, room_temp_f: 70
    ).call
    assert cool[:actual_btu_hr] < hot[:actual_btu_hr]
  end

  test "cast iron uses n=1.45 exponent" do
    result = Construction::RadiatorBtuCalculator.new(
      rated_btu_hr: 5000, radiator_type: "cast_iron",
      supply_water_f: 180, return_water_f: 160, room_temp_f: 70
    ).call
    assert_in_delta 1.45, result[:exponent], 0.001
  end

  test "fin-tube rated dT is 115 F" do
    result = Construction::RadiatorBtuCalculator.new(
      rated_btu_hr: 600, radiator_type: "fin_tube",
      supply_water_f: 190, return_water_f: 180, room_temp_f: 70
    ).call
    assert_in_delta 115.0, result[:rated_dt_f], 0.01
  end

  test "output scales with capacity ratio ^ exponent" do
    rated = Construction::RadiatorBtuCalculator.new(
      rated_btu_hr: 5000, radiator_type: "panel",
      supply_water_f: 180, return_water_f: 140, room_temp_f: 70
    ).call
    half_dt = Construction::RadiatorBtuCalculator.new(
      rated_btu_hr: 5000, radiator_type: "panel",
      supply_water_f: 115, return_water_f: 115, room_temp_f: 70
    ).call
    # half the dT → (0.5)^1.3 ≈ 0.406 → about 2030 BTU
    assert_in_delta 2030, half_dt[:actual_btu_hr], 60
  end

  test "actual watts conversion" do
    result = Construction::RadiatorBtuCalculator.new(
      rated_btu_hr: 5000, radiator_type: "panel",
      supply_water_f: 180, return_water_f: 140, room_temp_f: 70
    ).call
    assert_in_delta result[:actual_btu_hr] / 3.412, result[:actual_watts], 1.0
  end

  test "error when supply below room temp" do
    result = Construction::RadiatorBtuCalculator.new(
      rated_btu_hr: 5000, radiator_type: "panel",
      supply_water_f: 60, return_water_f: 60, room_temp_f: 70
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Supply water temperature must be above room temperature"
  end

  test "error for unknown type" do
    result = Construction::RadiatorBtuCalculator.new(
      rated_btu_hr: 5000, radiator_type: "magic",
      supply_water_f: 180, return_water_f: 140, room_temp_f: 70
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Radiator type must be panel, cast_iron, or fin_tube"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::RadiatorBtuCalculator.new(
      rated_btu_hr: 5000, radiator_type: "panel",
      supply_water_f: 180, return_water_f: 140, room_temp_f: 70
    )
    assert_equal [], calc.errors
  end
end
