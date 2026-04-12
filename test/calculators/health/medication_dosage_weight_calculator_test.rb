require "test_helper"

class Health::MedicationDosageWeightCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: ibuprofen 70 kg ---

  test "ibuprofen 70kg calculates single dose" do
    result = Health::MedicationDosageWeightCalculator.new(weight: 70, medication: "ibuprofen").call
    assert result[:valid]
    # 70 * 10 = 700, capped at 400
    assert_equal 400.0, result[:recommended_single_dose_mg]
    assert result[:capped]
  end

  test "ibuprofen 30kg is not capped" do
    result = Health::MedicationDosageWeightCalculator.new(weight: 30, medication: "ibuprofen").call
    assert result[:valid]
    # 30 * 10 = 300, below 400 cap
    assert_equal 300.0, result[:recommended_single_dose_mg]
    refute result[:capped]
  end

  # --- Acetaminophen ---

  test "acetaminophen 80kg capped at max single" do
    result = Health::MedicationDosageWeightCalculator.new(weight: 80, medication: "acetaminophen").call
    assert result[:valid]
    # 80 * 15 = 1200, capped at 1000
    assert_equal 1000.0, result[:recommended_single_dose_mg]
    assert_equal 4, result[:doses_per_day]
    assert result[:capped]
  end

  # --- Weight unit conversion ---

  test "lbs to kg conversion works" do
    result = Health::MedicationDosageWeightCalculator.new(weight: 154, weight_unit: "lbs", medication: "ibuprofen").call
    assert result[:valid]
    # 154 lbs = ~69.85 kg
    assert_in_delta 69.85, result[:weight_kg], 0.5
  end

  # --- Custom medication ---

  test "custom medication with dose_mg_per_kg" do
    result = Health::MedicationDosageWeightCalculator.new(
      weight: 70, medication: "custom", dose_mg_per_kg: 5, doses_per_day: 2
    ).call
    assert result[:valid]
    assert_equal 350.0, result[:recommended_single_dose_mg]
    assert_equal 700.0, result[:recommended_daily_total_mg]
  end

  test "custom medication without dose returns error" do
    result = Health::MedicationDosageWeightCalculator.new(
      weight: 70, medication: "custom"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Custom dose per kg must be positive"
  end

  # --- Validation ---

  test "zero weight returns error" do
    result = Health::MedicationDosageWeightCalculator.new(weight: 0, medication: "ibuprofen").call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "weight over 500 returns error" do
    result = Health::MedicationDosageWeightCalculator.new(weight: 600, medication: "ibuprofen").call
    refute result[:valid]
    assert_includes result[:errors], "Weight seems unrealistically high"
  end

  test "unknown medication returns error" do
    result = Health::MedicationDosageWeightCalculator.new(weight: 70, medication: "unknown").call
    refute result[:valid]
    assert_includes result[:errors], "Unknown medication"
  end

  test "invalid weight unit returns error" do
    result = Health::MedicationDosageWeightCalculator.new(weight: 70, weight_unit: "stones", medication: "ibuprofen").call
    refute result[:valid]
    assert_includes result[:errors], "Weight unit must be kg or lbs"
  end

  # --- Daily total capping ---

  test "daily total is capped correctly" do
    result = Health::MedicationDosageWeightCalculator.new(weight: 70, medication: "ibuprofen").call
    assert result[:valid]
    # 400 x 3 = 1200, max daily is 1200 - exactly at cap
    assert_equal 1200.0, result[:recommended_daily_total_mg]
  end

  # --- Notes ---

  test "includes medication notes" do
    result = Health::MedicationDosageWeightCalculator.new(weight: 70, medication: "ibuprofen").call
    assert result[:valid]
    assert_includes result[:notes], "Take with food"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::MedicationDosageWeightCalculator.new(weight: 70, medication: "ibuprofen")
    assert_equal [], calc.errors
  end
end
