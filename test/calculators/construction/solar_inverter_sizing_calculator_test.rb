require "test_helper"

class Construction::SolarInverterSizingCalculatorTest < ActiveSupport::TestCase
  test "24 × 400 W panels at 1.20 DC/AC ratio" do
    result = Construction::SolarInverterSizingCalculator.new(
      panel_watts: 400, panel_count: 24, dc_ac_ratio: 1.20, ac_voltage: 240
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # Array = 400 × 24 = 9600 W DC
    assert_equal 9600, result[:array_dc_watts]
    assert_in_delta 9.6, result[:array_dc_kw], 0.001
    # Inverter = 9600 / 1.2 = 8000 W AC
    assert_in_delta 8000, result[:inverter_ac_watts], 1
    assert_in_delta 8.0, result[:inverter_ac_kw], 0.01
  end

  test "inverter amps at 240 V" do
    result = Construction::SolarInverterSizingCalculator.new(
      panel_watts: 400, panel_count: 24, dc_ac_ratio: 1.20, ac_voltage: 240
    ).call
    # 8000 W / 240 V = 33.3 A
    assert_in_delta 33.3, result[:inverter_max_amps], 0.1
    # 33.3 × 1.25 = 41.67 A → round up to 50 A breaker
    assert_equal 50, result[:recommended_breaker]
  end

  test "higher DC/AC ratio reduces inverter size" do
    low = Construction::SolarInverterSizingCalculator.new(panel_watts: 400, panel_count: 20, dc_ac_ratio: 1.10).call
    high = Construction::SolarInverterSizingCalculator.new(panel_watts: 400, panel_count: 20, dc_ac_ratio: 1.40).call
    assert high[:inverter_ac_kw] < low[:inverter_ac_kw]
  end

  test "more panels increases array size" do
    small = Construction::SolarInverterSizingCalculator.new(panel_watts: 400, panel_count: 10).call
    big = Construction::SolarInverterSizingCalculator.new(panel_watts: 400, panel_count: 30).call
    assert big[:array_dc_kw] > small[:array_dc_kw]
  end

  test "NEC 125% breaker sizing rule" do
    result = Construction::SolarInverterSizingCalculator.new(
      panel_watts: 400, panel_count: 20, ac_voltage: 240
    ).call
    # 8000/1.2=6667 W / 240 = 27.77 A × 1.25 = 34.72 → 40 A breaker
    assert_equal 40, result[:recommended_breaker]
  end

  test "error when panel count is zero" do
    result = Construction::SolarInverterSizingCalculator.new(panel_watts: 400, panel_count: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Panel count must be at least 1"
  end

  test "error when DC/AC ratio out of range" do
    result = Construction::SolarInverterSizingCalculator.new(panel_watts: 400, panel_count: 10, dc_ac_ratio: 0.9).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "DC/AC ratio must be between 1.0 and 1.5"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::SolarInverterSizingCalculator.new(panel_watts: 400, panel_count: 24)
    assert_equal [], calc.errors
  end
end
