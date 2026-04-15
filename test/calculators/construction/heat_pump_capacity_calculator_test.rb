require "test_helper"

class Construction::HeatPumpCapacityCalculatorTest < ActiveSupport::TestCase
  test "standard HP at rated 47 F gives 100%" do
    result = Construction::HeatPumpCapacityCalculator.new(
      rated_btu_hr: 36_000, outdoor_f: 47, hp_type: "standard"
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_in_delta 1.0, result[:capacity_fraction], 0.01
    assert_in_delta 36_000, result[:actual_btu_hr], 50
  end

  test "standard HP derates at 17 F" do
    result = Construction::HeatPumpCapacityCalculator.new(
      rated_btu_hr: 36_000, outdoor_f: 17, hp_type: "standard"
    ).call
    # Standard curve at 17 F → 0.70
    assert_in_delta 0.70, result[:capacity_fraction], 0.01
    assert_in_delta 25_200, result[:actual_btu_hr], 100
    assert_in_delta 30.0, result[:derating_pct], 0.5
  end

  test "cold climate HP retains more capacity at 5 F" do
    std = Construction::HeatPumpCapacityCalculator.new(rated_btu_hr: 36_000, outdoor_f: 5, hp_type: "standard").call
    cc = Construction::HeatPumpCapacityCalculator.new(rated_btu_hr: 36_000, outdoor_f: 5, hp_type: "cold_climate").call
    assert cc[:capacity_fraction] > std[:capacity_fraction]
    assert cc[:actual_btu_hr] > std[:actual_btu_hr]
  end

  test "actual tons is BTU ÷ 12000" do
    result = Construction::HeatPumpCapacityCalculator.new(rated_btu_hr: 36_000, outdoor_f: 35).call
    assert_in_delta result[:actual_btu_hr] / 12_000.0, result[:actual_tons], 0.02
  end

  test "interpolation between data points" do
    # 30 F is between 17 and 35; fraction should be between 0.70 and 0.88
    result = Construction::HeatPumpCapacityCalculator.new(rated_btu_hr: 36_000, outdoor_f: 30).call
    assert result[:capacity_fraction] > 0.70
    assert result[:capacity_fraction] < 0.88
  end

  test "temperature above 65 clamps to 110%" do
    result = Construction::HeatPumpCapacityCalculator.new(rated_btu_hr: 36_000, outdoor_f: 90).call
    assert_in_delta 1.10, result[:capacity_fraction], 0.01
  end

  test "temperature below -25 clamps to lowest fraction" do
    result = Construction::HeatPumpCapacityCalculator.new(rated_btu_hr: 36_000, outdoor_f: -30).call
    assert_in_delta 0.15, result[:capacity_fraction], 0.01
  end

  test "error when rated BTU is zero" do
    result = Construction::HeatPumpCapacityCalculator.new(rated_btu_hr: 0, outdoor_f: 17).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Rated BTU/hr must be greater than zero"
  end

  test "error for unknown HP type" do
    result = Construction::HeatPumpCapacityCalculator.new(rated_btu_hr: 36_000, outdoor_f: 17, hp_type: "magic").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Heat pump type must be standard or cold_climate"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::HeatPumpCapacityCalculator.new(rated_btu_hr: 36_000, outdoor_f: 17)
    assert_equal [], calc.errors
  end
end
