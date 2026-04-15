require "test_helper"

class Construction::PsychrometricCalculatorTest < ActiveSupport::TestCase
  test "75 F and 50% RH basic values" do
    result = Construction::PsychrometricCalculator.new(dry_bulb_f: 75, relative_humidity: 50).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:dew_point_f] > 50 && result[:dew_point_f] < 60
    assert result[:wet_bulb_f] > 55 && result[:wet_bulb_f] < 70
    assert result[:humidity_ratio_kg_kg] > 0
  end

  test "dew point below dry bulb at low humidity" do
    result = Construction::PsychrometricCalculator.new(dry_bulb_f: 90, relative_humidity: 20).call
    assert result[:dew_point_f] < result[:dry_bulb_f]
  end

  test "dew point equals dry bulb at 100 RH" do
    result = Construction::PsychrometricCalculator.new(dry_bulb_f: 70, relative_humidity: 100).call
    assert_in_delta result[:dry_bulb_f], result[:dew_point_f], 0.5
  end

  test "wet bulb lies between dew point and dry bulb" do
    result = Construction::PsychrometricCalculator.new(dry_bulb_f: 90, relative_humidity: 60).call
    assert result[:wet_bulb_f] >= result[:dew_point_f] - 0.5
    assert result[:wet_bulb_f] <= result[:dry_bulb_f] + 0.5
  end

  test "higher humidity increases vapor pressure" do
    low = Construction::PsychrometricCalculator.new(dry_bulb_f: 70, relative_humidity: 30).call
    high = Construction::PsychrometricCalculator.new(dry_bulb_f: 70, relative_humidity: 80).call
    assert high[:vapor_pressure_hpa] > low[:vapor_pressure_hpa]
  end

  test "humidity ratio conversion grains per pound" do
    result = Construction::PsychrometricCalculator.new(dry_bulb_f: 75, relative_humidity: 50).call
    # At 75 F 50% RH, humidity ratio ≈ 0.0093 kg/kg = 65 gr/lb
    assert result[:humidity_ratio_gr_lb] > 40
    assert result[:humidity_ratio_gr_lb] < 90
  end

  test "enthalpy in BTU/lb is positive at room temp" do
    result = Construction::PsychrometricCalculator.new(dry_bulb_f: 75, relative_humidity: 50).call
    assert result[:enthalpy_btu_lb] > 20
    assert result[:enthalpy_btu_lb] < 35
  end

  test "error when RH out of range" do
    result = Construction::PsychrometricCalculator.new(dry_bulb_f: 75, relative_humidity: 120).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Relative humidity must be between 0 and 100"
  end

  test "error when dry bulb too cold" do
    result = Construction::PsychrometricCalculator.new(dry_bulb_f: -50, relative_humidity: 50).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Dry bulb") }
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::PsychrometricCalculator.new(dry_bulb_f: 75, relative_humidity: 50)
    assert_equal [], calc.errors
  end
end
