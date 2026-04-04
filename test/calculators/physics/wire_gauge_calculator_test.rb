require "test_helper"

class Physics::WireGaugeCalculatorTest < ActiveSupport::TestCase
  test "AWG 10" do
    result = Physics::WireGaugeCalculator.new(gauge: "10").call
    assert result[:valid]
    assert_equal 2.588, result[:diameter_mm]
    assert_equal 5.261, result[:area_mm2]
    assert_equal 3.277, result[:resistance_ohm_per_km]
    assert_equal 15, result[:ampacity_a]
  end

  test "AWG 0000" do
    result = Physics::WireGaugeCalculator.new(gauge: "0000").call
    assert result[:valid]
    assert_equal 11.684, result[:diameter_mm]
    assert_equal 302, result[:ampacity_a]
  end

  test "AWG 40 smallest" do
    result = Physics::WireGaugeCalculator.new(gauge: "40").call
    assert result[:valid]
    assert_equal 0.0799, result[:diameter_mm]
  end

  test "includes inch conversion" do
    result = Physics::WireGaugeCalculator.new(gauge: "12").call
    assert result[:valid]
    assert_in_delta(2.053 / 25.4, result[:diameter_in], 0.001)
  end

  test "unknown gauge returns error" do
    result = Physics::WireGaugeCalculator.new(gauge: "99").call
    refute result[:valid]
    assert_includes result[:errors], "Unknown AWG gauge: 99"
  end

  test "errors accessor" do
    calc = Physics::WireGaugeCalculator.new(gauge: "10")
    assert_equal [], calc.errors
  end
end
