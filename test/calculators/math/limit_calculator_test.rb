require "test_helper"

class Math::LimitCalculatorTest < ActiveSupport::TestCase
  test "limit of sin(x)/x as x->0 is 1" do
    result = Math::LimitCalculator.new(expression: "sin(x)/x", approach_value: "0").call
    assert result[:valid]
    assert result[:exists]
    assert_in_delta 1.0, result[:limit_numeric], 1e-4
  end

  test "limit of x^2 as x->3 is 9" do
    result = Math::LimitCalculator.new(expression: "x^2", approach_value: "3").call
    assert result[:valid]
    assert result[:exists]
    assert_in_delta 9.0, result[:limit_numeric], 1e-4
  end

  test "limit of 1/x as x->infinity is 0" do
    result = Math::LimitCalculator.new(expression: "1/x", approach_value: "infinity").call
    assert result[:valid]
    assert result[:exists]
    assert_in_delta 0.0, result[:limit_numeric], 1e-4
  end

  test "limit of (x^2-4)/(x-2) as x->2 is 4" do
    result = Math::LimitCalculator.new(expression: "(x^2-4)/(x-2)", approach_value: "2").call
    assert result[:valid]
    assert result[:exists]
    assert_in_delta 4.0, result[:limit_numeric], 1e-3
  end

  test "left-sided limit" do
    result = Math::LimitCalculator.new(expression: "x^2", approach_value: "2", direction: "left").call
    assert result[:valid]
    assert result[:exists]
    assert_in_delta 4.0, result[:limit_numeric], 1e-4
  end

  test "right-sided limit" do
    result = Math::LimitCalculator.new(expression: "x^2", approach_value: "2", direction: "right").call
    assert result[:valid]
    assert result[:exists]
    assert_in_delta 4.0, result[:limit_numeric], 1e-4
  end

  test "blank expression returns error" do
    result = Math::LimitCalculator.new(expression: "", approach_value: "0").call
    refute result[:valid]
    assert_includes result[:errors], "Expression cannot be blank"
  end

  test "blank approach value returns error" do
    result = Math::LimitCalculator.new(expression: "x", approach_value: "").call
    refute result[:valid]
    assert_includes result[:errors], "Approach value cannot be blank"
  end

  test "invalid direction returns error" do
    result = Math::LimitCalculator.new(expression: "x", approach_value: "0", direction: "up").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Direction") }
  end

  test "invalid expression returns error" do
    result = Math::LimitCalculator.new(expression: "sin(", approach_value: "0").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid expression") }
  end

  test "constant function limit" do
    result = Math::LimitCalculator.new(expression: "5", approach_value: "10").call
    assert result[:valid]
    assert result[:exists]
    assert_in_delta 5.0, result[:limit_numeric], 1e-6
  end

  test "errors accessor returns empty array before call" do
    calc = Math::LimitCalculator.new(expression: "x", approach_value: "0")
    assert_equal [], calc.errors
  end
end
