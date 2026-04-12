require "test_helper"

class Cooking::CanningAltitudeCalculatorTest < ActiveSupport::TestCase
  test "happy path: water bath at sea level" do
    calc = Cooking::CanningAltitudeCalculator.new(
      altitude_ft: 500, base_processing_time: 20, canning_method: "water_bath"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 20, result[:adjusted_processing_time]
    assert_equal 0, result[:extra_minutes]
  end

  test "happy path: water bath at 5000 ft" do
    calc = Cooking::CanningAltitudeCalculator.new(
      altitude_ft: 5000, base_processing_time: 20, canning_method: "water_bath"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 30, result[:adjusted_processing_time]
    assert_equal 10, result[:extra_minutes]
  end

  test "happy path: water bath at 8000 ft" do
    calc = Cooking::CanningAltitudeCalculator.new(
      altitude_ft: 8000, base_processing_time: 15, canning_method: "water_bath"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 30, result[:adjusted_processing_time]
    assert_equal 15, result[:extra_minutes]
  end

  test "happy path: pressure dial at 3000 ft" do
    calc = Cooking::CanningAltitudeCalculator.new(
      altitude_ft: 3000, base_processing_time: 25, canning_method: "pressure_dial", base_pressure: 10
    )
    result = calc.call

    assert result[:valid]
    assert_equal 12, result[:adjusted_pressure]
    assert_equal 2, result[:extra_psi]
    assert_equal 25, result[:adjusted_processing_time]
  end

  test "happy path: pressure weighted above 1000 ft" do
    calc = Cooking::CanningAltitudeCalculator.new(
      altitude_ft: 2500, base_processing_time: 25, canning_method: "pressure_weighted"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 15, result[:adjusted_pressure]
  end

  test "happy path: pressure weighted below 1000 ft" do
    calc = Cooking::CanningAltitudeCalculator.new(
      altitude_ft: 500, base_processing_time: 25, canning_method: "pressure_weighted"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 10, result[:adjusted_pressure]
  end

  test "negative altitude returns error" do
    calc = Cooking::CanningAltitudeCalculator.new(
      altitude_ft: -100, base_processing_time: 20, canning_method: "water_bath"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Altitude must be non-negative"
  end

  test "altitude over 10000 returns error" do
    calc = Cooking::CanningAltitudeCalculator.new(
      altitude_ft: 15000, base_processing_time: 20, canning_method: "water_bath"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Altitude must be 10,000 feet or less"
  end

  test "zero processing time returns error" do
    calc = Cooking::CanningAltitudeCalculator.new(
      altitude_ft: 5000, base_processing_time: 0, canning_method: "water_bath"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Base processing time must be positive"
  end

  test "unknown method returns error" do
    calc = Cooking::CanningAltitudeCalculator.new(
      altitude_ft: 5000, base_processing_time: 20, canning_method: "unknown"
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.any? { |e| e.include?("Unknown canning method") }
  end
end
