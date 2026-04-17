require "test_helper"

module Textile
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    {
      fabric_yardage: :textile_fabric_yardage_url,
      seam_allowance: :textile_seam_allowance_url,
      knitting_gauge: :textile_knitting_gauge_url,
      crochet_gauge: :textile_crochet_gauge_url,
      needle_hook_size: :textile_needle_hook_size_url,
      yarn_yardage: :textile_yarn_yardage_url,
      quilt_backing: :textile_quilt_backing_url,
      half_square_triangle: :textile_half_square_triangle_url,
      binding_strips: :textile_binding_strips_url,
      fabric_gsm: :textile_fabric_gsm_url,
      fabric_shrinkage: :textile_fabric_shrinkage_url,
      cross_stitch_fabric: :textile_cross_stitch_fabric_url
    }.each do |action, url_helper|
      test "should get #{action}" do
        get send(url_helper)
        assert_response :success
        assert_select "h1"
      end
    end
  end
end
