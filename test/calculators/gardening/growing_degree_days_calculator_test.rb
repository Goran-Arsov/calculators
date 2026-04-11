require "test_helper"

class Gardening::GrowingDegreeDaysCalculatorTest < ActiveSupport::TestCase
  test "default Fahrenheit base is 50" do
    result = Gardening::GrowingDegreeDaysCalculator.new(tmax: 80, tmin: 60).call
    assert_equal true, result[:valid]
    assert_in_delta 70, result[:average_temp], 0.01
    assert_in_delta 50, result[:base_temp], 0.01
    assert_in_delta 20, result[:gdd], 0.01
  end

  test "default Celsius base is 10" do
    result = Gardening::GrowingDegreeDaysCalculator.new(
      tmax: 25, tmin: 15, unit: "celsius"
    ).call
    assert_in_delta 10, result[:gdd], 0.01
  end

  test "negative GDD clamped to zero" do
    result = Gardening::GrowingDegreeDaysCalculator.new(tmax: 40, tmin: 30).call
    assert_in_delta 0, result[:gdd], 0.01
  end

  test "custom base overrides default" do
    result = Gardening::GrowingDegreeDaysCalculator.new(tmax: 80, tmin: 60, base: 40).call
    assert_in_delta 30, result[:gdd], 0.01
  end

  test "invalid when max less than min" do
    result = Gardening::GrowingDegreeDaysCalculator.new(tmax: 50, tmin: 60).call
    assert_equal false, result[:valid]
  end
end
