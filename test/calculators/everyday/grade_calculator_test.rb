require "test_helper"

class Everyday::GradeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "equal weights, all 90s → A-" do
    result = Everyday::GradeCalculator.new(scores: "90,90,90", weights: "33.3,33.3,33.4").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_in_delta 90.0, result[:weighted_average], 0.1
    assert_equal "A-", result[:letter_grade]
  end

  test "weighted average with different weights" do
    # (80*30 + 95*70) / 100 = (2400 + 6650) / 100 = 90.5 → A-
    result = Everyday::GradeCalculator.new(scores: "80,95", weights: "30,70").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 90.5, result[:weighted_average]
    assert_equal "A-", result[:letter_grade]
  end

  test "perfect score → A+" do
    result = Everyday::GradeCalculator.new(scores: "100,100", weights: "50,50").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 100.0, result[:weighted_average]
    assert_equal "A+", result[:letter_grade]
  end

  test "zero scores → F" do
    result = Everyday::GradeCalculator.new(scores: "0,0", weights: "50,50").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0.0, result[:weighted_average]
    assert_equal "F", result[:letter_grade]
  end

  test "borderline B+ at 87" do
    result = Everyday::GradeCalculator.new(scores: "87", weights: "100").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 87.0, result[:weighted_average]
    assert_equal "B+", result[:letter_grade]
  end

  test "total_weight is returned" do
    result = Everyday::GradeCalculator.new(scores: "85,90", weights: "40,60").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 100.0, result[:total_weight]
  end

  test "assignments array is returned" do
    result = Everyday::GradeCalculator.new(scores: "85,90", weights: "40,60").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 2, result[:assignments].size
    assert_equal({ score: 85.0, weight: 40.0 }, result[:assignments][0])
  end

  # --- Validation errors ---

  test "error when scores and weights counts differ" do
    result = Everyday::GradeCalculator.new(scores: "85,90", weights: "40,30,30").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Number of scores must match number of weights"
  end

  test "error when scores are empty" do
    result = Everyday::GradeCalculator.new(scores: "", weights: "50").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Scores cannot be empty"
  end

  test "error when weights are not positive" do
    result = Everyday::GradeCalculator.new(scores: "85,90", weights: "0,50").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "All weights must be greater than zero"
  end

  test "error when scores are negative" do
    result = Everyday::GradeCalculator.new(scores: "-5,90", weights: "50,50").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Scores cannot be negative"
  end

  test "string coercion for scores and weights" do
    result = Everyday::GradeCalculator.new(scores: "85", weights: "100").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 85.0, result[:weighted_average]
    assert_equal "B", result[:letter_grade]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::GradeCalculator.new(scores: "85,90", weights: "40,60")
    assert_equal [], calc.errors
  end
end
