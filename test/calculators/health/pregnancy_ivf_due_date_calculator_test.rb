require "test_helper"

class Health::PregnancyIvfDueDateCalculatorTest < ActiveSupport::TestCase
  # --- Day 5 blastocyst transfer ---

  test "day 5 transfer calculates correct due date" do
    # Transfer on 2026-01-20, LMP = 2026-01-20 - 19 = 2026-01-01
    # Due date = 2026-01-01 + 280 = 2026-10-08
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "2026-01-20", embryo_type: "day_5"
    ).call
    assert result[:valid]
    assert_equal Date.new(2026, 10, 8), result[:due_date]
  end

  test "day 5 equivalent LMP is 19 days before transfer" do
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "2026-01-20", embryo_type: "day_5"
    ).call
    assert result[:valid]
    assert_equal Date.new(2026, 1, 1), result[:equivalent_lmp]
  end

  # --- Day 3 cleavage transfer ---

  test "day 3 transfer calculates correct due date" do
    # Transfer on 2026-01-20, LMP = 2026-01-20 - 17 = 2026-01-03
    # Due date = 2026-01-03 + 280 = 2026-10-10
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "2026-01-20", embryo_type: "day_3"
    ).call
    assert result[:valid]
    assert_equal Date.new(2026, 10, 10), result[:due_date]
  end

  test "day 3 equivalent LMP is 17 days before transfer" do
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "2026-01-20", embryo_type: "day_3"
    ).call
    assert_equal Date.new(2026, 1, 3), result[:equivalent_lmp]
  end

  # --- Embryo type label ---

  test "day 5 has blastocyst label" do
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "2026-01-20", embryo_type: "day_5"
    ).call
    assert_includes result[:embryo_type_label], "Blastocyst"
  end

  test "day 3 has cleavage stage label" do
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "2026-01-20", embryo_type: "day_3"
    ).call
    assert_includes result[:embryo_type_label], "Cleavage"
  end

  # --- Trimester dates ---

  test "trimester dates are calculated" do
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "2026-01-20", embryo_type: "day_5"
    ).call
    assert result[:trimester_dates][:first_trimester_start]
    assert result[:trimester_dates][:second_trimester_start]
    assert result[:trimester_dates][:third_trimester_start]
  end

  # --- Milestones ---

  test "milestones include key dates" do
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "2026-01-20", embryo_type: "day_5"
    ).call
    milestone_names = result[:milestones].map { |m| m[:name] }
    assert_includes milestone_names, "Heartbeat detectable"
    assert_includes milestone_names, "Anatomy scan"
    assert_includes milestone_names, "Due date"
  end

  # --- Gestational age ---

  test "gestational age display format" do
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "2026-01-20", embryo_type: "day_5"
    ).call
    assert result[:gestational_age_display].match?(/\d+ weeks, \d+ days/)
  end

  # --- Validation ---

  test "nil transfer date returns error" do
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: nil, embryo_type: "day_5"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Transfer date is required and must be a valid date"
  end

  test "empty transfer date returns error" do
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "", embryo_type: "day_5"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Transfer date is required and must be a valid date"
  end

  test "invalid embryo type returns error" do
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "2026-01-20", embryo_type: "day_7"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Embryo type must be day_3 or day_5"
  end

  test "transfer date far in the future returns error" do
    result = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: (Date.today + 400).to_s, embryo_type: "day_5"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Transfer date cannot be more than 10 months in the future"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::PregnancyIvfDueDateCalculator.new(
      transfer_date: "2026-01-20", embryo_type: "day_5"
    )
    assert_equal [], calc.errors
  end
end
