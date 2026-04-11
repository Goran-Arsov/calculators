require "test_helper"

class Geography::GeohashConverterTest < ActiveSupport::TestCase
  test "encode NYC at precision 9 returns valid hash" do
    result = Geography::GeohashConverter.new(
      mode: "encode", lat: 40.7128, lon: -74.0060, precision: 9
    ).call
    assert_equal true, result[:valid]
    assert_equal 9, result[:geohash].length
    assert_match(/\Adr5r/, result[:geohash])
  end

  test "decode and re-encode produces stable hash" do
    encoded = Geography::GeohashConverter.new(
      mode: "encode", lat: 40.7128, lon: -74.0060, precision: 8
    ).call
    decoded = Geography::GeohashConverter.new(
      mode: "decode", geohash: encoded[:geohash]
    ).call
    re_encoded = Geography::GeohashConverter.new(
      mode: "encode", lat: decoded[:decoded_lat], lon: decoded[:decoded_lon], precision: 8
    ).call
    assert_equal encoded[:geohash], re_encoded[:geohash]
  end

  test "decoded coordinates are within precision tolerance" do
    encoded = Geography::GeohashConverter.new(
      mode: "encode", lat: 40.7128, lon: -74.0060, precision: 9
    ).call
    decoded = Geography::GeohashConverter.new(
      mode: "decode", geohash: encoded[:geohash]
    ).call
    assert_in_delta 40.7128, decoded[:decoded_lat], 0.001
    assert_in_delta(-74.0060, decoded[:decoded_lon], 0.001)
  end

  test "precision 1 returns single character" do
    result = Geography::GeohashConverter.new(
      mode: "encode", lat: 0, lon: 0, precision: 1
    ).call
    assert_equal 1, result[:geohash].length
  end

  test "invalid character in decode returns error" do
    result = Geography::GeohashConverter.new(
      mode: "decode", geohash: "abc"
    ).call
    assert_equal false, result[:valid]
    assert_match(/Invalid geohash character/, result[:errors].first)
  end

  test "invalid latitude in encode returns error" do
    result = Geography::GeohashConverter.new(
      mode: "encode", lat: 95, lon: 0, precision: 5
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Latitude must be between -90 and 90"
  end

  test "precision out of range returns error" do
    result = Geography::GeohashConverter.new(
      mode: "encode", lat: 0, lon: 0, precision: 15
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Precision must be between 1 and 12"
  end

  test "uppercase geohash decodes the same as lowercase" do
    lower = Geography::GeohashConverter.new(mode: "decode", geohash: "dr5regy3x").call
    upper = Geography::GeohashConverter.new(mode: "decode", geohash: "DR5REGY3X").call
    assert_equal lower[:decoded_lat], upper[:decoded_lat]
  end
end
