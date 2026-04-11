require "test_helper"

class Geography::PopulationDensityCalculatorTest < ActiveSupport::TestCase
  test "NYC density is over 10000 per km2" do
    result = Geography::PopulationDensityCalculator.new(
      population: 8_804_190, area: 778.2, area_unit: "km2"
    ).call
    assert_equal true, result[:valid]
    assert result[:density_per_km2] > 10_000
    assert_equal "Hyperdense (megacity core)", result[:classification]
  end

  test "Mongolia density is very sparse" do
    result = Geography::PopulationDensityCalculator.new(
      population: 3_300_000, area: 1_564_100, area_unit: "km2"
    ).call
    assert result[:density_per_km2] < 10
    assert_equal "Very sparse (wilderness/rural)", result[:classification]
  end

  test "mi2 input converts correctly" do
    result = Geography::PopulationDensityCalculator.new(
      population: 1000, area: 1, area_unit: "mi2"
    ).call
    # 1 mi2 = 2.58999 km2 -> density ~386 per km2
    assert_in_delta 386, result[:density_per_km2], 1
    assert_in_delta 1000, result[:density_per_mi2], 1
  end

  test "hectare input converts correctly" do
    result = Geography::PopulationDensityCalculator.new(
      population: 100, area: 1, area_unit: "ha"
    ).call
    # 1 ha = 0.01 km2 -> density = 10000 per km2
    assert_in_delta 10_000, result[:density_per_km2], 0.1
  end

  test "zero population returns errors" do
    result = Geography::PopulationDensityCalculator.new(
      population: 0, area: 100, area_unit: "km2"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Population must be greater than zero"
  end

  test "invalid area unit returns errors" do
    result = Geography::PopulationDensityCalculator.new(
      population: 100, area: 10, area_unit: "foo"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Area unit must be one of: km2, mi2, ha, acre, m2"
  end
end
