require "test_helper"

class Construction::HeatLossCalculatorTest < ActiveSupport::TestCase
  BASE = {
    wall_area_sqft: 1200, wall_r: 13,
    roof_area_sqft: 1500, roof_r: 30,
    window_area_sqft: 150, window_u: 0.35,
    floor_area_sqft: 1500, floor_r: 19,
    volume_cuft: 12000,
    indoor_f: 70, outdoor_f: 10
  }

  test "basic whole-house calculation" do
    result = Construction::HeatLossCalculator.new(**BASE).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:total_btu_hr] > 0
    assert result[:total_watts] > 0
    assert_equal 60.0, result[:dt_f]
  end

  test "lower outdoor temperature increases heat loss" do
    warm = Construction::HeatLossCalculator.new(**BASE.merge(outdoor_f: 40)).call
    cold = Construction::HeatLossCalculator.new(**BASE.merge(outdoor_f: -10)).call
    assert cold[:total_btu_hr] > warm[:total_btu_hr]
  end

  test "better insulation reduces heat loss" do
    poor = Construction::HeatLossCalculator.new(**BASE.merge(wall_r: 11, roof_r: 19)).call
    good = Construction::HeatLossCalculator.new(**BASE.merge(wall_r: 21, roof_r: 49)).call
    assert good[:total_btu_hr] < poor[:total_btu_hr]
  end

  test "BTU to watts conversion" do
    result = Construction::HeatLossCalculator.new(**BASE).call
    assert_in_delta result[:total_btu_hr] / 3.412142, result[:total_watts], 1.0
  end

  test "net wall area excludes windows" do
    # Same wall area but zero window: wall loss should be higher
    with_window = Construction::HeatLossCalculator.new(**BASE).call
    without_window = Construction::HeatLossCalculator.new(**BASE.merge(window_area_sqft: 0.01, window_u: 0.35)).call
    assert without_window[:wall_loss_btu_hr] > with_window[:wall_loss_btu_hr]
  end

  test "infiltration contributes to total" do
    base = Construction::HeatLossCalculator.new(**BASE).call
    leaky = Construction::HeatLossCalculator.new(**BASE.merge(infiltration_ach: 1.5)).call
    assert leaky[:total_btu_hr] > base[:total_btu_hr]
  end

  test "error when indoor not greater than outdoor" do
    result = Construction::HeatLossCalculator.new(**BASE.merge(indoor_f: 50, outdoor_f: 60)).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Indoor temperature must be greater than outdoor"
  end

  test "error when wall R is zero" do
    result = Construction::HeatLossCalculator.new(**BASE.merge(wall_r: 0)).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Wall R-value must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::HeatLossCalculator.new(**BASE)
    assert_equal [], calc.errors
  end
end
