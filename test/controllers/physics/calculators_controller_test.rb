require "test_helper"

module Physics
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    test "should get velocity" do
      get physics_velocity_url
      assert_response :success
      assert_select "h1", /Velocity Calculator/
    end

    test "should get force" do
      get physics_force_url
      assert_response :success
      assert_select "h1", /Force Calculator/
    end

    test "should get kinetic_energy" do
      get physics_kinetic_energy_url
      assert_response :success
      assert_select "h1", /Kinetic Energy Calculator/
    end

    test "should get ohms_law" do
      get physics_ohms_law_url
      assert_response :success
      assert_select "h1", /Ohm's Law Calculator/
    end

    test "should get projectile_motion" do
      get physics_projectile_motion_url
      assert_response :success
      assert_select "h1", /Projectile Motion Calculator/
    end

    test "should get element_mass" do
      get physics_element_mass_url
      assert_response :success
      assert_select "h1", /Element Mass Calculator/
    end

    test "should get element_volume" do
      get physics_element_volume_url
      assert_response :success
      assert_select "h1", /Element Volume Calculator/
    end

    test "should get unit_converter" do
      get physics_unit_converter_url
      assert_response :success
      assert_select "h1", /Unit Converter/
    end

    test "should get electricity_cost" do
      get physics_electricity_cost_url
      assert_response :success
      assert_select "h1", /Electricity Cost Calculator/
    end

    test "should get wire_gauge" do
      get physics_wire_gauge_url
      assert_response :success
      assert_select "h1", /Wire Gauge Calculator/
    end

    test "should get decibel" do
      get physics_decibel_url
      assert_response :success
      assert_select "h1", /Decibel.*Calculator/
    end

    test "should get wavelength_frequency" do
      get physics_wavelength_frequency_url
      assert_response :success
      assert_select "h1", /Wavelength/
    end

    test "should get planet_weight" do
      get physics_planet_weight_url
      assert_response :success
      assert_select "h1", /Planet Weight/
    end
  end
end
