require "test_helper"

class Health::BacCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: male, metric ---

  test "happy path male metric 3 drinks 70kg 0 hours" do
    result = Health::BacCalculator.new(drinks: 3, weight: 70, gender: "male", hours: 0).call
    assert result[:valid]
    # BAC = (3*14 / (70000 * 0.68)) * 100 = 42 / 47600 * 100 = 0.0882
    assert_in_delta 0.0882, result[:bac], 0.005
    assert_equal "Legally impaired", result[:status]
    assert result[:hours_until_sober] > 0
    assert_in_delta 42.0, result[:alcohol_grams], 0.1
  end

  test "happy path female metric 2 drinks 60kg 0 hours" do
    result = Health::BacCalculator.new(drinks: 2, weight: 60, gender: "female", hours: 0).call
    assert result[:valid]
    # BAC = (2*14 / (60000 * 0.55)) * 100 = 28 / 33000 * 100 = 0.0848
    assert_in_delta 0.0848, result[:bac], 0.005
    assert_equal "Legally impaired", result[:status]
  end

  # --- Time metabolism ---

  test "bac decreases with elapsed time" do
    result_0h = Health::BacCalculator.new(drinks: 3, weight: 70, gender: "male", hours: 0).call
    result_2h = Health::BacCalculator.new(drinks: 3, weight: 70, gender: "male", hours: 2).call
    assert result_0h[:bac] > result_2h[:bac]
    # Should decrease by 0.015 * 2 = 0.03
    assert_in_delta result_0h[:bac] - 0.03, result_2h[:bac], 0.001
  end

  test "bac does not go below zero" do
    result = Health::BacCalculator.new(drinks: 1, weight: 90, gender: "male", hours: 10).call
    assert result[:valid]
    assert_equal 0.0, result[:bac]
    assert_equal "Sober", result[:status]
    assert_in_delta 0.0, result[:hours_until_sober], 0.1
  end

  # --- Imperial units ---

  test "imperial units converts lbs to grams correctly" do
    result = Health::BacCalculator.new(drinks: 3, weight: 154, gender: "male", hours: 0, unit_system: "imperial").call
    assert result[:valid]
    # 154 lbs = ~69.85 kg = ~69854 grams
    # BAC = (42 / (69854 * 0.68)) * 100 = 0.0884
    assert_in_delta 0.0884, result[:bac], 0.005
  end

  # --- Status categories ---

  test "sober status when bac below 0.02" do
    result = Health::BacCalculator.new(drinks: 0.5, weight: 100, gender: "male", hours: 0).call
    assert result[:valid]
    assert_equal "Sober", result[:status]
  end

  test "minimal impairment between 0.02 and 0.05" do
    result = Health::BacCalculator.new(drinks: 1.5, weight: 70, gender: "male", hours: 0).call
    assert result[:valid]
    # BAC = (21 / 47600) * 100 = 0.0441
    assert_equal "Minimal impairment", result[:status]
  end

  # --- Validation ---

  test "zero drinks returns error" do
    result = Health::BacCalculator.new(drinks: 0, weight: 70, gender: "male", hours: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Number of drinks must be positive"
  end

  test "negative drinks returns error" do
    result = Health::BacCalculator.new(drinks: -2, weight: 70, gender: "male", hours: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Number of drinks must be positive"
  end

  test "zero weight returns error" do
    result = Health::BacCalculator.new(drinks: 3, weight: 0, gender: "male", hours: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "invalid gender returns error" do
    result = Health::BacCalculator.new(drinks: 3, weight: 70, gender: "other", hours: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Gender must be male or female"
  end

  test "negative hours returns error" do
    result = Health::BacCalculator.new(drinks: 3, weight: 70, gender: "male", hours: -1).call
    refute result[:valid]
    assert_includes result[:errors], "Hours must be zero or positive"
  end

  test "multiple validation errors at once" do
    result = Health::BacCalculator.new(drinks: 0, weight: 0, gender: "invalid", hours: -1).call
    refute result[:valid]
    assert result[:errors].length >= 4
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Health::BacCalculator.new(drinks: "3", weight: "70", gender: "male", hours: "0").call
    assert result[:valid]
    assert result[:bac] > 0
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::BacCalculator.new(drinks: 3, weight: 70, gender: "male", hours: 0)
    assert_equal [], calc.errors
  end
end
