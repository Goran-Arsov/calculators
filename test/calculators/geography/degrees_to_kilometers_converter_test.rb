require "test_helper"

class Geography::DegreesToKilometersConverterTest < ActiveSupport::TestCase
  test "1 degree latitude is about 111.32 km everywhere" do
    [ 0, 30, 45, 60, 89 ].each do |lat|
      result = Geography::DegreesToKilometersConverter.new(latitude: lat, degrees: 1).call
      assert_in_delta 111.32, result[:km_per_degree_latitude], 0.01
    end
  end

  test "1 degree longitude at equator is 111.32 km" do
    result = Geography::DegreesToKilometersConverter.new(latitude: 0, degrees: 1).call
    assert_in_delta 111.32, result[:km_per_degree_longitude], 0.01
  end

  test "1 degree longitude at 60 degrees latitude is half" do
    result = Geography::DegreesToKilometersConverter.new(latitude: 60, degrees: 1).call
    # cos(60°) = 0.5
    assert_in_delta 55.66, result[:km_per_degree_longitude], 0.01
  end

  test "1 degree longitude at pole is essentially zero" do
    result = Geography::DegreesToKilometersConverter.new(latitude: 90, degrees: 1).call
    assert_in_delta 0.0, result[:km_per_degree_longitude], 0.0001
  end

  test "input degrees scaling works" do
    result = Geography::DegreesToKilometersConverter.new(latitude: 0, degrees: 5).call
    assert_in_delta 556.6, result[:input_km_latitude], 0.5
  end

  test "miles output is provided" do
    result = Geography::DegreesToKilometersConverter.new(latitude: 0, degrees: 1).call
    assert_in_delta 69.17, result[:miles_per_degree_latitude], 0.05
  end

  test "invalid latitude returns errors" do
    result = Geography::DegreesToKilometersConverter.new(latitude: 95, degrees: 1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Latitude must be between -90 and 90"
  end

  test "zero degrees returns errors" do
    result = Geography::DegreesToKilometersConverter.new(latitude: 0, degrees: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Degrees must be greater than zero"
  end
end
