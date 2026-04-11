require "test_helper"

class Gardening::CalculatorsControllerTest < ActionDispatch::IntegrationTest
  CALCULATOR_PATHS = [
    [ :gardening_mulch_path, /Mulch Calculator/ ],
    [ :gardening_topsoil_path, /Topsoil Calculator/ ],
    [ :gardening_raised_bed_soil_path, /Raised Bed Soil Calculator/ ],
    [ :gardening_compost_path, /Compost Calculator/ ],
    [ :gardening_fertilizer_path, /Fertilizer Calculator/ ],
    [ :gardening_grass_seed_path, /Grass Seed Calculator/ ],
    [ :gardening_lawn_watering_path, /Lawn Watering Calculator/ ],
    [ :gardening_plant_spacing_path, /Plant Spacing Calculator/ ],
    [ :gardening_growing_degree_days_path, /Growing Degree Days Calculator/ ],
    [ :gardening_tree_age_path, /Tree Age Calculator/ ],
    [ :gardening_greenhouse_heater_path, /Greenhouse Heater/ ],
    [ :gardening_compost_ratio_path, /Compost C:N Ratio Calculator/ ]
  ].freeze

  CALCULATOR_PATHS.each do |helper, heading|
    test "GET #{helper} renders successfully" do
      get send(helper)
      assert_response :success
      assert_select "h1", heading
    end
  end
end
