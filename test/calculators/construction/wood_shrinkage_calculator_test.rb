require "test_helper"

class Construction::WoodShrinkageCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "red oak tangential from 30% to 8% MC" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "red_oak",
      direction: "tangential",
      initial_dimension: 10.0,
      initial_mc: 30,
      final_mc: 8
    ).call

    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "Red Oak", result[:species_name]
    assert_equal "tangential", result[:direction]
    # S = 8.6; mc_change = 22; fraction = (8.6/100) * (22/30) = 0.06307 ≈ 6.307%
    assert_equal 6.307, result[:shrinkage_percent]
    # dimension_change = 10 * 0.06306666... = 0.6307
    assert_equal 0.6307, result[:dimension_change]
    assert_equal 9.3693, result[:final_dimension]
  end

  test "radial shrinkage uses radial coefficient" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "red_oak",
      direction: "radial",
      initial_dimension: 10.0,
      initial_mc: 30,
      final_mc: 8
    ).call

    assert_equal true, result[:valid]
    # S = 4.0; fraction = (4/100) * (22/30) = 0.02933 ≈ 2.933%
    assert_equal 2.933, result[:shrinkage_percent]
  end

  test "no shrinkage above fiber saturation point" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "red_oak",
      direction: "tangential",
      initial_dimension: 10.0,
      initial_mc: 60,
      final_mc: 30
    ).call

    assert_equal true, result[:valid]
    # Both capped to 30, mc_change = 0
    assert_equal 0.0, result[:shrinkage_percent]
    assert_equal 0.0, result[:dimension_change]
    assert_equal 10.0, result[:final_dimension]
  end

  test "initial above FSP final below caps correctly" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "red_oak",
      direction: "tangential",
      initial_dimension: 10.0,
      initial_mc: 80,
      final_mc: 8
    ).call

    assert_equal true, result[:valid]
    # Capped to 30; same as 30 -> 8
    assert_equal 6.307, result[:shrinkage_percent]
  end

  test "equal moisture content produces zero shrinkage" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "hard_maple",
      direction: "tangential",
      initial_dimension: 12.0,
      initial_mc: 12,
      final_mc: 12
    ).call

    assert_equal true, result[:valid]
    assert_equal 0.0, result[:shrinkage_percent]
    assert_equal 12.0, result[:final_dimension]
  end

  test "different species use different coefficients" do
    mahogany = Construction::WoodShrinkageCalculator.new(
      species: "mahogany",
      direction: "tangential",
      initial_dimension: 10.0,
      initial_mc: 30,
      final_mc: 8
    ).call

    hickory = Construction::WoodShrinkageCalculator.new(
      species: "hickory",
      direction: "tangential",
      initial_dimension: 10.0,
      initial_mc: 30,
      final_mc: 8
    ).call

    assert_equal "Mahogany (Genuine)", mahogany[:species_name]
    assert_equal "Hickory", hickory[:species_name]
    # Hickory shrinks more than mahogany
    assert hickory[:shrinkage_percent] > mahogany[:shrinkage_percent]
  end

  test "string inputs are coerced" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "red_oak",
      direction: "tangential",
      initial_dimension: "10",
      initial_mc: "30",
      final_mc: "8"
    ).call
    assert_equal true, result[:valid]
    assert_equal 6.307, result[:shrinkage_percent]
  end

  test "species table contains expected species" do
    assert Construction::WoodShrinkageCalculator::SPECIES.key?("red_oak")
    assert Construction::WoodShrinkageCalculator::SPECIES.key?("teak")
    assert_equal 8.6, Construction::WoodShrinkageCalculator::SPECIES["red_oak"][:tangential]
    assert_equal 4.0, Construction::WoodShrinkageCalculator::SPECIES["red_oak"][:radial]
  end

  # --- Validation errors ---

  test "error when species is unknown" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "unobtainium",
      direction: "tangential",
      initial_dimension: 10.0,
      initial_mc: 30,
      final_mc: 8
    ).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Unknown species"
  end

  test "error when direction is invalid" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "red_oak",
      direction: "diagonal",
      initial_dimension: 10.0,
      initial_mc: 30,
      final_mc: 8
    ).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Direction must be tangential or radial"
  end

  test "error when initial dimension is zero" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "red_oak",
      direction: "tangential",
      initial_dimension: 0,
      initial_mc: 30,
      final_mc: 8
    ).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Initial dimension must be greater than zero"
  end

  test "error when initial MC out of range" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "red_oak",
      direction: "tangential",
      initial_dimension: 10,
      initial_mc: 150,
      final_mc: 8
    ).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Initial moisture content must be between 0 and 100"
  end

  test "error when final MC out of range" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "red_oak",
      direction: "tangential",
      initial_dimension: 10,
      initial_mc: 30,
      final_mc: -5
    ).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Final moisture content must be between 0 and 100"
  end

  test "error when final MC exceeds initial MC" do
    result = Construction::WoodShrinkageCalculator.new(
      species: "red_oak",
      direction: "tangential",
      initial_dimension: 10,
      initial_mc: 8,
      final_mc: 20
    ).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Final moisture content must be less than or equal to initial"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::WoodShrinkageCalculator.new(
      species: "red_oak",
      direction: "tangential",
      initial_dimension: 10,
      initial_mc: 30,
      final_mc: 8
    )
    assert_equal [], calc.errors
  end
end
