require "test_helper"

class Geography::CoordinateDistanceCalculatorTest < ActiveSupport::TestCase
  test "NYC to London is about 5570 km" do
    result = Geography::CoordinateDistanceCalculator.new(
      lat1: 40.7128, lon1: -74.0060,
      lat2: 51.5074, lon2: -0.1278
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 5570, result[:distance_km], 30
    assert_in_delta 3461, result[:distance_miles], 20
    assert_in_delta 3008, result[:distance_nautical_miles], 20
  end

  test "same point returns zero distance" do
    result = Geography::CoordinateDistanceCalculator.new(
      lat1: 40.0, lon1: -74.0, lat2: 40.0, lon2: -74.0
    ).call
    assert_equal 0.0, result[:distance_km]
  end

  test "nautical miles is 0.539957 of km" do
    result = Geography::CoordinateDistanceCalculator.new(
      lat1: 0, lon1: 0, lat2: 0, lon2: 1
    ).call
    assert_in_delta result[:distance_km] * 0.539957, result[:distance_nautical_miles], 0.01
  end

  test "invalid latitude returns errors" do
    result = Geography::CoordinateDistanceCalculator.new(
      lat1: 95, lon1: 0, lat2: 0, lon2: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Latitude 1 must be between -90 and 90"
  end

  test "invalid longitude returns errors" do
    result = Geography::CoordinateDistanceCalculator.new(
      lat1: 0, lon1: -200, lat2: 0, lon2: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Longitude 1 must be between -180 and 180"
  end

  test "string inputs are coerced" do
    result = Geography::CoordinateDistanceCalculator.new(
      lat1: "40.7128", lon1: "-74.0060",
      lat2: "51.5074", lon2: "-0.1278"
    ).call
    assert_equal true, result[:valid]
    assert result[:distance_km] > 5000
  end
end
