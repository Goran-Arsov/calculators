require "test_helper"

class Everyday::PetCostCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: dogs ---

  test "small dog, 10 years → first_year=1850, annual=1350, lifetime=14000" do
    result = Everyday::PetCostCalculator.new(pet_type: "dog", size: "small", ownership_years: 10).call
    assert_equal true, result[:valid]
    assert_equal 1850.0, result[:first_year_cost]
    assert_equal 1350.0, result[:annual_cost]
    assert_equal 14000.0, result[:lifetime_cost]  # 1850 + 1350*9 = 14000
  end

  test "medium dog, 10 years → first_year=2200, annual=1700, lifetime=17500" do
    result = Everyday::PetCostCalculator.new(pet_type: "dog", size: "medium", ownership_years: 10).call
    assert_equal true, result[:valid]
    assert_equal 2200.0, result[:first_year_cost]
    assert_equal 1700.0, result[:annual_cost]
    assert_equal 17500.0, result[:lifetime_cost]
  end

  test "large dog, 10 years → first_year=2600, annual=2100, lifetime=21500" do
    result = Everyday::PetCostCalculator.new(pet_type: "dog", size: "large", ownership_years: 10).call
    assert_equal true, result[:valid]
    assert_equal 2600.0, result[:first_year_cost]
    assert_equal 2100.0, result[:annual_cost]
    assert_equal 21500.0, result[:lifetime_cost]
  end

  # --- Happy path: cats ---

  test "cat, 15 years → first_year=1650, annual=1150, lifetime=17750" do
    result = Everyday::PetCostCalculator.new(pet_type: "cat", size: nil, ownership_years: 15).call
    assert_equal true, result[:valid]
    assert_equal 1650.0, result[:first_year_cost]
    assert_equal 1150.0, result[:annual_cost]
    assert_equal 17750.0, result[:lifetime_cost]  # 1650 + 1150*14 = 17750
  end

  test "1 year ownership returns first year cost only" do
    result = Everyday::PetCostCalculator.new(pet_type: "dog", size: "small", ownership_years: 1).call
    assert_equal true, result[:valid]
    assert_equal 1850.0, result[:first_year_cost]
    assert_equal 1850.0, result[:lifetime_cost]
  end

  test "annual breakdown: food + vet + other = annual" do
    result = Everyday::PetCostCalculator.new(pet_type: "cat", size: nil, ownership_years: 5).call
    assert_equal result[:annual_cost], result[:food_annual] + result[:vet_annual] + result[:other_annual]
  end

  test "handles string inputs" do
    result = Everyday::PetCostCalculator.new(pet_type: "Dog", size: "Small", ownership_years: "5").call
    assert_equal true, result[:valid]
    assert_equal 1850.0, result[:first_year_cost]
  end

  # --- Validation errors ---

  test "error when pet type is invalid" do
    result = Everyday::PetCostCalculator.new(pet_type: "fish", size: nil, ownership_years: 5).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Pet type must be dog or cat"
  end

  test "error when dog size is missing" do
    result = Everyday::PetCostCalculator.new(pet_type: "dog", size: "", ownership_years: 5).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Dog size must be small, medium, or large"
  end

  test "error when ownership years is zero" do
    result = Everyday::PetCostCalculator.new(pet_type: "cat", size: nil, ownership_years: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Ownership years must be at least 1"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::PetCostCalculator.new(pet_type: "dog", size: "medium", ownership_years: 10)
    assert_equal [], calc.errors
  end
end
