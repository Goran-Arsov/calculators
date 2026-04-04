require "test_helper"

class Health::MacroCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: maintain ---

  test "maintain goal with 2000 calories" do
    result = Health::MacroCalculator.new(calories: 2000, goal: "maintain").call
    assert result[:valid]
    # Protein: 30% = 600 cal / 4 = 150g
    assert_equal 150, result[:protein_g]
    assert_equal 600, result[:protein_cal]
    # Carbs: 40% = 800 cal / 4 = 200g
    assert_equal 200, result[:carbs_g]
    assert_equal 800, result[:carbs_cal]
    # Fat: 30% = 600 cal / 9 = 66.67g
    assert_equal 67, result[:fat_g]
    assert_equal 600, result[:fat_cal]
  end

  # --- Happy path: cut ---

  test "cut goal with 1800 calories" do
    result = Health::MacroCalculator.new(calories: 1800, goal: "cut").call
    assert result[:valid]
    # Protein: 40% = 720 cal / 4 = 180g
    assert_equal 180, result[:protein_g]
    assert_equal 720, result[:protein_cal]
    # Carbs: 30% = 540 cal / 4 = 135g
    assert_equal 135, result[:carbs_g]
    assert_equal 540, result[:carbs_cal]
    # Fat: 30% = 540 cal / 9 = 60g
    assert_equal 60, result[:fat_g]
    assert_equal 540, result[:fat_cal]
  end

  # --- Happy path: bulk ---

  test "bulk goal with 3000 calories" do
    result = Health::MacroCalculator.new(calories: 3000, goal: "bulk").call
    assert result[:valid]
    # Protein: 25% = 750 cal / 4 = 187.5g
    assert_equal 188, result[:protein_g]
    assert_equal 750, result[:protein_cal]
    # Carbs: 50% = 1500 cal / 4 = 375g
    assert_equal 375, result[:carbs_g]
    assert_equal 1500, result[:carbs_cal]
    # Fat: 25% = 750 cal / 9 = 83.33g
    assert_equal 83, result[:fat_g]
    assert_equal 750, result[:fat_cal]
  end

  # --- Validation ---

  test "zero calories returns error" do
    result = Health::MacroCalculator.new(calories: 0, goal: "maintain").call
    refute result[:valid]
    assert_includes result[:errors], "Calories must be positive"
  end

  test "negative calories returns error" do
    result = Health::MacroCalculator.new(calories: -500, goal: "maintain").call
    refute result[:valid]
    assert_includes result[:errors], "Calories must be positive"
  end

  test "invalid goal returns error" do
    result = Health::MacroCalculator.new(calories: 2000, goal: "shred").call
    refute result[:valid]
    assert_includes result[:errors], "Goal must be maintain, cut, or bulk"
  end

  test "errors accessor returns empty array before call" do
    calc = Health::MacroCalculator.new(calories: 2000, goal: "maintain")
    assert_equal [], calc.errors
  end
end
