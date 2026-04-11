require "test_helper"

class Geography::DestinationPointCalculatorTest < ActiveSupport::TestCase
  test "NYC + bearing 51° + 5570 km lands near London" do
    result = Geography::DestinationPointCalculator.new(
      lat: 40.7128, lon: -74.0060, bearing: 51, distance: 5570, distance_unit: "km"
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 51.5, result[:destination_lat], 1.5
    assert_in_delta(-0.1, result[:destination_lon], 1.5)
  end

  test "due north 111.32 km moves about 1 degree latitude" do
    result = Geography::DestinationPointCalculator.new(
      lat: 0, lon: 0, bearing: 0, distance: 111.32, distance_unit: "km"
    ).call
    assert_in_delta 1.0, result[:destination_lat], 0.01
    assert_in_delta 0.0, result[:destination_lon], 0.001
  end

  test "due east at equator 111.32 km moves about 1 degree longitude" do
    result = Geography::DestinationPointCalculator.new(
      lat: 0, lon: 0, bearing: 90, distance: 111.32, distance_unit: "km"
    ).call
    assert_in_delta 0.0, result[:destination_lat], 0.001
    assert_in_delta 1.0, result[:destination_lon], 0.01
  end

  test "miles unit converts correctly" do
    result_km = Geography::DestinationPointCalculator.new(
      lat: 0, lon: 0, bearing: 0, distance: 100, distance_unit: "km"
    ).call
    result_mi = Geography::DestinationPointCalculator.new(
      lat: 0, lon: 0, bearing: 0, distance: 62.1371, distance_unit: "mi"
    ).call
    assert_in_delta result_km[:destination_lat], result_mi[:destination_lat], 0.001
  end

  test "invalid bearing returns errors" do
    result = Geography::DestinationPointCalculator.new(
      lat: 0, lon: 0, bearing: 400, distance: 100, distance_unit: "km"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Bearing must be between 0 and 360"
  end

  test "invalid distance unit returns errors" do
    result = Geography::DestinationPointCalculator.new(
      lat: 0, lon: 0, bearing: 90, distance: 100, distance_unit: "foo"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Distance unit must be km, mi, nmi, or m"
  end
end
