require "test_helper"

class Construction::SidingCalculatorTest < ActiveSupport::TestCase
  test "basic wall minus openings" do
    result = Construction::SidingCalculator.new(
      wall_length_ft: 120, wall_height_ft: 9,
      windows: 10, doors: 2, waste_pct: 10
    ).call
    assert_equal true, result[:valid]
    # wall = 1080, openings = 10*15 + 2*21 = 192, net = 888
    # with waste = 976.8, squares = 9.77
    assert_in_delta 1080.0, result[:wall_area_sqft], 0.01
    assert_in_delta 192.0, result[:openings_area_sqft], 0.01
    assert_in_delta 888.0, result[:net_area_sqft], 0.01
    assert_in_delta 9.77, result[:squares], 0.1
  end

  test "adds gable area" do
    result = Construction::SidingCalculator.new(
      wall_length_ft: 100, wall_height_ft: 10,
      gable_length_ft: 30, gable_height_ft: 8,
      waste_pct: 0
    ).call
    # wall = 1000, gable = 0.5*30*8 = 120, gross = 1120
    assert_in_delta 120.0, result[:gable_area_sqft], 0.01
    assert_in_delta 1120.0, result[:gross_area_sqft], 0.01
  end

  test "net area floors at zero" do
    result = Construction::SidingCalculator.new(
      wall_length_ft: 10, wall_height_ft: 10,
      windows: 20, doors: 10
    ).call
    assert_equal 0.0, result[:net_area_sqft]
  end

  test "zero wall errors" do
    result = Construction::SidingCalculator.new(
      wall_length_ft: 0, wall_height_ft: 10
    ).call
    assert_equal false, result[:valid]
  end
end
