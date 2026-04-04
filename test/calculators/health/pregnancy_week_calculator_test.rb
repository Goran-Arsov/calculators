require "test_helper"

class Health::PregnancyWeekCalculatorTest < ActiveSupport::TestCase
  # --- Happy path with LMP ---

  test "calculates current week from LMP" do
    lmp = (Date.today - 168).to_s  # 168 days = 24 weeks
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_equal 24, result[:current_week]
    assert_equal 0, result[:current_day]
  end

  test "calculates current week and day from LMP" do
    lmp = (Date.today - 170).to_s  # 170 days = 24 weeks, 2 days
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_equal 24, result[:current_week]
    assert_equal 2, result[:current_day]
  end

  test "calculates due date as 280 days from LMP" do
    lmp = (Date.today - 100).to_s
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_equal Date.parse(lmp) + 280, result[:due_date]
  end

  test "returns LMP date in result" do
    lmp = (Date.today - 100).to_s
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_equal Date.parse(lmp), result[:lmp_date]
  end

  test "calculates days remaining until due date" do
    lmp = (Date.today - 100).to_s
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_equal 180, result[:days_remaining]
  end

  test "calculates percentage complete" do
    lmp = (Date.today - 140).to_s  # 140 / 280 = 50%
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_in_delta 50.0, result[:percentage_complete], 0.1
  end

  # --- Trimester detection ---

  test "week 1-13 is first trimester" do
    lmp = (Date.today - 50).to_s  # ~7 weeks
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_equal "First", result[:trimester]
  end

  test "week 14-27 is second trimester" do
    lmp = (Date.today - 140).to_s  # 20 weeks
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_equal "Second", result[:trimester]
  end

  test "week 28-40 is third trimester" do
    lmp = (Date.today - 210).to_s  # 30 weeks
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_equal "Third", result[:trimester]
  end

  # --- Happy path with due date ---

  test "calculates from due date by deriving LMP" do
    due = (Date.today + 100).to_s
    result = Health::PregnancyWeekCalculator.new(due_date: due).call
    assert result[:valid]
    expected_lmp = Date.parse(due) - 280
    assert_equal expected_lmp, result[:lmp_date]
    assert_equal Date.parse(due), result[:due_date]
  end

  test "due date and LMP give consistent weeks" do
    lmp = (Date.today - 100).to_s
    due = (Date.parse(lmp) + 280).to_s

    result_lmp = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    result_due = Health::PregnancyWeekCalculator.new(due_date: due).call

    assert_equal result_lmp[:current_week], result_due[:current_week]
    assert_equal result_lmp[:current_day], result_due[:current_day]
  end

  # --- Edge cases ---

  test "week 0 for today as LMP" do
    lmp = Date.today.to_s
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_equal 0, result[:current_week]
    assert_equal 0, result[:current_day]
    assert_equal "Pre-pregnancy", result[:trimester]
  end

  test "week 40 returns third trimester" do
    lmp = (Date.today - 280).to_s
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_equal 40, result[:current_week]
    assert_equal "Third", result[:trimester]
  end

  test "past due date returns past due trimester" do
    lmp = (Date.today - 290).to_s  # 41+ weeks
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert_equal "Past due date", result[:trimester]
  end

  test "days remaining does not go negative" do
    lmp = (Date.today - 290).to_s
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert result[:days_remaining] >= 0
  end

  test "percentage complete caps at 100" do
    lmp = (Date.today - 290).to_s
    result = Health::PregnancyWeekCalculator.new(lmp_date: lmp).call
    assert result[:valid]
    assert result[:percentage_complete] <= 100.0
  end

  # --- Validation ---

  test "nil dates returns error" do
    result = Health::PregnancyWeekCalculator.new(due_date: nil, lmp_date: nil).call
    refute result[:valid]
    assert_includes result[:errors], "Either a due date or last menstrual period date is required"
  end

  test "empty string dates returns error" do
    result = Health::PregnancyWeekCalculator.new(due_date: "", lmp_date: "").call
    refute result[:valid]
    assert_includes result[:errors], "Either a due date or last menstrual period date is required"
  end

  test "future LMP returns error" do
    result = Health::PregnancyWeekCalculator.new(lmp_date: (Date.today + 1).to_s).call
    refute result[:valid]
    assert_includes result[:errors], "LMP date cannot be in the future"
  end

  test "LMP too far in the past returns error" do
    result = Health::PregnancyWeekCalculator.new(lmp_date: (Date.today - 400).to_s).call
    refute result[:valid]
    assert_includes result[:errors], "LMP date seems too far in the past"
  end

  test "due date too far in the future returns error" do
    result = Health::PregnancyWeekCalculator.new(due_date: (Date.today + 400).to_s).call
    refute result[:valid]
    assert_includes result[:errors], "Due date seems too far in the future"
  end

  test "errors accessor returns empty array before call" do
    calc = Health::PregnancyWeekCalculator.new(lmp_date: Date.today.to_s)
    assert_equal [], calc.errors
  end
end
