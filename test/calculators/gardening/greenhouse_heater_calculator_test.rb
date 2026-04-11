require "test_helper"

class Gardening::GreenhouseHeaterCalculatorTest < ActiveSupport::TestCase
  test "10x20x8 single poly at 40F delta" do
    result = Gardening::GreenhouseHeaterCalculator.new(
      length_ft: 20, width_ft: 10, height_ft: 8,
      desired_temp_f: 50, outside_temp_f: 10,
      glazing: "single_poly"
    ).call
    assert_equal true, result[:valid]
    # surface = 2*(20*10 + 20*8 + 10*8) = 2*(200+160+80) = 880
    assert_in_delta 880, result[:surface_area_sqft], 0.01
    assert_in_delta 40, result[:delta_t], 0.01
    assert_equal 1.15, result[:u_value]
    # btu = 880 * 40 * 1.15 = 40_480
    assert_equal 40480, result[:btu_per_hour]
  end

  test "double poly halves the heater" do
    single = Gardening::GreenhouseHeaterCalculator.new(
      length_ft: 20, width_ft: 10, height_ft: 8,
      desired_temp_f: 50, outside_temp_f: 10,
      glazing: "single_poly"
    ).call
    double = Gardening::GreenhouseHeaterCalculator.new(
      length_ft: 20, width_ft: 10, height_ft: 8,
      desired_temp_f: 50, outside_temp_f: 10,
      glazing: "double_poly"
    ).call
    assert double[:btu_per_hour] < single[:btu_per_hour]
  end

  test "desired must exceed outside" do
    result = Gardening::GreenhouseHeaterCalculator.new(
      length_ft: 10, width_ft: 10, height_ft: 8,
      desired_temp_f: 50, outside_temp_f: 60,
      glazing: "single_poly"
    ).call
    assert_equal false, result[:valid]
  end

  test "watts conversion" do
    result = Gardening::GreenhouseHeaterCalculator.new(
      length_ft: 20, width_ft: 10, height_ft: 8,
      desired_temp_f: 50, outside_temp_f: 10,
      glazing: "single_poly"
    ).call
    assert_in_delta result[:btu_per_hour] * 0.293071, result[:watts], 1
  end
end
