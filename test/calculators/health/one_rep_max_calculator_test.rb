require "test_helper"

class Health::OneRepMaxCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates 1RM with 10 reps at 100 kg" do
    # Epley: 100 × (1 + 10/30) = 100 × 1.333 = 133.3
    # Brzycki: 100 × 36/(37-10) = 100 × 36/27 = 133.3
    result = Health::OneRepMaxCalculator.new(weight: 100, reps: 10).call
    assert result[:valid]
    assert_in_delta 133.3, result[:epley_1rm], 0.1
    assert_in_delta 133.3, result[:brzycki_1rm], 0.1
    assert_in_delta 133.3, result[:average_1rm], 0.1
  end

  test "calculates 1RM with 5 reps at 80 kg" do
    # Epley: 80 × (1 + 5/30) = 80 × 1.1667 = 93.3
    # Brzycki: 80 × 36/(37-5) = 80 × 36/32 = 90.0
    result = Health::OneRepMaxCalculator.new(weight: 80, reps: 5).call
    assert result[:valid]
    assert_in_delta 93.3, result[:epley_1rm], 0.1
    assert_in_delta 90.0, result[:brzycki_1rm], 0.1
    assert_in_delta 91.7, result[:average_1rm], 0.1
  end

  test "1 rep returns the weight itself" do
    result = Health::OneRepMaxCalculator.new(weight: 100, reps: 1).call
    assert result[:valid]
    assert_in_delta 100.0, result[:epley_1rm], 0.1
    assert_in_delta 100.0, result[:brzycki_1rm], 0.1
    assert_in_delta 100.0, result[:average_1rm], 0.1
  end

  test "high rep count (20 reps)" do
    # Epley: 60 × (1 + 20/30) = 60 × 1.667 = 100.0
    # Brzycki: 60 × 36/(37-20) = 60 × 36/17 = 127.1
    result = Health::OneRepMaxCalculator.new(weight: 60, reps: 20).call
    assert result[:valid]
    assert_in_delta 100.0, result[:epley_1rm], 0.1
    assert_in_delta 127.1, result[:brzycki_1rm], 0.1
  end

  test "max valid reps (30)" do
    result = Health::OneRepMaxCalculator.new(weight: 50, reps: 30).call
    assert result[:valid]
    # Epley: 50 × (1 + 30/30) = 50 × 2 = 100.0
    assert_in_delta 100.0, result[:epley_1rm], 0.1
    # Brzycki: 50 × 36/(37-30) = 50 × 36/7 = 257.1
    assert_in_delta 257.1, result[:brzycki_1rm], 0.1
  end

  # --- Validation ---

  test "zero weight returns error" do
    result = Health::OneRepMaxCalculator.new(weight: 0, reps: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "negative weight returns error" do
    result = Health::OneRepMaxCalculator.new(weight: -50, reps: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "zero reps returns error" do
    result = Health::OneRepMaxCalculator.new(weight: 100, reps: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Reps must be between 1 and 30"
  end

  test "reps over 30 returns error" do
    result = Health::OneRepMaxCalculator.new(weight: 100, reps: 31).call
    refute result[:valid]
    assert_includes result[:errors], "Reps must be between 1 and 30"
  end

  test "negative reps returns error" do
    result = Health::OneRepMaxCalculator.new(weight: 100, reps: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Reps must be between 1 and 30"
  end

  test "errors accessor returns empty array before call" do
    calc = Health::OneRepMaxCalculator.new(weight: 100, reps: 10)
    assert_equal [], calc.errors
  end
end
