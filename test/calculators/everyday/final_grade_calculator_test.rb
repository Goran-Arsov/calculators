require "test_helper"

class Everyday::FinalGradeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic calculation with achievable target" do
    result = Everyday::FinalGradeCalculator.new(
      current_grade_percent: 85, final_exam_weight_percent: 30, desired_grade_percent: 90
    ).call
    assert_equal true, result[:valid]
    # required = (90 - 85 * 0.7) / 0.3 = (90 - 59.5) / 0.3 = 101.67
    assert_in_delta 101.67, result[:required_final_grade], 0.01
    assert_equal false, result[:is_achievable]
  end

  test "achievable target returns true" do
    result = Everyday::FinalGradeCalculator.new(
      current_grade_percent: 85, final_exam_weight_percent: 30, desired_grade_percent: 80
    ).call
    assert_equal true, result[:valid]
    # required = (80 - 85 * 0.7) / 0.3 = (80 - 59.5) / 0.3 = 68.33
    assert_in_delta 68.33, result[:required_final_grade], 0.01
    assert_equal true, result[:is_achievable]
  end

  test "perfect current grade wanting same grade needs zero on final" do
    result = Everyday::FinalGradeCalculator.new(
      current_grade_percent: 90, final_exam_weight_percent: 20, desired_grade_percent: 72
    ).call
    assert_equal true, result[:valid]
    # required = (72 - 90 * 0.8) / 0.2 = (72 - 72) / 0.2 = 0
    assert_in_delta 0.0, result[:required_final_grade], 0.01
    assert_equal true, result[:is_achievable]
  end

  test "letter grade needed is correct" do
    result = Everyday::FinalGradeCalculator.new(
      current_grade_percent: 80, final_exam_weight_percent: 40, desired_grade_percent: 85
    ).call
    assert_equal true, result[:valid]
    # required = (85 - 80 * 0.6) / 0.4 = (85 - 48) / 0.4 = 92.5
    assert_equal "A", result[:letter_grade_needed]
    assert_equal "B", result[:current_letter_grade]
  end

  test "current letter grade F for low grade" do
    result = Everyday::FinalGradeCalculator.new(
      current_grade_percent: 45, final_exam_weight_percent: 50, desired_grade_percent: 60
    ).call
    assert_equal true, result[:valid]
    assert_equal "F", result[:current_letter_grade]
  end

  test "final exam worth 100% means only final matters" do
    result = Everyday::FinalGradeCalculator.new(
      current_grade_percent: 50, final_exam_weight_percent: 100, desired_grade_percent: 90
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 90.0, result[:required_final_grade], 0.01
    assert_equal true, result[:is_achievable]
  end

  test "negative required grade is not achievable" do
    result = Everyday::FinalGradeCalculator.new(
      current_grade_percent: 100, final_exam_weight_percent: 10, desired_grade_percent: 50
    ).call
    assert_equal true, result[:valid]
    # required = (50 - 100 * 0.9) / 0.1 = (50 - 90) / 0.1 = -400
    assert result[:required_final_grade] < 0
    assert_equal false, result[:is_achievable]
  end

  # --- Validation errors ---

  test "error when current grade below 0" do
    result = Everyday::FinalGradeCalculator.new(
      current_grade_percent: -5, final_exam_weight_percent: 30, desired_grade_percent: 80
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Current grade") }
  end

  test "error when current grade above 100" do
    result = Everyday::FinalGradeCalculator.new(
      current_grade_percent: 105, final_exam_weight_percent: 30, desired_grade_percent: 80
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Current grade") }
  end

  test "error when final exam weight is 0" do
    result = Everyday::FinalGradeCalculator.new(
      current_grade_percent: 85, final_exam_weight_percent: 0, desired_grade_percent: 80
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Final exam weight") }
  end

  test "error when desired grade above 100" do
    result = Everyday::FinalGradeCalculator.new(
      current_grade_percent: 85, final_exam_weight_percent: 30, desired_grade_percent: 105
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Desired grade") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::FinalGradeCalculator.new(
      current_grade_percent: 85, final_exam_weight_percent: 30, desired_grade_percent: 90
    )
    assert_equal [], calc.errors
  end
end
