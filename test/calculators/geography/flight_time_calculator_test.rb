require "test_helper"

class Geography::FlightTimeCalculatorTest < ActiveSupport::TestCase
  test "JFK to LHR commercial jet is roughly 6-7 hours total" do
    result = Geography::FlightTimeCalculator.new(
      lat1: 40.6413, lon1: -73.7781,
      lat2: 51.4700, lon2: -0.4543,
      aircraft: "commercial_jet"
    ).call
    assert_equal true, result[:valid]
    assert result[:total_hours].between?(6, 7)
    assert_equal 900, result[:cruise_speed_kph]
  end

  test "distance is great-circle haversine" do
    result = Geography::FlightTimeCalculator.new(
      lat1: 40.6413, lon1: -73.7781,
      lat2: 51.4700, lon2: -0.4543,
      aircraft: "commercial_jet"
    ).call
    assert_in_delta 5540, result[:distance_km], 50
  end

  test "turboprop is much slower than commercial jet" do
    jet = Geography::FlightTimeCalculator.new(
      lat1: 0, lon1: 0, lat2: 0, lon2: 10, aircraft: "commercial_jet"
    ).call
    prop = Geography::FlightTimeCalculator.new(
      lat1: 0, lon1: 0, lat2: 0, lon2: 10, aircraft: "turboprop"
    ).call
    assert prop[:total_hours] > jet[:total_hours]
  end

  test "explicit distance_km bypasses coordinates" do
    result = Geography::FlightTimeCalculator.new(
      distance_km: 900, cruise_speed_kph: 900, taxi_minutes: 0
    ).call
    assert_in_delta 1.0, result[:total_hours], 0.001
  end

  test "taxi minutes are added to total" do
    no_taxi = Geography::FlightTimeCalculator.new(
      distance_km: 900, cruise_speed_kph: 900, taxi_minutes: 0
    ).call
    with_taxi = Geography::FlightTimeCalculator.new(
      distance_km: 900, cruise_speed_kph: 900, taxi_minutes: 30
    ).call
    assert_in_delta 0.5, with_taxi[:total_hours] - no_taxi[:total_hours], 0.001
  end

  test "missing coords without distance returns error" do
    result = Geography::FlightTimeCalculator.new(cruise_speed_kph: 900).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Provide either distance_km or all four coordinates"
  end

  test "zero cruise speed returns error" do
    result = Geography::FlightTimeCalculator.new(
      distance_km: 1000, cruise_speed_kph: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Cruise speed must be greater than zero"
  end
end
