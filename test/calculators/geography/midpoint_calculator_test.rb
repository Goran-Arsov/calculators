require "test_helper"

class Geography::MidpointCalculatorTest < ActiveSupport::TestCase
  test "midpoint on equator at same latitude averages longitudes" do
    result = Geography::MidpointCalculator.new(
      lat1: 0, lon1: -10, lat2: 0, lon2: 10
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 0, result[:midpoint_lat], 0.0001
    assert_in_delta 0, result[:midpoint_lon], 0.0001
  end

  test "midpoint is symmetric when swapping points" do
    a = Geography::MidpointCalculator.new(
      lat1: 40.7128, lon1: -74.0060,
      lat2: 51.5074, lon2: -0.1278
    ).call
    b = Geography::MidpointCalculator.new(
      lat1: 51.5074, lon1: -0.1278,
      lat2: 40.7128, lon2: -74.0060
    ).call
    assert_in_delta a[:midpoint_lat], b[:midpoint_lat], 0.0001
    assert_in_delta a[:midpoint_lon], b[:midpoint_lon], 0.0001
  end

  test "same point returns same point as midpoint" do
    result = Geography::MidpointCalculator.new(
      lat1: 40.7128, lon1: -74.0060,
      lat2: 40.7128, lon2: -74.0060
    ).call
    assert_in_delta 40.7128, result[:midpoint_lat], 0.001
    assert_in_delta(-74.0060, result[:midpoint_lon], 0.001)
  end

  test "invalid latitude returns errors" do
    result = Geography::MidpointCalculator.new(
      lat1: 100, lon1: 0, lat2: 0, lon2: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Latitude 1 must be between -90 and 90"
  end
end
