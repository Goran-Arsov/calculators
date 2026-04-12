require "test_helper"

class Education::CollegeCostComparisonCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "compares two colleges over 4 years" do
    calc = Education::CollegeCostComparisonCalculator.new(
      college_a_tuition: 12_000, college_a_room_board: 10_000, college_a_fees: 1_500, college_a_aid: 5_000,
      college_b_tuition: 40_000, college_b_room_board: 14_000, college_b_fees: 2_000, college_b_aid: 20_000,
      years: 4, annual_inflation: 3.0
    )
    result = calc.call

    assert result[:valid]
    assert result[:college_a][:total_cost] > 0
    assert result[:college_b][:total_cost] > 0
    assert result[:difference] >= 0
    assert_includes [ "College A", "College B" ], result[:cheaper]
    assert_equal 4, result[:years]
  end

  test "identifies cheaper college correctly" do
    calc = Education::CollegeCostComparisonCalculator.new(
      college_a_tuition: 10_000, college_a_room_board: 8_000, college_a_fees: 500, college_a_aid: 0,
      college_b_tuition: 30_000, college_b_room_board: 12_000, college_b_fees: 1_000, college_b_aid: 0,
      years: 4
    )
    result = calc.call

    assert result[:valid]
    assert_equal "College A", result[:cheaper]
    assert result[:college_a][:total_cost] < result[:college_b][:total_cost]
  end

  test "financial aid can make expensive school cheaper" do
    calc = Education::CollegeCostComparisonCalculator.new(
      college_a_tuition: 10_000, college_a_room_board: 8_000, college_a_fees: 0, college_a_aid: 0,
      college_b_tuition: 40_000, college_b_room_board: 14_000, college_b_fees: 0, college_b_aid: 42_000,
      years: 4
    )
    result = calc.call

    assert result[:valid]
    assert_equal "College B", result[:cheaper]
  end

  # --- Inflation ---

  test "inflation increases total cost" do
    no_inflation = Education::CollegeCostComparisonCalculator.new(
      college_a_tuition: 20_000, college_a_room_board: 10_000,
      college_b_tuition: 20_000, college_b_room_board: 10_000,
      years: 4, annual_inflation: 0
    )
    with_inflation = Education::CollegeCostComparisonCalculator.new(
      college_a_tuition: 20_000, college_a_room_board: 10_000,
      college_b_tuition: 20_000, college_b_room_board: 10_000,
      years: 4, annual_inflation: 5.0
    )

    no_result = no_inflation.call
    with_result = with_inflation.call

    assert with_result[:college_a][:total_cost] > no_result[:college_a][:total_cost]
  end

  # --- Custom names ---

  test "custom college names are preserved" do
    calc = Education::CollegeCostComparisonCalculator.new(
      college_a_name: "MIT", college_a_tuition: 50_000, college_a_room_board: 15_000,
      college_b_name: "Stanford", college_b_tuition: 55_000, college_b_room_board: 16_000,
      years: 4
    )
    result = calc.call

    assert result[:valid]
    assert_equal "MIT", result[:college_a][:name]
    assert_equal "Stanford", result[:college_b][:name]
  end

  # --- Validation ---

  test "zero tuition for college A returns error" do
    calc = Education::CollegeCostComparisonCalculator.new(
      college_a_tuition: 0, college_a_room_board: 10_000,
      college_b_tuition: 20_000, college_b_room_board: 10_000
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "College A tuition must be positive"
  end

  test "zero tuition for college B returns error" do
    calc = Education::CollegeCostComparisonCalculator.new(
      college_a_tuition: 20_000, college_a_room_board: 10_000,
      college_b_tuition: 0, college_b_room_board: 10_000
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "College B tuition must be positive"
  end

  test "negative aid returns error" do
    calc = Education::CollegeCostComparisonCalculator.new(
      college_a_tuition: 20_000, college_a_room_board: 10_000, college_a_aid: -5_000,
      college_b_tuition: 20_000, college_b_room_board: 10_000
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Financial aid cannot be negative"
  end

  test "invalid years returns error" do
    calc = Education::CollegeCostComparisonCalculator.new(
      college_a_tuition: 20_000, college_a_room_board: 10_000,
      college_b_tuition: 20_000, college_b_room_board: 10_000,
      years: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Years must be between 1 and 6"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    calc = Education::CollegeCostComparisonCalculator.new(
      college_a_tuition: "20000", college_a_room_board: "10000",
      college_b_tuition: "30000", college_b_room_board: "12000",
      years: "4"
    )
    result = calc.call

    assert result[:valid]
  end
end
