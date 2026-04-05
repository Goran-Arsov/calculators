require "test_helper"

class Health::OvulationCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: 28 day cycle ---

  test "happy path 28 day cycle" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01", cycle_length: 28).call
    assert result[:valid]
    # Ovulation: 28 - 14 = day 14 => 2026-04-15
    assert_equal Date.new(2026, 4, 15), result[:ovulation_date]
    # Fertile window: April 10 to April 16
    assert_equal Date.new(2026, 4, 10), result[:fertile_window_start]
    assert_equal Date.new(2026, 4, 16), result[:fertile_window_end]
    # Next period: 2026-04-29
    assert_equal Date.new(2026, 4, 29), result[:next_period]
    assert_equal 28, result[:cycle_length]
  end

  # --- Different cycle lengths ---

  test "30 day cycle shifts ovulation later" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01", cycle_length: 30).call
    assert result[:valid]
    # Ovulation: 30 - 14 = day 16 => 2026-04-17
    assert_equal Date.new(2026, 4, 17), result[:ovulation_date]
    assert_equal Date.new(2026, 5, 1), result[:next_period]
  end

  test "24 day cycle shifts ovulation earlier" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01", cycle_length: 24).call
    assert result[:valid]
    # Ovulation: 24 - 14 = day 10 => 2026-04-11
    assert_equal Date.new(2026, 4, 11), result[:ovulation_date]
  end

  # --- Fertile window ---

  test "fertile window is 5 days before to 1 day after ovulation" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01", cycle_length: 28).call
    ov = result[:ovulation_date]
    assert_equal ov - 5, result[:fertile_window_start]
    assert_equal ov + 1, result[:fertile_window_end]
  end

  # --- Upcoming cycles ---

  test "returns 3 upcoming cycles" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01", cycle_length: 28).call
    assert result[:valid]
    assert_equal 3, result[:upcoming_cycles].length
  end

  test "upcoming cycles have correct cycle numbers" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01", cycle_length: 28).call
    assert_equal 1, result[:upcoming_cycles][0][:cycle_number]
    assert_equal 2, result[:upcoming_cycles][1][:cycle_number]
    assert_equal 3, result[:upcoming_cycles][2][:cycle_number]
  end

  test "second cycle starts at first cycle next period" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01", cycle_length: 28).call
    cycle1 = result[:upcoming_cycles][0]
    cycle2 = result[:upcoming_cycles][1]
    assert_equal cycle1[:next_period], cycle2[:period_start]
  end

  test "cycle ovulation dates are spaced by cycle length" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01", cycle_length: 30).call
    ov1 = result[:upcoming_cycles][0][:ovulation_date]
    ov2 = result[:upcoming_cycles][1][:ovulation_date]
    assert_equal 30, (ov2 - ov1).to_i
  end

  # --- Validation: no date ---

  test "nil last period date returns error" do
    result = Health::OvulationCalculator.new(last_period_date: nil).call
    refute result[:valid]
    assert_includes result[:errors], "Last period date is required and must be a valid date"
  end

  test "empty last period date returns error" do
    result = Health::OvulationCalculator.new(last_period_date: "").call
    refute result[:valid]
    assert_includes result[:errors], "Last period date is required and must be a valid date"
  end

  # --- Validation: invalid cycle length ---

  test "cycle length below 20 returns error" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01", cycle_length: 15).call
    refute result[:valid]
    assert_includes result[:errors], "Cycle length must be between 20 and 45 days"
  end

  test "cycle length above 45 returns error" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01", cycle_length: 50).call
    refute result[:valid]
    assert_includes result[:errors], "Cycle length must be between 20 and 45 days"
  end

  # --- Validation: date too old ---

  test "date more than 1 year ago returns error" do
    old_date = (Date.today - 400).to_s
    result = Health::OvulationCalculator.new(last_period_date: old_date, cycle_length: 28).call
    refute result[:valid]
    assert_includes result[:errors], "Last period date cannot be more than 1 year ago"
  end

  # --- String coercion ---

  test "string cycle length is coerced" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01", cycle_length: "28").call
    assert result[:valid]
  end

  # --- Default cycle length ---

  test "default cycle length is 28" do
    result = Health::OvulationCalculator.new(last_period_date: "2026-04-01").call
    assert result[:valid]
    assert_equal 28, result[:cycle_length]
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::OvulationCalculator.new(last_period_date: "2026-04-01")
    assert_equal [], calc.errors
  end
end
