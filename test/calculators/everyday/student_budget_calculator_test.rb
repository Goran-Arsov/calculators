require "test_helper"

class Everyday::StudentBudgetCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic budget calculation" do
    result = Everyday::StudentBudgetCalculator.new(
      tuition: 12000, room_and_board: 10000, books_supplies: 1200,
      transportation: 1500, personal_expenses: 2000,
      financial_aid: 8000, work_income: 5000, other_scholarships: 3000
    ).call
    assert_equal true, result[:valid]
    assert_equal 26700.0, result[:total_cost]
    assert_equal 16000.0, result[:total_aid]
    assert_equal 10700.0, result[:annual_gap]
    assert_in_delta 891.67, result[:monthly_gap_12_months], 0.01
    assert_in_delta 1188.89, result[:monthly_gap_9_months], 0.01
  end

  test "aid exceeds cost produces negative gap" do
    result = Everyday::StudentBudgetCalculator.new(
      tuition: 5000, room_and_board: 3000, books_supplies: 500,
      transportation: 500, personal_expenses: 1000,
      financial_aid: 8000, work_income: 4000, other_scholarships: 2000
    ).call
    assert_equal true, result[:valid]
    assert_equal 10000.0, result[:total_cost]
    assert_equal 14000.0, result[:total_aid]
    assert_equal(-4000.0, result[:annual_gap])
  end

  test "zero costs and zero aid" do
    result = Everyday::StudentBudgetCalculator.new(
      tuition: 0, room_and_board: 0, books_supplies: 0,
      transportation: 0, personal_expenses: 0,
      financial_aid: 0, work_income: 0, other_scholarships: 0
    ).call
    assert_equal true, result[:valid]
    assert_equal 0.0, result[:total_cost]
    assert_equal 0.0, result[:total_aid]
    assert_equal 0.0, result[:annual_gap]
  end

  test "category breakdown is returned" do
    result = Everyday::StudentBudgetCalculator.new(
      tuition: 10000, room_and_board: 8000, books_supplies: 1000,
      transportation: 1000, personal_expenses: 2000,
      financial_aid: 5000, work_income: 3000, other_scholarships: 1000
    ).call
    assert_equal true, result[:valid]
    assert_equal 10000.0, result[:category_breakdown][:tuition]
    assert_equal 8000.0, result[:category_breakdown][:room_and_board]
    assert_equal 1000.0, result[:category_breakdown][:books_supplies]
    assert_equal 1000.0, result[:category_breakdown][:transportation]
    assert_equal 2000.0, result[:category_breakdown][:personal_expenses]
  end

  test "monthly gap 12 months divides by 12" do
    result = Everyday::StudentBudgetCalculator.new(
      tuition: 12000, room_and_board: 0, books_supplies: 0,
      transportation: 0, personal_expenses: 0,
      financial_aid: 0, work_income: 0, other_scholarships: 0
    ).call
    assert_equal true, result[:valid]
    assert_equal 1000.0, result[:monthly_gap_12_months]
  end

  test "monthly gap 9 months divides by 9" do
    result = Everyday::StudentBudgetCalculator.new(
      tuition: 9000, room_and_board: 0, books_supplies: 0,
      transportation: 0, personal_expenses: 0,
      financial_aid: 0, work_income: 0, other_scholarships: 0
    ).call
    assert_equal true, result[:valid]
    assert_equal 1000.0, result[:monthly_gap_9_months]
  end

  # --- Validation errors ---

  test "error when tuition is negative" do
    result = Everyday::StudentBudgetCalculator.new(
      tuition: -1000, room_and_board: 0, books_supplies: 0,
      transportation: 0, personal_expenses: 0,
      financial_aid: 0, work_income: 0, other_scholarships: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Tuition cannot be negative"
  end

  test "error when room and board is negative" do
    result = Everyday::StudentBudgetCalculator.new(
      tuition: 0, room_and_board: -500, books_supplies: 0,
      transportation: 0, personal_expenses: 0,
      financial_aid: 0, work_income: 0, other_scholarships: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Room and board cannot be negative"
  end

  test "error when financial aid is negative" do
    result = Everyday::StudentBudgetCalculator.new(
      tuition: 0, room_and_board: 0, books_supplies: 0,
      transportation: 0, personal_expenses: 0,
      financial_aid: -100, work_income: 0, other_scholarships: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Financial aid cannot be negative"
  end

  test "string coercion works for all inputs" do
    result = Everyday::StudentBudgetCalculator.new(
      tuition: "10000", room_and_board: "8000", books_supplies: "1000",
      transportation: "1000", personal_expenses: "2000",
      financial_aid: "5000", work_income: "3000", other_scholarships: "1000"
    ).call
    assert_equal true, result[:valid]
    assert_equal 22000.0, result[:total_cost]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::StudentBudgetCalculator.new(
      tuition: 10000, room_and_board: 8000, books_supplies: 1000,
      transportation: 1000, personal_expenses: 2000,
      financial_aid: 5000, work_income: 3000, other_scholarships: 1000
    )
    assert_equal [], calc.errors
  end
end
