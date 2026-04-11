require "test_helper"

class Geography::LatitudeLongitudeConverterTest < ActiveSupport::TestCase
  test "dms to decimal for NYC" do
    result = Geography::LatitudeLongitudeConverter.new(
      lat_deg: 40, lat_min: 42, lat_sec: 46, lat_hemi: "N",
      lon_deg: 74, lon_min: 0, lon_sec: 21.6, lon_hemi: "W",
      mode: "dms_to_decimal"
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 40.7128, result[:decimal_lat], 0.001
    assert_in_delta(-74.0060, result[:decimal_lon], 0.001)
  end

  test "southern and western hemispheres are negative" do
    result = Geography::LatitudeLongitudeConverter.new(
      lat_deg: 33, lat_min: 52, lat_sec: 0, lat_hemi: "S",
      lon_deg: 151, lon_min: 12, lon_sec: 0, lon_hemi: "E",
      mode: "dms_to_decimal"
    ).call
    assert_equal true, result[:valid]
    assert result[:decimal_lat] < 0
    assert result[:decimal_lon] > 0
  end

  test "decimal to dms" do
    result = Geography::LatitudeLongitudeConverter.new(
      decimal_lat: 40.7128, decimal_lon: -74.0060,
      mode: "decimal_to_dms"
    ).call
    assert_equal true, result[:valid]
    assert_equal 40, result[:lat_deg]
    assert_equal 42, result[:lat_min]
    assert_equal "N", result[:lat_hemi]
    assert_equal "W", result[:lon_hemi]
  end

  test "invalid decimal latitude returns errors" do
    result = Geography::LatitudeLongitudeConverter.new(
      decimal_lat: 95, decimal_lon: 0, mode: "decimal_to_dms"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Decimal latitude must be between -90 and 90"
  end

  test "invalid dms minutes returns errors" do
    result = Geography::LatitudeLongitudeConverter.new(
      lat_deg: 40, lat_min: 70, lat_sec: 0, lat_hemi: "N",
      lon_deg: 74, lon_min: 0, lon_sec: 0, lon_hemi: "W",
      mode: "dms_to_decimal"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Latitude minutes must be between 0 and 59"
  end
end
