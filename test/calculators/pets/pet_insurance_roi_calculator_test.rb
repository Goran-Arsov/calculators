require "test_helper"

class Pets::PetInsuranceRoiCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates insurance ROI for young medium dog" do
    result = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "medium", pet_age: 2,
      expected_lifespan: 12, monthly_premium: 45,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    assert result[:valid]
    assert_equal 10, result[:remaining_years]
    assert result[:total_premiums] > 0
    assert result[:total_insurance_cost] > 0
    assert result[:estimated_vet_bills] > 0
    assert result[:estimated_emergencies] > 0
  end

  test "returns all expected fields" do
    result = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "medium", pet_age: 2,
      expected_lifespan: 12, monthly_premium: 45,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    assert result[:valid]
    assert result.key?(:total_premiums)
    assert result.key?(:total_deductibles)
    assert result.key?(:total_insurance_cost)
    assert result.key?(:estimated_vet_bills)
    assert result.key?(:estimated_emergencies)
    assert result.key?(:total_estimated_costs)
    assert result.key?(:insurance_payouts)
    assert result.key?(:net_savings)
    assert result.key?(:roi_percentage)
    assert result.key?(:recommendation)
  end

  # --- Different pet types ---

  test "cats have lower vet costs than dogs" do
    dog = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "medium", pet_age: 2,
      expected_lifespan: 12, monthly_premium: 45,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    cat = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "cat", breed_size: "medium", pet_age: 2,
      expected_lifespan: 15, monthly_premium: 25,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    # Per year, cat vet costs should be lower
    dog_per_year = dog[:estimated_vet_bills].to_f / dog[:remaining_years]
    cat_per_year = cat[:estimated_vet_bills].to_f / cat[:remaining_years]
    assert cat_per_year < dog_per_year
  end

  # --- Breed size effects ---

  test "larger breeds have higher vet costs" do
    small = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "small", pet_age: 2,
      expected_lifespan: 14, monthly_premium: 30,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    giant = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "giant", pet_age: 2,
      expected_lifespan: 8, monthly_premium: 60,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    # Per year, giant should cost more
    small_per_year = small[:estimated_vet_bills].to_f / small[:remaining_years]
    giant_per_year = giant[:estimated_vet_bills].to_f / giant[:remaining_years]
    assert giant_per_year > small_per_year
  end

  # --- Premium calculations ---

  test "total premiums equal monthly times 12 times years" do
    result = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "medium", pet_age: 2,
      expected_lifespan: 12, monthly_premium: 45,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    expected_premiums = 45 * 12 * 10
    assert_equal expected_premiums, result[:total_premiums]
  end

  test "total deductibles equal annual times remaining years" do
    result = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "medium", pet_age: 2,
      expected_lifespan: 12, monthly_premium: 45,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    expected_deductibles = 250 * 10
    assert_equal expected_deductibles, result[:total_deductibles]
  end

  # --- Recommendation ---

  test "gives positive recommendation for high-cost scenario" do
    result = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "giant", pet_age: 0,
      expected_lifespan: 8, monthly_premium: 30,
      annual_deductible: 100, reimbursement_rate: 90
    ).call
    assert result[:valid]
    assert result.key?(:recommendation)
  end

  # --- Validation ---

  test "invalid pet type returns error" do
    result = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "bird", breed_size: "medium", pet_age: 2,
      expected_lifespan: 12, monthly_premium: 45,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Pet type must be dog or cat"
  end

  test "negative pet age returns error" do
    result = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "medium", pet_age: -1,
      expected_lifespan: 12, monthly_premium: 45,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Pet age must be 0 or older"
  end

  test "age exceeding lifespan returns error" do
    result = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "medium", pet_age: 15,
      expected_lifespan: 12, monthly_premium: 45,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Pet age must be less than expected lifespan"
  end

  test "zero monthly premium returns error" do
    result = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "medium", pet_age: 2,
      expected_lifespan: 12, monthly_premium: 0,
      annual_deductible: 250, reimbursement_rate: 80
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Monthly premium must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Pets::PetInsuranceRoiCalculator.new(
      pet_type: "dog", breed_size: "medium", pet_age: 2,
      expected_lifespan: 12, monthly_premium: 45,
      annual_deductible: 250, reimbursement_rate: 80
    )
    assert_equal [], calc.errors
  end
end
