require "test_helper"

class RefactoredCalcsRenderTest < ActionDispatch::IntegrationTest
  REFACTORED = [
    [:alcohol, %w[hydrometer_correction ibu priming_sugar srm yeast_pitch]],
    [:automotive, %w[ev_charging_cost ev_vs_gas_comparison oil_change_interval towing_capacity zero_to_sixty]],
    [:construction, %w[attic_ventilation baseboard bathroom_remodel beam_load_span brick_block cabinet_door carpet concrete concrete_mix deck drainage_slope drywall fence flooring gravel_mulch grout gutter hvac_btu insulation kitchen_remodel lumber paint pool_volume rebar_spacing retaining_wall roofing septic_tank_size siding solar_panel_layout sqft_cost staircase tile wallpaper water_heater_sizing wood_moisture wood_shrinkage wood_weight]],
    [:cooking, %w[meat_cooking_time smoke_time]],
    [:health, %w[running_pace_zone]],
    [:pets, %w[cat_food fish_tank horse_feed pet_medication_dosage puppy_weight_predictor]]
  ].freeze

  REFACTORED.each do |category, calcs|
    calcs.each do |calc|
      test "#{category}/#{calc} renders 200" do
        helper = "#{category}_#{calc}_path"
        path = send(helper)
        get path
        assert_response :success, "#{category}/#{calc} at #{path} did not render 200 (got #{response.status})"
        assert_match(/unitSystem|unit-system|Unit/i, response.body, "#{calc} should mention a unit system in response body")
      end
    end
  end
end
