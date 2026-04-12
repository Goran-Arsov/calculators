require "test_helper"

class Construction::SolarPanelLayoutCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "12m x 8m roof in portrait produces valid results" do
    result = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 12, roof_width_m: 8
    ).call
    assert_equal true, result[:valid]
    assert result[:total_panels] > 0
    assert result[:capacity_kw] > 0
    assert result[:annual_kwh] > 0
  end

  test "portrait orientation calculates correct panel count" do
    result = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 10, roof_width_m: 8.5, panel_orientation: "portrait"
    ).call
    # Portrait: panel 1.0m wide x 1.7m tall
    # Along length: floor(10 / 1.0) = 10
    # Along width: floor(8.5 / 1.7) = 5
    assert_equal 10, result[:panels_along_length]
    assert_equal 5, result[:panels_along_width]
    assert_equal 50, result[:total_panels]
  end

  test "landscape orientation calculates correct panel count" do
    result = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 10, roof_width_m: 8.5, panel_orientation: "landscape"
    ).call
    # Landscape: panel 1.7m wide x 1.0m tall
    # Along length: floor(10 / 1.7) = 5
    # Along width: floor(8.5 / 1.0) = 8
    assert_equal 5, result[:panels_along_length]
    assert_equal 8, result[:panels_along_width]
    assert_equal 40, result[:total_panels]
  end

  test "capacity calculated correctly" do
    result = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 10, roof_width_m: 8.5
    ).call
    # 50 panels x 400W / 1000 = 20.0 kW
    assert_equal 20.0, result[:capacity_kw]
  end

  test "annual kWh calculated with efficiency factor" do
    result = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 10, roof_width_m: 8.5, peak_sun_hours: 5.0
    ).call
    # 20 kW x 5.0 hours x 365 days x 0.80 = 29,200
    assert_equal 29_200, result[:annual_kwh]
  end

  test "coverage percentage calculated correctly" do
    result = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 10, roof_width_m: 8.5
    ).call
    # Panel area: 50 * 1.7 = 85 m2
    # Roof area: 10 * 8.5 = 85 m2
    assert_equal 85.0, result[:panel_area_m2]
    assert_equal 85.0, result[:roof_area_m2]
    assert_equal 100.0, result[:coverage_pct]
  end

  test "different peak sun hours changes annual output" do
    result_low = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 10, roof_width_m: 8.5, peak_sun_hours: 3.0
    ).call
    result_high = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 10, roof_width_m: 8.5, peak_sun_hours: 6.0
    ).call
    assert result_high[:annual_kwh] > result_low[:annual_kwh]
  end

  test "small roof produces fewer panels" do
    result = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 3, roof_width_m: 2
    ).call
    # Along length: floor(3/1.0) = 3, Along width: floor(2/1.7) = 1
    assert_equal 3, result[:total_panels]
  end

  # --- Validation errors ---

  test "error when roof length is zero" do
    result = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 0, roof_width_m: 8
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Roof length must be greater than zero"
  end

  test "error when roof width is zero" do
    result = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 12, roof_width_m: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Roof width must be greater than zero"
  end

  test "error when peak sun hours is zero" do
    result = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 12, roof_width_m: 8, peak_sun_hours: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Peak sun hours must be greater than zero"
  end

  test "error when orientation is invalid" do
    result = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 12, roof_width_m: 8, panel_orientation: "diagonal"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Panel orientation must be portrait or landscape"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::SolarPanelLayoutCalculator.new(
      roof_length_m: 12, roof_width_m: 8
    )
    assert_equal [], calc.errors
  end
end
