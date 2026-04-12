require "test_helper"

class Pets::PetMedicationDosageCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates benadryl dose for 50 lb dog" do
    # 50 lbs = 22.68 kg, min: 2 mg/kg = 45.36 mg, max: 4 mg/kg = 90.72 mg
    result = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 50, medication: "benadryl").call
    assert result[:valid]
    assert_in_delta 45.4, result[:min_dose_mg], 0.5
    assert_in_delta 90.7, result[:max_dose_mg], 0.5
    assert_equal "Every 8-12 hours", result[:frequency]
  end

  test "calculates benadryl dose for 10 lb cat" do
    # 10 lbs = 4.54 kg, min: 1 mg/kg = 4.54 mg, max: 2 mg/kg = 9.07 mg
    result = Pets::PetMedicationDosageCalculator.new(pet_type: "cat", weight_lbs: 10, medication: "benadryl").call
    assert result[:valid]
    assert_in_delta 4.5, result[:min_dose_mg], 0.5
    assert_in_delta 9.1, result[:max_dose_mg], 0.5
  end

  test "returns all expected fields" do
    result = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 50, medication: "benadryl").call
    assert result[:valid]
    assert result[:pet_type]
    assert result[:weight_lbs]
    assert result[:weight_kg]
    assert result[:medication_name]
    assert result[:medication_key]
    assert result[:min_dose_mg]
    assert result[:max_dose_mg]
    assert result[:min_mg_per_kg]
    assert result[:max_mg_per_kg]
    assert result[:frequency]
  end

  # --- Different medications ---

  test "calculates pepcid dose" do
    result = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 50, medication: "pepcid").call
    assert result[:valid]
    assert_equal "Pepcid (Famotidine)", result[:medication_name]
  end

  test "calculates glucosamine dose" do
    result = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 50, medication: "glucosamine").call
    assert result[:valid]
    assert_equal "Glucosamine", result[:medication_name]
  end

  test "calculates fish oil dose for cat" do
    result = Pets::PetMedicationDosageCalculator.new(pet_type: "cat", weight_lbs: 10, medication: "fish_oil").call
    assert result[:valid]
    assert_equal "Fish Oil (EPA + DHA)", result[:medication_name]
  end

  # --- Weight scaling ---

  test "larger pets get larger doses" do
    small = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 20, medication: "benadryl").call
    large = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 80, medication: "benadryl").call
    assert large[:min_dose_mg] > small[:min_dose_mg]
    assert large[:max_dose_mg] > small[:max_dose_mg]
  end

  test "dose scales linearly with weight" do
    result_50 = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 50, medication: "benadryl").call
    result_100 = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 100, medication: "benadryl").call
    assert_in_delta result_50[:min_dose_mg] * 2, result_100[:min_dose_mg], 0.5
  end

  # --- Dog vs Cat differences ---

  test "cats and dogs may have different dosage ranges for same medication" do
    dog = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 20, medication: "benadryl").call
    cat = Pets::PetMedicationDosageCalculator.new(pet_type: "cat", weight_lbs: 20, medication: "benadryl").call
    # Dogs have higher mg/kg for benadryl
    assert dog[:min_mg_per_kg] >= cat[:min_mg_per_kg]
  end

  # --- Validation ---

  test "zero weight returns error" do
    result = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 0, medication: "benadryl").call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "excessive weight returns error" do
    result = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 300, medication: "benadryl").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("realistic") }
  end

  test "invalid pet type returns error" do
    result = Pets::PetMedicationDosageCalculator.new(pet_type: "bird", weight_lbs: 5, medication: "benadryl").call
    refute result[:valid]
    assert_includes result[:errors], "Pet type must be dog or cat"
  end

  test "invalid medication returns error" do
    result = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 50, medication: "tylenol").call
    refute result[:valid]
    assert_includes result[:errors], "Medication not recognized"
  end

  test "errors accessor returns empty array before call" do
    calc = Pets::PetMedicationDosageCalculator.new(pet_type: "dog", weight_lbs: 50, medication: "benadryl")
    assert_equal [], calc.errors
  end
end
