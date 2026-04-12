require "test_helper"

class Pets::CatAgeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates human age for 1 year old cat" do
    result = Pets::CatAgeCalculator.new(cat_age: 1).call
    assert result[:valid]
    assert_in_delta 15.0, result[:human_age], 0.1
  end

  test "calculates human age for 2 year old cat" do
    # 15 + 9 = 24
    result = Pets::CatAgeCalculator.new(cat_age: 2).call
    assert result[:valid]
    assert_in_delta 24.0, result[:human_age], 0.1
  end

  test "calculates human age for 5 year old cat" do
    # 15 + 9 + (3 * 4) = 36
    result = Pets::CatAgeCalculator.new(cat_age: 5).call
    assert result[:valid]
    assert_in_delta 36.0, result[:human_age], 0.1
  end

  test "calculates human age for 10 year old cat" do
    # 15 + 9 + (8 * 4) = 56
    result = Pets::CatAgeCalculator.new(cat_age: 10).call
    assert result[:valid]
    assert_in_delta 56.0, result[:human_age], 0.1
  end

  test "calculates human age for 15 year old cat" do
    # 15 + 9 + (13 * 4) = 76
    result = Pets::CatAgeCalculator.new(cat_age: 15).call
    assert result[:valid]
    assert_in_delta 76.0, result[:human_age], 0.1
  end

  # --- Fractional ages ---

  test "handles fractional cat age under 1 year" do
    # 0.5 * 15 = 7.5
    result = Pets::CatAgeCalculator.new(cat_age: 0.5).call
    assert result[:valid]
    assert_in_delta 7.5, result[:human_age], 0.1
  end

  test "handles 1.5 year old cat" do
    # 15 + (0.5 * 9) = 19.5
    result = Pets::CatAgeCalculator.new(cat_age: 1.5).call
    assert result[:valid]
    assert_in_delta 19.5, result[:human_age], 0.1
  end

  # --- Life stages ---

  test "kitten life stage for young cat" do
    result = Pets::CatAgeCalculator.new(cat_age: 0.3).call
    assert result[:valid]
    assert_equal "Kitten", result[:life_stage]
  end

  test "junior life stage" do
    result = Pets::CatAgeCalculator.new(cat_age: 1).call
    assert result[:valid]
    assert_equal "Junior", result[:life_stage]
  end

  test "prime life stage" do
    result = Pets::CatAgeCalculator.new(cat_age: 4).call
    assert result[:valid]
    assert_equal "Prime", result[:life_stage]
  end

  test "mature life stage" do
    result = Pets::CatAgeCalculator.new(cat_age: 8).call
    assert result[:valid]
    assert_equal "Mature", result[:life_stage]
  end

  test "senior life stage" do
    result = Pets::CatAgeCalculator.new(cat_age: 12).call
    assert result[:valid]
    assert_equal "Senior", result[:life_stage]
  end

  test "geriatric life stage" do
    result = Pets::CatAgeCalculator.new(cat_age: 16).call
    assert result[:valid]
    assert_equal "Geriatric", result[:life_stage]
  end

  # --- Unit: months ---

  test "converts months to years for calculation" do
    result = Pets::CatAgeCalculator.new(cat_age: 12, unit: "months").call
    assert result[:valid]
    assert_in_delta 15.0, result[:human_age], 0.1
    assert_in_delta 1.0, result[:age_in_years], 0.01
  end

  test "6 months equals half a year" do
    result = Pets::CatAgeCalculator.new(cat_age: 6, unit: "months").call
    assert result[:valid]
    assert_in_delta 7.5, result[:human_age], 0.1
  end

  # --- Default values ---

  test "defaults to years unit" do
    result = Pets::CatAgeCalculator.new(cat_age: 5).call
    assert result[:valid]
    assert_equal "years", result[:unit]
  end

  # --- Validation ---

  test "zero age returns error" do
    result = Pets::CatAgeCalculator.new(cat_age: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Cat age must be positive"
  end

  test "negative age returns error" do
    result = Pets::CatAgeCalculator.new(cat_age: -1).call
    refute result[:valid]
    assert_includes result[:errors], "Cat age must be positive"
  end

  test "excessive age returns error" do
    result = Pets::CatAgeCalculator.new(cat_age: 36).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("cannot exceed") }
  end

  test "invalid unit returns error" do
    result = Pets::CatAgeCalculator.new(cat_age: 5, unit: "days").call
    refute result[:valid]
    assert_includes result[:errors], "Unit must be years or months"
  end

  test "errors accessor returns empty array before call" do
    calc = Pets::CatAgeCalculator.new(cat_age: 5)
    assert_equal [], calc.errors
  end
end
