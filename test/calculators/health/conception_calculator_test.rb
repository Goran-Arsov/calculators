require "test_helper"

class Health::ConceptionCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: from due date, 28 day cycle ---

  test "from due date with 28 day cycle" do
    result = Health::ConceptionCalculator.new(due_date: "2026-12-25", cycle_length: 28).call
    assert result[:valid]
    assert_equal "due_date", result[:method]
    # LMP = 2026-12-25 - 280 = 2026-03-20
    assert_equal Date.new(2026, 3, 20), result[:estimated_lmp]
    # Ovulation: 28 - 14 = day 14 => 2026-03-20 + 14 = 2026-04-03
    assert_equal Date.new(2026, 4, 3), result[:estimated_conception]
    assert_equal Date.new(2026, 12, 25), result[:due_date]
  end

  # --- Happy path: from LMP, 28 day cycle ---

  test "from lmp with 28 day cycle" do
    result = Health::ConceptionCalculator.new(last_period_date: "2026-03-20", cycle_length: 28).call
    assert result[:valid]
    assert_equal "lmp", result[:method]
    # Ovulation: day 14 => 2026-03-20 + 14 = 2026-04-03
    assert_equal Date.new(2026, 4, 3), result[:estimated_conception]
    # Due date: 2026-03-20 + 280 = 2026-12-25
    assert_equal Date.new(2026, 12, 25), result[:due_date]
  end

  # --- Fertile window ---

  test "fertile window spans 5 days before to 1 day after conception" do
    result = Health::ConceptionCalculator.new(due_date: "2026-12-25", cycle_length: 28).call
    assert result[:valid]
    conception = result[:estimated_conception]
    assert_equal conception - 5, result[:fertile_window_start]
    assert_equal conception + 1, result[:fertile_window_end]
  end

  # --- Different cycle lengths ---

  test "longer cycle shifts conception date later" do
    result_28 = Health::ConceptionCalculator.new(last_period_date: "2026-03-01", cycle_length: 28).call
    result_35 = Health::ConceptionCalculator.new(last_period_date: "2026-03-01", cycle_length: 35).call
    assert result_35[:estimated_conception] > result_28[:estimated_conception]
    # 35 - 14 = day 21 vs 28 - 14 = day 14 => 7 day difference
    assert_equal 7, (result_35[:estimated_conception] - result_28[:estimated_conception]).to_i
  end

  test "shorter cycle shifts conception date earlier" do
    result = Health::ConceptionCalculator.new(last_period_date: "2026-03-01", cycle_length: 24).call
    assert result[:valid]
    # 24 - 14 = day 10
    assert_equal Date.new(2026, 3, 11), result[:estimated_conception]
  end

  # --- Conception range ---

  test "conception range is +/- 2 days from estimate" do
    result = Health::ConceptionCalculator.new(due_date: "2026-12-25", cycle_length: 28).call
    conception = result[:estimated_conception]
    assert_equal conception - 2, result[:conception_week][:earliest]
    assert_equal conception, result[:conception_week][:most_likely]
    assert_equal conception + 2, result[:conception_week][:latest]
  end

  # --- Validation: neither date provided ---

  test "no dates provided returns error" do
    result = Health::ConceptionCalculator.new.call
    refute result[:valid]
    assert_includes result[:errors], "Either due date or last period date is required"
  end

  # --- Validation: both dates provided ---

  test "both dates provided returns error" do
    result = Health::ConceptionCalculator.new(due_date: "2026-12-25", last_period_date: "2026-03-20").call
    refute result[:valid]
    assert_includes result[:errors], "Provide either due date or last period date, not both"
  end

  # --- Validation: invalid cycle length ---

  test "cycle length too short returns error" do
    result = Health::ConceptionCalculator.new(due_date: "2026-12-25", cycle_length: 15).call
    refute result[:valid]
    assert_includes result[:errors], "Cycle length must be between 20 and 45 days"
  end

  test "cycle length too long returns error" do
    result = Health::ConceptionCalculator.new(due_date: "2026-12-25", cycle_length: 50).call
    refute result[:valid]
    assert_includes result[:errors], "Cycle length must be between 20 and 45 days"
  end

  # --- String coercion ---

  test "string cycle length is coerced" do
    result = Health::ConceptionCalculator.new(due_date: "2026-12-25", cycle_length: "28").call
    assert result[:valid]
  end

  # --- Invalid date string ---

  test "invalid date string returns error" do
    result = Health::ConceptionCalculator.new(due_date: "not-a-date").call
    refute result[:valid]
    assert_includes result[:errors], "Either due date or last period date is required"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::ConceptionCalculator.new(due_date: "2026-12-25")
    assert_equal [], calc.errors
  end
end
