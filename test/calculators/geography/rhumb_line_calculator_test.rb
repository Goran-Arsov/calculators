require "test_helper"

class Geography::RhumbLineCalculatorTest < ActiveSupport::TestCase
  test "NYC to London rhumb line is longer than great-circle" do
    rhumb = Geography::RhumbLineCalculator.new(
      lat1: 40.7128, lon1: -74.0060, lat2: 51.5074, lon2: -0.1278
    ).call
    great_circle = Geography::CoordinateDistanceCalculator.new(
      lat1: 40.7128, lon1: -74.0060, lat2: 51.5074, lon2: -0.1278
    ).call
    assert_equal true, rhumb[:valid]
    assert rhumb[:distance_km] > great_circle[:distance_km]
    assert rhumb[:distance_km] < great_circle[:distance_km] * 1.10
  end

  test "due east at equator returns 90 degree bearing" do
    result = Geography::RhumbLineCalculator.new(
      lat1: 0, lon1: 0, lat2: 0, lon2: 10
    ).call
    assert_in_delta 90.0, result[:bearing], 0.01
    assert_equal "E", result[:compass]
  end

  test "due north along meridian returns 0 degree bearing" do
    result = Geography::RhumbLineCalculator.new(
      lat1: 0, lon1: 0, lat2: 10, lon2: 0
    ).call
    assert_in_delta 0.0, result[:bearing], 0.01
    assert_equal "N", result[:compass]
  end

  test "antimeridian crossing uses shortest path" do
    result = Geography::RhumbLineCalculator.new(
      lat1: 0, lon1: 170, lat2: 0, lon2: -170
    ).call
    # Should go east 20° rather than west 340°
    assert result[:distance_km] < 5000
  end

  test "invalid latitude returns errors" do
    result = Geography::RhumbLineCalculator.new(
      lat1: 95, lon1: 0, lat2: 0, lon2: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Latitude 1 must be between -90 and 90"
  end
end
