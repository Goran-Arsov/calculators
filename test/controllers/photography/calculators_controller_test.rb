require "test_helper"

module Photography
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    {
      depth_of_field: :photography_depth_of_field_url,
      exposure_triangle: :photography_exposure_triangle_url,
      print_size_dpi: :photography_print_size_dpi_url,
      video_file_size: :photography_video_file_size_url,
      aspect_ratio_crop: :photography_aspect_ratio_crop_url,
      golden_hour: :photography_golden_hour_url,
      timelapse_interval: :photography_timelapse_interval_url,
      photo_storage: :photography_photo_storage_url
    }.each do |action, url_helper|
      test "should get #{action}" do
        get send(url_helper)
        assert_response :success
        assert_select "h1"
      end
    end
  end
end
