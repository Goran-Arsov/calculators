require "test_helper"

class Health::DogAgeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates human age for 5 year old medium dog" do
    # 16 × ln(5) + 31 = 16 × 1.6094 + 31 = 25.75 + 31 = 56.75
    result = Health::DogAgeCalculator.new(dog_age: 5, size: "medium").call
    assert result[:valid]
    assert_in_delta 56.8, result[:human_age_equivalent], 0.2
    assert_equal 5.0, result[:dog_age]
    assert_equal "medium", result[:size]
  end

  test "calculates human age for 1 year old medium dog" do
    # 16 × ln(1) + 31 = 16 × 0 + 31 = 31
    result = Health::DogAgeCalculator.new(dog_age: 1, size: "medium").call
    assert result[:valid]
    assert_in_delta 31.0, result[:human_age_equivalent], 0.1
  end

  test "calculates human age for 10 year old medium dog" do
    # 16 × ln(10) + 31 = 16 × 2.3026 + 31 = 36.84 + 31 = 67.84
    result = Health::DogAgeCalculator.new(dog_age: 10, size: "medium").call
    assert result[:valid]
    assert_in_delta 67.8, result[:human_age_equivalent], 0.2
  end

  # --- Size adjustments ---

  test "small dogs age slower" do
    medium_result = Health::DogAgeCalculator.new(dog_age: 5, size: "medium").call
    small_result = Health::DogAgeCalculator.new(dog_age: 5, size: "small").call
    assert small_result[:valid]
    assert small_result[:human_age_equivalent] < medium_result[:human_age_equivalent]
  end

  test "large dogs age faster" do
    medium_result = Health::DogAgeCalculator.new(dog_age: 5, size: "medium").call
    large_result = Health::DogAgeCalculator.new(dog_age: 5, size: "large").call
    assert large_result[:valid]
    assert large_result[:human_age_equivalent] > medium_result[:human_age_equivalent]
  end

  test "small dog applies 0.9 factor" do
    # Base: 16 × ln(5) + 31 = 56.75 × 0.9 = 51.08
    result = Health::DogAgeCalculator.new(dog_age: 5, size: "small").call
    assert result[:valid]
    base = 16 * Math.log(5) + 31
    assert_in_delta (base * 0.9).round(1), result[:human_age_equivalent], 0.2
  end

  test "large dog applies 1.1 factor" do
    # Base: 16 × ln(5) + 31 = 56.75 × 1.1 = 62.43
    result = Health::DogAgeCalculator.new(dog_age: 5, size: "large").call
    assert result[:valid]
    base = 16 * Math.log(5) + 31
    assert_in_delta (base * 1.1).round(1), result[:human_age_equivalent], 0.2
  end

  # --- Fractional age ---

  test "handles fractional dog age" do
    # 2.5 years: 16 × ln(2.5) + 31 = 16 × 0.9163 + 31 = 14.66 + 31 = 45.66
    result = Health::DogAgeCalculator.new(dog_age: 2.5, size: "medium").call
    assert result[:valid]
    assert_in_delta 45.7, result[:human_age_equivalent], 0.2
  end

  # --- Default size ---

  test "defaults to medium size" do
    result = Health::DogAgeCalculator.new(dog_age: 5).call
    assert result[:valid]
    assert_equal "medium", result[:size]
  end

  # --- Validation ---

  test "zero age returns error" do
    result = Health::DogAgeCalculator.new(dog_age: 0, size: "medium").call
    refute result[:valid]
    assert_includes result[:errors], "Dog age must be positive"
  end

  test "negative age returns error" do
    result = Health::DogAgeCalculator.new(dog_age: -1, size: "medium").call
    refute result[:valid]
    assert_includes result[:errors], "Dog age must be positive"
  end

  test "unrealistic age returns error" do
    result = Health::DogAgeCalculator.new(dog_age: 31, size: "medium").call
    refute result[:valid]
    assert_includes result[:errors], "Dog age must be realistic (up to 30 years)"
  end

  test "invalid size returns error" do
    result = Health::DogAgeCalculator.new(dog_age: 5, size: "giant").call
    refute result[:valid]
    assert_includes result[:errors], "Size must be small, medium, or large"
  end

  test "errors accessor returns empty array before call" do
    calc = Health::DogAgeCalculator.new(dog_age: 5, size: "medium")
    assert_equal [], calc.errors
  end
end
