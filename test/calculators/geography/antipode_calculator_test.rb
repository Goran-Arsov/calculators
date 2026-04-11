require "test_helper"

class Geography::AntipodeCalculatorTest < ActiveSupport::TestCase
  test "antipode of NYC is in Indian Ocean" do
    result = Geography::AntipodeCalculator.new(lat: 40.7128, lon: -74.0060).call
    assert_equal true, result[:valid]
    assert_in_delta(-40.7128, result[:antipode_lat], 0.0001)
    assert_in_delta 105.994, result[:antipode_lon], 0.001
    assert_equal "S", result[:hemisphere_lat]
    assert_equal "E", result[:hemisphere_lon]
  end

  test "antipode of equator zero is opposite meridian" do
    result = Geography::AntipodeCalculator.new(lat: 0, lon: 0).call
    assert_in_delta 0.0, result[:antipode_lat], 0.0001
    assert_in_delta 180.0, result[:antipode_lon], 0.0001
  end

  test "antipode of north pole is south pole" do
    result = Geography::AntipodeCalculator.new(lat: 90, lon: 0).call
    assert_in_delta(-90.0, result[:antipode_lat], 0.0001)
  end

  test "longitude wrap works for east hemisphere input" do
    result = Geography::AntipodeCalculator.new(lat: 0, lon: 90).call
    assert_in_delta(-90.0, result[:antipode_lon], 0.0001)
  end

  test "longitude wrap works for negative wrap-around" do
    result = Geography::AntipodeCalculator.new(lat: 0, lon: -90).call
    assert_in_delta 90.0, result[:antipode_lon], 0.0001
  end

  test "invalid latitude returns errors" do
    result = Geography::AntipodeCalculator.new(lat: 95, lon: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Latitude must be between -90 and 90"
  end
end
