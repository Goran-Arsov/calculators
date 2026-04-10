require "test_helper"

class Construction::WoodMoistureCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "10% moisture content from 110g wet / 100g dry" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 110, dry_weight: 100).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 10.0, result[:moisture_content]
    assert_equal 10.0, result[:water_weight]
    assert_equal 110.0, result[:wet_weight]
    assert_equal 100.0, result[:dry_weight]
  end

  test "kiln-dry category for 8% MC" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 108, dry_weight: 100).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 8.0, result[:moisture_content]
    assert_equal "Kiln-dry (interior use)", result[:category]
    assert_equal "Suitable for indoor furniture, cabinetry, and flooring", result[:suitable_for]
  end

  test "air-dry category for 15% MC" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 115, dry_weight: 100).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 15.0, result[:moisture_content]
    assert_equal "Air-dry", result[:category]
  end

  test "wet / shipping dry for 25% MC" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 125, dry_weight: 100).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 25.0, result[:moisture_content]
    assert_equal "Wet / shipping dry", result[:category]
  end

  test "green category for > 30% MC" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 150, dry_weight: 100).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 50.0, result[:moisture_content]
    assert_equal "Green (above fiber saturation point)", result[:category]
  end

  test "very dry / over-dried for < 6% MC" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 103, dry_weight: 100).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 3.0, result[:moisture_content]
    assert_equal "Very dry / over-dried", result[:category]
  end

  test "equal wet and dry weights yields 0% MC" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 100, dry_weight: 100).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0.0, result[:moisture_content]
    assert_equal 0.0, result[:water_weight]
    assert_equal "Very dry / over-dried", result[:category]
  end

  test "boundary 19% is wet / shipping dry (lower bound)" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 119, dry_weight: 100).call
    assert_equal "Wet / shipping dry", result[:category]
  end

  test "boundary 30% is wet / shipping dry (upper bound)" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 130, dry_weight: 100).call
    assert_equal "Wet / shipping dry", result[:category]
  end

  test "boundary 14% is air-dry (lower bound)" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 114, dry_weight: 100).call
    assert_equal "Air-dry", result[:category]
  end

  test "boundary 6% is kiln-dry (lower bound)" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 106, dry_weight: 100).call
    assert_equal "Kiln-dry (interior use)", result[:category]
  end

  test "string inputs are coerced" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: "110", dry_weight: "100").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 10.0, result[:moisture_content]
  end

  test "moisture content is rounded to 2 decimals" do
    # 107.77 / 100 => 7.77%
    result = Construction::WoodMoistureCalculator.new(wet_weight: 107.77, dry_weight: 100).call
    assert_equal 7.77, result[:moisture_content]
  end

  # --- Validation errors ---

  test "error when wet weight is zero" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 0, dry_weight: 100).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Wet weight must be greater than zero"
  end

  test "error when dry weight is zero" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 110, dry_weight: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Dry weight must be greater than zero"
  end

  test "error when wet weight is negative" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: -10, dry_weight: 100).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Wet weight must be greater than zero"
  end

  test "error when dry weight is negative" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 110, dry_weight: -5).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Dry weight must be greater than zero"
  end

  test "error when wet weight is less than dry weight" do
    result = Construction::WoodMoistureCalculator.new(wet_weight: 90, dry_weight: 100).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Wet weight must be greater than or equal to dry weight"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::WoodMoistureCalculator.new(wet_weight: 110, dry_weight: 100)
    assert_equal [], calc.errors
  end
end
