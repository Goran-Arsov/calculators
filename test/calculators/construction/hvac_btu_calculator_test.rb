require "test_helper"

class Construction::HvacBtuCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "500 sqft room → recommended BTU > 0" do
    result = Construction::HvacBtuCalculator.new(room_sqft: 500).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:recommended_btu] > 0
    assert result[:tonnage] > 0
  end

  test "base BTU equals sqft times 20" do
    result = Construction::HvacBtuCalculator.new(room_sqft: 500, ceiling_height: 8, insulation: "average", climate_zone: "moderate", windows: 0).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 10_000, result[:base_btu]
  end

  test "higher ceiling increases BTU" do
    standard = Construction::HvacBtuCalculator.new(room_sqft: 500, ceiling_height: 8, insulation: "average", climate_zone: "moderate", windows: 0).call
    tall = Construction::HvacBtuCalculator.new(room_sqft: 500, ceiling_height: 10, insulation: "average", climate_zone: "moderate", windows: 0).call
    assert tall[:total_btu] > standard[:total_btu]
    assert_in_delta 1.25, tall[:ceiling_factor], 0.01
  end

  test "poor insulation increases BTU vs good insulation" do
    poor = Construction::HvacBtuCalculator.new(room_sqft: 500, insulation: "poor", climate_zone: "moderate", windows: 0).call
    good = Construction::HvacBtuCalculator.new(room_sqft: 500, insulation: "good", climate_zone: "moderate", windows: 0).call
    assert poor[:total_btu] > good[:total_btu]
  end

  test "hot climate increases BTU vs cold climate" do
    hot = Construction::HvacBtuCalculator.new(room_sqft: 500, insulation: "average", climate_zone: "hot", windows: 0).call
    cold = Construction::HvacBtuCalculator.new(room_sqft: 500, insulation: "average", climate_zone: "cold", windows: 0).call
    assert hot[:total_btu] > cold[:total_btu]
  end

  test "each window adds 1000 BTU" do
    no_windows = Construction::HvacBtuCalculator.new(room_sqft: 500, insulation: "average", climate_zone: "moderate", windows: 0).call
    with_windows = Construction::HvacBtuCalculator.new(room_sqft: 500, insulation: "average", climate_zone: "moderate", windows: 4).call
    assert_equal 4000, with_windows[:window_btu]
    assert_equal with_windows[:total_btu] - no_windows[:total_btu], 4000
  end

  test "recommended BTU rounded up to nearest 1000" do
    result = Construction::HvacBtuCalculator.new(room_sqft: 500, ceiling_height: 8, insulation: "average", climate_zone: "moderate", windows: 2).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0, result[:recommended_btu] % 1000
    assert result[:recommended_btu] >= result[:total_btu]
  end

  test "tonnage equals recommended BTU / 12000" do
    result = Construction::HvacBtuCalculator.new(room_sqft: 500).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    expected_tonnage = (result[:recommended_btu] / 12_000.0).round(2)
    assert_equal expected_tonnage, result[:tonnage]
  end

  test "string inputs are coerced" do
    result = Construction::HvacBtuCalculator.new(room_sqft: "500", ceiling_height: "10", insulation: "poor", climate_zone: "hot", windows: "3").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:recommended_btu] > 0
  end

  # --- Validation errors ---

  test "error when room sqft is zero" do
    result = Construction::HvacBtuCalculator.new(room_sqft: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Room square footage must be greater than zero"
  end

  test "error when ceiling height is zero" do
    result = Construction::HvacBtuCalculator.new(room_sqft: 500, ceiling_height: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Ceiling height must be greater than zero"
  end

  test "error when insulation is invalid" do
    result = Construction::HvacBtuCalculator.new(room_sqft: 500, insulation: "terrible").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Insulation must be one of: poor, average, good"
  end

  test "error when climate zone is invalid" do
    result = Construction::HvacBtuCalculator.new(room_sqft: 500, climate_zone: "tropical").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Climate zone must be one of: hot, warm, moderate, cool, cold"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::HvacBtuCalculator.new(room_sqft: 500)
    assert_equal [], calc.errors
  end
end
