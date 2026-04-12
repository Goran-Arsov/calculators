require "test_helper"

class Construction::BrickBlockCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "20x8 wall with standard brick produces valid results" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8
    ).call
    assert_equal true, result[:valid]
    assert result[:units_needed] > 0
    assert result[:mortar_bags] > 0
  end

  test "gross area calculated correctly" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8
    ).call
    assert_equal 160.0, result[:gross_area_sqft]
  end

  test "net area subtracts openings" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, openings_sqft: 24
    ).call
    assert_equal 136.0, result[:net_area_sqft]
  end

  test "standard brick units per sqft approximately 6.75" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, unit_type: "standard_brick"
    ).call
    # (8 + 0.375) * (2.25 + 0.375) = 8.375 * 2.625 = 21.984375
    # 144 / 21.984375 = 6.55 (approx)
    assert result[:units_per_sqft] > 6.0
    assert result[:units_per_sqft] < 7.5
  end

  test "total units includes 10% waste" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 10, wall_height_ft: 10, unit_type: "standard_brick", openings_sqft: 0
    ).call
    # Net area = 100 sqft
    units_raw = (100 * result[:units_per_sqft]).ceil
    units_with_waste = (units_raw * 1.10).ceil
    assert_equal units_with_waste, result[:units_needed]
  end

  test "CMU 8 produces valid results" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, unit_type: "cmu_8"
    ).call
    assert_equal true, result[:valid]
    # CMU: (16+0.375) * (8+0.375) = 16.375 * 8.375 = ~137.14
    # 144 / 137.14 = ~1.05
    assert result[:units_per_sqft] > 1.0
    assert result[:units_per_sqft] < 1.2
  end

  test "CMU mortar bags calculated differently from bricks" do
    result_brick = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, unit_type: "standard_brick"
    ).call
    result_cmu = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, unit_type: "cmu_8"
    ).call
    # Both 160 sqft but different mortar calculation methods
    assert result_brick[:mortar_bags] > 0
    assert result_cmu[:mortar_bags] > 0
  end

  test "waste units calculated correctly" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8
    ).call
    assert result[:waste_units] > 0
    assert result[:waste_units] < result[:units_needed]
  end

  test "zero openings produces full area" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, openings_sqft: 0
    ).call
    assert_equal result[:gross_area_sqft], result[:net_area_sqft]
  end

  test "all unit types produce valid results" do
    %w[standard_brick modular_brick king_brick cmu_8 cmu_12].each do |unit|
      result = Construction::BrickBlockCalculator.new(
        wall_length_ft: 20, wall_height_ft: 8, unit_type: unit
      ).call
      assert_equal true, result[:valid], "Unit type #{unit} should produce valid results"
    end
  end

  # --- Validation errors ---

  test "error when wall length is zero" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 0, wall_height_ft: 8
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Wall length must be greater than zero"
  end

  test "error when wall height is zero" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Wall height must be greater than zero"
  end

  test "error when unit type is invalid" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, unit_type: "glass_block"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Invalid unit type"
  end

  test "error when openings exceed wall area" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, openings_sqft: 200
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Openings cannot exceed wall area"
  end

  test "error when openings are negative" do
    result = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, openings_sqft: -5
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Openings cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::BrickBlockCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8
    )
    assert_equal [], calc.errors
  end
end
