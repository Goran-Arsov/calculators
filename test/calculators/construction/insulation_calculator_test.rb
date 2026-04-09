require "test_helper"

class Construction::InsulationCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "zone 4 attic fiberglass produces valid results" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 500, climate_zone: 4, location: "attic", insulation_type: "fiberglass_batt"
    ).call
    assert_equal true, result[:valid]
    assert_equal 49, result[:required_r_value]
    assert result[:thickness_inches] > 0
    assert result[:quantity_needed] > 0
    assert result[:estimated_cost] > 0
  end

  test "zone 1 attic requires R30" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 1, location: "attic", insulation_type: "fiberglass_batt"
    ).call
    assert_equal 30, result[:required_r_value]
  end

  test "zone 3 wall requires R13" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 3, location: "wall", insulation_type: "fiberglass_batt"
    ).call
    assert_equal 13, result[:required_r_value]
  end

  test "zone 6 floor requires R30" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 6, location: "floor", insulation_type: "blown_cellulose"
    ).call
    assert_equal 30, result[:required_r_value]
  end

  test "spray foam produces thinner insulation than fiberglass" do
    fiberglass = Construction::InsulationCalculator.new(
      area_sqft: 500, climate_zone: 4, location: "attic", insulation_type: "fiberglass_batt"
    ).call
    spray_foam = Construction::InsulationCalculator.new(
      area_sqft: 500, climate_zone: 4, location: "attic", insulation_type: "spray_foam"
    ).call
    assert spray_foam[:thickness_inches] < fiberglass[:thickness_inches]
  end

  test "cost varies by insulation type" do
    fiberglass = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 4, location: "attic", insulation_type: "fiberglass_batt"
    ).call
    spray_foam = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 4, location: "attic", insulation_type: "spray_foam"
    ).call
    assert spray_foam[:estimated_cost] > fiberglass[:estimated_cost]
  end

  test "fiberglass cost is 0.50 per sqft" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 200, climate_zone: 4, location: "attic", insulation_type: "fiberglass_batt"
    ).call
    assert_equal 100.0, result[:estimated_cost]
  end

  test "unit label for fiberglass is rolls" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 4, location: "attic", insulation_type: "fiberglass_batt"
    ).call
    assert_equal "rolls", result[:unit_label]
  end

  test "unit label for cellulose is bags" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 4, location: "attic", insulation_type: "blown_cellulose"
    ).call
    assert_equal "bags", result[:unit_label]
  end

  test "quantity based on 40 sqft per unit" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 4, location: "attic", insulation_type: "fiberglass_batt"
    ).call
    # 100 / 40 = 2.5, ceil = 3
    assert_equal 3, result[:quantity_needed]
  end

  # --- Validation errors ---

  test "error when area is zero" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 0, climate_zone: 4, location: "attic", insulation_type: "fiberglass_batt"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Area must be greater than zero"
  end

  test "error when climate zone out of range" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 9, location: "attic", insulation_type: "fiberglass_batt"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Climate zone must be between 1 and 7"
  end

  test "error when location is invalid" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 4, location: "basement", insulation_type: "fiberglass_batt"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Location must be attic, wall, or floor"
  end

  test "error when insulation type is invalid" do
    result = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 4, location: "attic", insulation_type: "wool"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Insulation type must be fiberglass_batt, blown_cellulose, or spray_foam"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::InsulationCalculator.new(
      area_sqft: 100, climate_zone: 4, location: "attic", insulation_type: "fiberglass_batt"
    )
    assert_equal [], calc.errors
  end
end
