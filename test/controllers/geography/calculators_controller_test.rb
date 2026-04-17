require "test_helper"

module Geography
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    {
      coordinate_distance: :geography_coordinate_distance_url,
      latitude_longitude_converter: :geography_latitude_longitude_converter_url,
      bearing: :geography_bearing_url,
      midpoint: :geography_midpoint_url,
      map_scale: :geography_map_scale_url,
      population_density: :geography_population_density_url,
      destination_point: :geography_destination_point_url,
      antipode: :geography_antipode_url,
      rhumb_line: :geography_rhumb_line_url,
      polygon_area: :geography_polygon_area_url,
      hiking_time: :geography_hiking_time_url,
      geohash: :geography_geohash_url,
      degrees_to_kilometers: :geography_degrees_to_kilometers_url,
      flight_time: :geography_flight_time_url
    }.each do |action, url_helper|
      test "should get #{action}" do
        get send(url_helper)
        assert_response :success
        assert_select "h1"
      end
    end
  end
end
