require "test_helper"

class Health::PregnancyDueDateCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates due date as 280 days from last period" do
    lmp = (Date.today - 100).to_s
    result = Health::PregnancyDueDateCalculator.new(last_period_date: lmp).call
    assert result[:valid]
    assert_equal Date.parse(lmp) + 280, result[:due_date]
  end

  test "calculates conception date as 14 days from last period" do
    lmp = (Date.today - 100).to_s
    result = Health::PregnancyDueDateCalculator.new(last_period_date: lmp).call
    assert result[:valid]
    assert_equal Date.parse(lmp) + 14, result[:conception_date]
  end

  test "calculates weeks pregnant from today" do
    lmp = (Date.today - 70).to_s
    result = Health::PregnancyDueDateCalculator.new(last_period_date: lmp).call
    assert result[:valid]
    assert_equal 10, result[:weeks_pregnant]
  end

  test "returns days remaining until due date" do
    lmp = (Date.today - 100).to_s
    result = Health::PregnancyDueDateCalculator.new(last_period_date: lmp).call
    assert result[:valid]
    assert_equal 180, result[:days_remaining]
  end

  test "returns trimester dates" do
    lmp = (Date.today - 50).to_s
    result = Health::PregnancyDueDateCalculator.new(last_period_date: lmp).call
    assert result[:valid]
    trimesters = result[:trimester_dates]
    lmp_date = Date.parse(lmp)

    assert_equal lmp_date, trimesters[:first_trimester_start]
    assert_equal lmp_date + (13 * 7), trimesters[:first_trimester_end]
    assert_equal lmp_date + (13 * 7) + 1, trimesters[:second_trimester_start]
    assert_equal lmp_date + (27 * 7), trimesters[:second_trimester_end]
    assert_equal lmp_date + (27 * 7) + 1, trimesters[:third_trimester_start]
    assert_equal lmp_date + (40 * 7), trimesters[:third_trimester_end]
  end

  # --- Edge cases ---

  test "recent last period date returns zero or low weeks" do
    lmp = Date.today.to_s
    result = Health::PregnancyDueDateCalculator.new(last_period_date: lmp).call
    assert result[:valid]
    assert_equal 0, result[:weeks_pregnant]
  end

  # --- Validation ---

  test "nil date returns error" do
    result = Health::PregnancyDueDateCalculator.new(last_period_date: nil).call
    refute result[:valid]
    assert_includes result[:errors], "Last period date is required and must be a valid date"
  end

  test "empty string date returns error" do
    result = Health::PregnancyDueDateCalculator.new(last_period_date: "").call
    refute result[:valid]
    assert_includes result[:errors], "Last period date is required and must be a valid date"
  end

  test "invalid date string returns error" do
    result = Health::PregnancyDueDateCalculator.new(last_period_date: "not-a-date").call
    refute result[:valid]
    assert_includes result[:errors], "Last period date is required and must be a valid date"
  end

  test "future date returns error" do
    result = Health::PregnancyDueDateCalculator.new(last_period_date: (Date.today + 1).to_s).call
    refute result[:valid]
    assert_includes result[:errors], "Last period date cannot be in the future"
  end

  test "date too far in the past returns error" do
    result = Health::PregnancyDueDateCalculator.new(last_period_date: (Date.today - 300).to_s).call
    refute result[:valid]
    assert_includes result[:errors], "Last period date seems too far in the past"
  end

  test "errors accessor returns empty array before call" do
    calc = Health::PregnancyDueDateCalculator.new(last_period_date: Date.today.to_s)
    assert_equal [], calc.errors
  end
end
