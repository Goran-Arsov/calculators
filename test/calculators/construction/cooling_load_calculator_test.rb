require "test_helper"

class Construction::CoolingLoadCalculatorTest < ActiveSupport::TestCase
  BASE = {
    wall_area_sqft: 1200, wall_r: 13,
    roof_area_sqft: 1500, roof_r: 38,
    window_area_sqft: 150, window_u: 0.35, window_shgc: 0.4, window_orientation: "w",
    floor_area_sqft: 1500,
    people: 4, lighting_watts: 500,
    indoor_f: 75, outdoor_f: 95,
    infiltration_cfm: 100
  }

  test "basic whole-house calculation" do
    result = Construction::CoolingLoadCalculator.new(**BASE).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:total_btu_hr] > 0
    assert result[:tons] > 0
    assert_equal 20.0, result[:dt_f]
  end

  test "tons equals BTU/hr ÷ 12000" do
    result = Construction::CoolingLoadCalculator.new(**BASE).call
    assert_in_delta result[:total_btu_hr] / 12_000.0, result[:tons], 0.02
  end

  test "west-facing windows have more solar gain than north" do
    w = Construction::CoolingLoadCalculator.new(**BASE.merge(window_orientation: "w")).call
    n = Construction::CoolingLoadCalculator.new(**BASE.merge(window_orientation: "n")).call
    assert w[:solar_windows_btu_hr] > n[:solar_windows_btu_hr]
  end

  test "more people increases latent + sensible load" do
    r4 = Construction::CoolingLoadCalculator.new(**BASE.merge(people: 4)).call
    r10 = Construction::CoolingLoadCalculator.new(**BASE.merge(people: 10)).call
    assert r10[:people_btu_hr] > r4[:people_btu_hr]
    assert r10[:total_btu_hr] > r4[:total_btu_hr]
  end

  test "better insulation reduces conduction gain" do
    poor = Construction::CoolingLoadCalculator.new(**BASE.merge(wall_r: 11, roof_r: 19)).call
    good = Construction::CoolingLoadCalculator.new(**BASE.merge(wall_r: 21, roof_r: 49)).call
    assert good[:total_btu_hr] < poor[:total_btu_hr]
  end

  test "error when outdoor not greater than indoor" do
    result = Construction::CoolingLoadCalculator.new(**BASE.merge(indoor_f: 80, outdoor_f: 70)).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Outdoor temperature must be greater than indoor"
  end

  test "error for invalid orientation" do
    result = Construction::CoolingLoadCalculator.new(**BASE.merge(window_orientation: "ne")).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Window orientation must be n, s, e, or w"
  end

  test "error for SHGC out of range" do
    result = Construction::CoolingLoadCalculator.new(**BASE.merge(window_shgc: 1.5)).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Window SHGC must be between 0 and 1"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::CoolingLoadCalculator.new(**BASE)
    assert_equal [], calc.errors
  end
end
