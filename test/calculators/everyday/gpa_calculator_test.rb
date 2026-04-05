require "test_helper"

class Everyday::GpaCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "all A's, 3 credits each → gpa=4.0" do
    result = Everyday::GpaCalculator.new(grades: "A,A,A", credits: "3,3,3").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 4.0, result[:gpa]
    assert_equal 9.0, result[:total_credits]
  end

  test "mixed grades" do
    result = Everyday::GpaCalculator.new(grades: "A,B,C", credits: "3,3,3").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # (4*3 + 3*3 + 2*3) / 9 = 27/9 = 3.0
    assert_equal 3.0, result[:gpa]
  end

  test "weighted by credits" do
    result = Everyday::GpaCalculator.new(grades: "A,F", credits: "1,1").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # (4*1 + 0*1) / 2 = 2.0
    assert_equal 2.0, result[:gpa]
  end

  test "all F's → gpa=0.0" do
    result = Everyday::GpaCalculator.new(grades: "F,F,F", credits: "3,3,3").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0.0, result[:gpa]
  end

  # --- Validation errors ---

  test "error with invalid grade" do
    result = Everyday::GpaCalculator.new(grades: "A,X,B", credits: "3,3,3").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid grades") }
  end

  test "error when grades and credits counts differ" do
    result = Everyday::GpaCalculator.new(grades: "A,B", credits: "3,3,3").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Number of grades must match number of credits"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::GpaCalculator.new(grades: "A,B,C", credits: "3,3,3")
    assert_equal [], calc.errors
  end
end
