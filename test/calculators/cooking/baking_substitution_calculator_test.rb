require "test_helper"

class Cooking::BakingSubstitutionCalculatorTest < ActiveSupport::TestCase
  test "happy path: butter to oil" do
    calc = Cooking::BakingSubstitutionCalculator.new(from_ingredient: "butter", to_ingredient: "oil", amount: 1)
    result = calc.call

    assert result[:valid]
    assert_equal 0.75, result[:converted_amount]
    assert_equal 0.75, result[:ratio]
  end

  test "happy path: oil to butter" do
    calc = Cooking::BakingSubstitutionCalculator.new(from_ingredient: "oil", to_ingredient: "butter", amount: 1)
    result = calc.call

    assert result[:valid]
    assert_equal 1.33, result[:converted_amount]
  end

  test "happy path: white sugar to honey" do
    calc = Cooking::BakingSubstitutionCalculator.new(from_ingredient: "white_sugar", to_ingredient: "honey", amount: 2)
    result = calc.call

    assert result[:valid]
    assert_equal 1.5, result[:converted_amount]
  end

  test "happy path: all purpose flour to cake flour" do
    calc = Cooking::BakingSubstitutionCalculator.new(from_ingredient: "all_purpose_flour", to_ingredient: "cake_flour", amount: 4)
    result = calc.call

    assert result[:valid]
    assert_equal 4.5, result[:converted_amount]
  end

  test "zero amount returns error" do
    calc = Cooking::BakingSubstitutionCalculator.new(from_ingredient: "butter", to_ingredient: "oil", amount: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Amount must be positive"
  end

  test "negative amount returns error" do
    calc = Cooking::BakingSubstitutionCalculator.new(from_ingredient: "butter", to_ingredient: "oil", amount: -1)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Amount must be positive"
  end

  test "unknown from ingredient returns error" do
    calc = Cooking::BakingSubstitutionCalculator.new(from_ingredient: "unknown", to_ingredient: "oil", amount: 1)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Unknown source ingredient: unknown"
  end

  test "unknown to ingredient returns error" do
    calc = Cooking::BakingSubstitutionCalculator.new(from_ingredient: "butter", to_ingredient: "unknown", amount: 1)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "No substitution available from butter to unknown"
  end

  test "available_substitutions returns data" do
    subs = Cooking::BakingSubstitutionCalculator.available_substitutions
    assert subs.key?("butter")
    assert subs.key?("egg")
    assert subs["butter"].key?("oil")
  end

  test "egg substitution 1:1 ratio" do
    calc = Cooking::BakingSubstitutionCalculator.new(from_ingredient: "egg", to_ingredient: "flax_egg", amount: 2)
    result = calc.call

    assert result[:valid]
    assert_equal 2.0, result[:converted_amount]
  end
end
