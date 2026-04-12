require "test_helper"

class Pets::PuppyWeightPredictorCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "predicts adult weight for medium breed at 16 weeks" do
    # Medium breed at 16 weeks = 55% growth, 15 lbs / 0.55 = ~27.3 lbs
    result = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 15, age_weeks: 16, breed_size: "medium").call
    assert result[:valid]
    assert_in_delta 27.3, result[:predicted_adult_weight_lbs], 2
  end

  test "returns all expected fields" do
    result = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 15, age_weeks: 16, breed_size: "medium").call
    assert result[:valid]
    assert result[:current_weight_lbs]
    assert result[:age_weeks]
    assert result[:breed_size]
    assert result[:growth_percentage]
    assert result[:predicted_adult_weight_lbs]
    assert result[:predicted_adult_weight_kg]
    assert result[:remaining_growth_percentage]
    assert result[:estimated_weeks_to_adult]
    assert result[:breed_weight_range_min]
    assert result[:breed_weight_range_max]
  end

  # --- Breed size categories ---

  test "toy breed prediction at 12 weeks" do
    # Toy at 12 weeks = 60% growth, 3 lbs / 0.60 = 5 lbs
    result = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 3, age_weeks: 12, breed_size: "toy").call
    assert result[:valid]
    assert_in_delta 5.0, result[:predicted_adult_weight_lbs], 1
  end

  test "giant breed prediction at 24 weeks" do
    # Giant at 24 weeks = 50% growth, 50 lbs / 0.50 = 100 lbs
    result = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 50, age_weeks: 24, breed_size: "giant").call
    assert result[:valid]
    assert_in_delta 100.0, result[:predicted_adult_weight_lbs], 5
  end

  test "large breed prediction" do
    result = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 25, age_weeks: 16, breed_size: "large").call
    assert result[:valid]
    assert result[:predicted_adult_weight_lbs] >= 55  # Min for large breed
  end

  # --- Growth tracking ---

  test "older puppies have higher growth percentage" do
    young = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 10, age_weeks: 8, breed_size: "medium").call
    older = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 25, age_weeks: 32, breed_size: "medium").call
    assert older[:growth_percentage] > young[:growth_percentage]
  end

  test "weeks to adult decreases as puppy ages" do
    young = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 10, age_weeks: 8, breed_size: "medium").call
    older = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 30, age_weeks: 40, breed_size: "medium").call
    assert young[:estimated_weeks_to_adult] > older[:estimated_weeks_to_adult]
  end

  test "remaining growth percentage decreases with age" do
    young = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 10, age_weeks: 8, breed_size: "medium").call
    older = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 30, age_weeks: 40, breed_size: "medium").call
    assert young[:remaining_growth_percentage] > older[:remaining_growth_percentage]
  end

  # --- Weight clamping ---

  test "prediction is clamped to breed range" do
    # Very heavy puppy for toy breed should be clamped
    result = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 10, age_weeks: 8, breed_size: "toy").call
    assert result[:valid]
    max_allowed = 10 * 1.2  # max for toy with 20% buffer
    assert result[:predicted_adult_weight_lbs] <= max_allowed
  end

  # --- Includes kg conversion ---

  test "provides kg conversion" do
    result = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 15, age_weeks: 16, breed_size: "medium").call
    assert result[:valid]
    expected_kg = result[:predicted_adult_weight_lbs] * 0.453592
    assert_in_delta expected_kg, result[:predicted_adult_weight_kg], 0.5
  end

  # --- Validation ---

  test "zero weight returns error" do
    result = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 0, age_weeks: 16, breed_size: "medium").call
    refute result[:valid]
    assert_includes result[:errors], "Current weight must be positive"
  end

  test "age under 4 weeks returns error" do
    result = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 5, age_weeks: 2, breed_size: "medium").call
    refute result[:valid]
    assert_includes result[:errors], "Age must be at least 4 weeks"
  end

  test "age over 104 weeks returns error" do
    result = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 50, age_weeks: 110, breed_size: "medium").call
    refute result[:valid]
    assert_includes result[:errors], "Age cannot exceed 104 weeks for a puppy"
  end

  test "invalid breed size returns error" do
    result = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 15, age_weeks: 16, breed_size: "massive").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Breed size") }
  end

  test "errors accessor returns empty array before call" do
    calc = Pets::PuppyWeightPredictorCalculator.new(current_weight_lbs: 15, age_weeks: 16, breed_size: "medium")
    assert_equal [], calc.errors
  end
end
