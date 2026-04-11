require "test_helper"

class Gardening::TreeAgeCalculatorTest < ActiveSupport::TestCase
  test "red oak 63 inch circumference is about 80 years" do
    result = Gardening::TreeAgeCalculator.new(
      circumference_in: 63, species: "red_oak"
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 20.05, result[:diameter_in], 0.1
    assert_equal 4.0, result[:growth_factor]
    assert_equal 80, result[:age_years]
  end

  test "faster growing cottonwood ages younger" do
    oak = Gardening::TreeAgeCalculator.new(
      circumference_in: 63, species: "red_oak"
    ).call
    cottonwood = Gardening::TreeAgeCalculator.new(
      circumference_in: 63, species: "cottonwood"
    ).call
    assert cottonwood[:age_years] < oak[:age_years]
  end

  test "zero circumference errors" do
    result = Gardening::TreeAgeCalculator.new(
      circumference_in: 0, species: "red_oak"
    ).call
    assert_equal false, result[:valid]
  end

  test "unknown species errors" do
    result = Gardening::TreeAgeCalculator.new(
      circumference_in: 30, species: "bogus_tree"
    ).call
    assert_equal false, result[:valid]
  end
end
