require "test_helper"

class RefactoredCalcsRenderTest < ActionDispatch::IntegrationTest
  REFACTORED = [
    [ :alcohol, %w[hydrometer_correction ibu priming_sugar srm yeast_pitch] ],
    [ :automotive, %w[ev_charging_cost ev_vs_gas_comparison oil_change_interval towing_capacity zero_to_sixty] ],
    [ :construction, %w[air_change_rate asphalt attic_ventilation baseboard bathroom_remodel battery_backup_runtime beam_load_span board_foot brick_block cabinet_door carpet caulk chimney_flue concrete concrete_mix conduit_fill cooling_load crown_molding deck dehumidifier_sizing drainage_slope drywall drywall_screws duct_size erv_hrv_ventilation excavation fence flooring generator_sizing gravel_mulch grout gutter heat_loss heat_pump_capacity heating_cost hvac_btu insulation joist kitchen_remodel lumber paint paver pipe_friction_loss plumbing plywood_sheets pool_volume psychrometric radiant_floor_heat radiator_btu rafter_length rebar_spacing retaining_wall roof_pitch roofing seer_eer_hspf septic_tank_size siding snow_melt_btu solar_inverter_sizing solar_panel_layout spread_footing sqft_cost staircase static_pressure stud_count tile voltage_drop wallpaper water_heater_sizing wire_ampacity wood_moisture wood_shrinkage wood_weight] ],
    [ :cooking, %w[meat_cooking_time smoke_time] ],
    [ :health, %w[alcohol_burnoff running_pace_zone] ],
    [ :pets, %w[cat_food fish_tank horse_feed pet_medication_dosage puppy_weight_predictor] ]
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
