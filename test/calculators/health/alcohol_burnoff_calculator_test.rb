require "test_helper"

class Health::AlcoholBurnoffCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: male ---

  test "happy path male: peak BAC and current BAC after 2 hours" do
    # 3 drinks, 80 kg, male, 2 hours
    # peak = (3 * 14) / (80000 * 0.68) * 100 = 4200 / 54400 * 100 = 0.0772
    # current = 0.0772 - 0.015 * 2 = 0.0472
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 3, weight_kg: 80, gender: "male", hours_since_first_drink: 2
    ).call
    assert result[:valid]
    assert_in_delta 0.0772, result[:peak_bac], 0.001
    assert_in_delta 0.0472, result[:current_bac], 0.001
    assert result[:hours_until_sober] > 0
  end

  # --- Happy path: female ---

  test "happy path female: higher BAC due to lower gender factor" do
    # 3 drinks, 60 kg, female, 1 hour
    # peak = (3 * 14) / (60000 * 0.55) * 100 = 4200 / 33000 * 100 = 0.1273
    # current = 0.1273 - 0.015 * 1 = 0.1123
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 3, weight_kg: 60, gender: "female", hours_since_first_drink: 1
    ).call
    assert result[:valid]
    assert_in_delta 0.1273, result[:peak_bac], 0.001
    assert_in_delta 0.1123, result[:current_bac], 0.001
    assert_equal "moderate", result[:bac_level_description]
  end

  # --- BAC cannot go below zero ---

  test "BAC does not go below zero after many hours" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 1, weight_kg: 80, gender: "male", hours_since_first_drink: 24
    ).call
    assert result[:valid]
    assert_equal 0.0, result[:current_bac]
    assert_equal 0.0, result[:hours_until_sober]
    assert_equal "sober", result[:bac_level_description]
  end

  # --- Zero hours (peak BAC) ---

  test "zero hours returns peak BAC as current BAC" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 2, weight_kg: 70, gender: "male", hours_since_first_drink: 0
    ).call
    assert result[:valid]
    assert_equal result[:peak_bac], result[:current_bac]
  end

  # --- Hours until sober ---

  test "hours until sober is calculated from current BAC" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 4, weight_kg: 70, gender: "male", hours_since_first_drink: 1
    ).call
    assert result[:valid]
    expected_hours = result[:current_bac] / 0.015
    assert_in_delta expected_hours, result[:hours_until_sober], 0.2
  end

  # --- BAC level descriptions ---

  test "sober level description" do
    # Very light drinking, heavy person, long time
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 1, weight_kg: 100, gender: "male", hours_since_first_drink: 5
    ).call
    assert result[:valid]
    assert_equal "sober", result[:bac_level_description]
  end

  test "mild level description" do
    # 1 drink, 80 kg, male, 0 hours => peak ~0.0257
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 1, weight_kg: 80, gender: "male", hours_since_first_drink: 0
    ).call
    assert result[:valid]
    assert_equal "mild", result[:bac_level_description]
  end

  test "moderate level description" do
    # 5 drinks, 60 kg, female, 0 hours => peak ~0.2121
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 5, weight_kg: 60, gender: "female", hours_since_first_drink: 0
    ).call
    assert result[:valid]
    assert_equal "severe", result[:bac_level_description]
  end

  test "severe level description with high drinks" do
    # 10 drinks, 60 kg, female, 0 hours => very high BAC
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 10, weight_kg: 60, gender: "female", hours_since_first_drink: 0
    ).call
    assert result[:valid]
    assert_equal "severe", result[:bac_level_description]
  end

  # --- Gender comparison ---

  test "female has higher BAC than male with same inputs" do
    male = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 3, weight_kg: 70, gender: "male", hours_since_first_drink: 0
    ).call
    female = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 3, weight_kg: 70, gender: "female", hours_since_first_drink: 0
    ).call
    assert male[:valid]
    assert female[:valid]
    assert female[:peak_bac] > male[:peak_bac]
  end

  # --- Validation: zero/negative values ---

  test "zero drinks returns error" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 0, weight_kg: 80, gender: "male", hours_since_first_drink: 1
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Number of drinks must be positive"
  end

  test "negative drinks returns error" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: -2, weight_kg: 80, gender: "male", hours_since_first_drink: 1
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Number of drinks must be positive"
  end

  test "zero weight returns error" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 3, weight_kg: 0, gender: "male", hours_since_first_drink: 1
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "negative weight returns error" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 3, weight_kg: -80, gender: "male", hours_since_first_drink: 1
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "invalid gender returns error" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 3, weight_kg: 80, gender: "other", hours_since_first_drink: 1
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Gender must be male or female"
  end

  test "negative hours returns error" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 3, weight_kg: 80, gender: "male", hours_since_first_drink: -1
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Hours must be zero or positive"
  end

  # --- Validation: upper bounds ---

  test "drinks over 50 returns error" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 51, weight_kg: 80, gender: "male", hours_since_first_drink: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Number of drinks cannot exceed 50"
  end

  test "weight over 300 kg returns error" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 3, weight_kg: 301, gender: "male", hours_since_first_drink: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Weight cannot exceed 300 kg"
  end

  test "hours over 48 returns error" do
    result = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 3, weight_kg: 80, gender: "male", hours_since_first_drink: 49
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Hours cannot exceed 48"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::AlcoholBurnoffCalculator.new(
      num_standard_drinks: 3, weight_kg: 80, gender: "male", hours_since_first_drink: 1
    )
    assert_equal [], calc.errors
  end
end
