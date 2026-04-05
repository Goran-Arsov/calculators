require "test_helper"

class Physics::PlanetWeightCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "100 on Earth → ~37.7 on Mars" do
    result = Physics::PlanetWeightCalculator.new(earth_weight: 100).call
    assert_equal true, result[:valid]
    refute result.key?(:errors)
    assert_equal 37.7, result["Mars"]
  end

  test "100 on Earth → ~236 on Jupiter" do
    result = Physics::PlanetWeightCalculator.new(earth_weight: 100).call
    assert_equal 236.0, result["Jupiter"]
  end

  test "returns weights for all planets" do
    result = Physics::PlanetWeightCalculator.new(earth_weight: 100).call
    expected_planets = %w[Mercury Venus Mars Jupiter Saturn Uranus Neptune Moon Pluto]
    expected_planets.each do |planet|
      assert result.key?(planet), "Missing weight for #{planet}"
      assert result[planet] > 0
    end
  end

  test "weight of 1 returns ratios directly" do
    result = Physics::PlanetWeightCalculator.new(earth_weight: 1).call
    assert_equal 0.38, result["Mercury"]
    assert_equal 0.91, result["Venus"]
  end

  # --- Validation errors ---

  test "error when earth weight is zero" do
    result = Physics::PlanetWeightCalculator.new(earth_weight: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Earth weight must be greater than zero"
  end

  test "error when earth weight is negative" do
    result = Physics::PlanetWeightCalculator.new(earth_weight: -50).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Earth weight must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Physics::PlanetWeightCalculator.new(earth_weight: 100)
    assert_equal [], calc.errors
  end
end
