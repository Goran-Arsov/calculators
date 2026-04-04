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
  end
end
