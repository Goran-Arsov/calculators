require "test_helper"

class Construction::ElectricalLoadCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic 2000 sqft home produces valid results" do
    result = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000
    ).call
    assert_equal true, result[:valid]
    assert result[:general_lighting_watts] > 0
    assert result[:total_load_watts] > 0
    assert result[:total_amps_240v] > 0
    assert result[:recommended_panel_amps] > 0
  end

  test "general lighting is 3 watts per sqft" do
    result = Construction::ElectricalLoadCalculator.new(
      square_footage: 1000
    ).call
    assert_equal 3000, result[:general_lighting_watts]
  end

  test "demand factor applied correctly" do
    result = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000
    ).call
    # General lighting = 6000W
    # General load = 6000 + 3000 + 1500 = 10500W
    # Demand: 3000 + (10500 - 3000)*0.35 = 3000 + 2625 = 5625W
    assert_equal 5625, result[:total_load_watts]
  end

  test "electric range adds 8000W" do
    result_no = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, has_electric_range: false
    ).call
    result_yes = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, has_electric_range: true
    ).call
    assert_equal 8000, result_yes[:total_load_watts] - result_no[:total_load_watts]
  end

  test "electric dryer adds 5000W" do
    result_no = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, has_electric_dryer: false
    ).call
    result_yes = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, has_electric_dryer: true
    ).call
    assert_equal 5000, result_yes[:total_load_watts] - result_no[:total_load_watts]
  end

  test "electric water heater adds 4500W" do
    result_no = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, has_electric_water_heater: false
    ).call
    result_yes = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, has_electric_water_heater: true
    ).call
    assert_equal 4500, result_yes[:total_load_watts] - result_no[:total_load_watts]
  end

  test "uses larger of AC or heat not both" do
    result_ac = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, ac_tons: 3, has_electric_heat: false
    ).call
    result_heat = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, ac_tons: 0, has_electric_heat: true
    ).call
    result_both = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, ac_tons: 3, has_electric_heat: true
    ).call
    # Heat = 2000 * 10 = 20000W, AC = 3 * 3517 = 10551W
    # With both, should use heat (20000) since it's larger
    assert_equal result_heat[:total_load_watts], result_both[:total_load_watts]
  end

  test "panel sizing 100A" do
    result = Construction::ElectricalLoadCalculator.new(
      square_footage: 1000
    ).call
    # Low load should get 100A panel
    assert_equal 100, result[:recommended_panel_amps]
  end

  test "panel sizing 200A for full house" do
    result = Construction::ElectricalLoadCalculator.new(
      square_footage: 2500, has_electric_range: true, has_electric_dryer: true,
      has_electric_water_heater: true, ac_tons: 3
    ).call
    assert [150, 200].include?(result[:recommended_panel_amps])
  end

  test "total amps calculated at 240V" do
    result = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000
    ).call
    expected_amps = (result[:total_load_watts] / 240.0).round(1)
    assert_equal expected_amps, result[:total_amps_240v]
  end

  # --- Validation errors ---

  test "error when square footage is zero" do
    result = Construction::ElectricalLoadCalculator.new(square_footage: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Square footage must be greater than zero"
  end

  test "error when AC tons negative" do
    result = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, ac_tons: -1
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "AC tons cannot be negative"
  end

  test "error when AC tons exceeds 5" do
    result = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, ac_tons: 6
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "AC tons cannot exceed 5"
  end

  test "boolean inputs handle string values" do
    result = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, has_electric_range: "true"
    ).call
    assert_equal true, result[:valid]
    # Should include range watts
    result_no = Construction::ElectricalLoadCalculator.new(
      square_footage: 2000, has_electric_range: "false"
    ).call
    assert result[:total_load_watts] > result_no[:total_load_watts]
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::ElectricalLoadCalculator.new(square_footage: 2000)
    assert_equal [], calc.errors
  end
end
