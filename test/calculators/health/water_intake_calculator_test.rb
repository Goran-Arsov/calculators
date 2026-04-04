require "test_helper"

class Health::WaterIntakeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates water intake for 70 kg no exercise" do
    # 70 × 0.033 = 2.31 liters
    result = Health::WaterIntakeCalculator.new(weight_kg: 70).call
    assert result[:valid]
    assert_in_delta 2.31, result[:liters], 0.01
    assert_equal 2310, result[:ml]
    assert_equal 9, result[:glasses]  # 2.31 / 0.25 = 9.24 => 9
  end

  test "calculates water intake with exercise" do
    # 70 × 0.033 = 2.31 base + (60/30) × 0.5 = 1.0 => 3.31 liters
    result = Health::WaterIntakeCalculator.new(weight_kg: 70, exercise_minutes: 60).call
    assert result[:valid]
    assert_in_delta 3.31, result[:liters], 0.01
    assert_equal 3310, result[:ml]
    assert_equal 13, result[:glasses]  # 3.31 / 0.25 = 13.24 => 13
  end

  test "calculates water intake with 30 min exercise" do
    # 80 × 0.033 = 2.64 base + (30/30) × 0.5 = 0.5 => 3.14 liters
    result = Health::WaterIntakeCalculator.new(weight_kg: 80, exercise_minutes: 30).call
    assert result[:valid]
    assert_in_delta 3.14, result[:liters], 0.01
  end

  test "zero exercise defaults correctly" do
    result = Health::WaterIntakeCalculator.new(weight_kg: 70, exercise_minutes: 0).call
    assert result[:valid]
    assert_in_delta 2.31, result[:liters], 0.01
  end

  # --- Edge cases ---

  test "very light person" do
    result = Health::WaterIntakeCalculator.new(weight_kg: 40).call
    assert result[:valid]
    assert_in_delta 1.32, result[:liters], 0.01
  end

  test "very heavy person" do
    result = Health::WaterIntakeCalculator.new(weight_kg: 150).call
    assert result[:valid]
    assert_in_delta 4.95, result[:liters], 0.01
  end

  # --- Validation ---

  test "zero weight returns error" do
    result = Health::WaterIntakeCalculator.new(weight_kg: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "negative weight returns error" do
    result = Health::WaterIntakeCalculator.new(weight_kg: -70).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "negative exercise minutes returns error" do
    result = Health::WaterIntakeCalculator.new(weight_kg: 70, exercise_minutes: -10).call
    refute result[:valid]
    assert_includes result[:errors], "Exercise minutes cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Health::WaterIntakeCalculator.new(weight_kg: 70)
    assert_equal [], calc.errors
  end
end
