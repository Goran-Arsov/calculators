require "test_helper"

class Everyday::RomanNumeralCalculatorTest < ActiveSupport::TestCase
  test "converts 1 to I" do
    result = Everyday::RomanNumeralCalculator.new(input: "1").call
    assert result[:valid]
    assert_equal :to_roman, result[:direction]
    assert_equal "I", result[:roman]
    assert_equal 1, result[:integer]
  end

  test "converts 4 to IV" do
    result = Everyday::RomanNumeralCalculator.new(input: "4").call
    assert result[:valid]
    assert_equal "IV", result[:roman]
  end

  test "converts 9 to IX" do
    result = Everyday::RomanNumeralCalculator.new(input: "9").call
    assert result[:valid]
    assert_equal "IX", result[:roman]
  end

  test "converts 42 to XLII" do
    result = Everyday::RomanNumeralCalculator.new(input: "42").call
    assert result[:valid]
    assert_equal "XLII", result[:roman]
  end

  test "converts 1994 to MCMXCIV" do
    result = Everyday::RomanNumeralCalculator.new(input: "1994").call
    assert result[:valid]
    assert_equal "MCMXCIV", result[:roman]
  end

  test "converts 3999 to MMMCMXCIX" do
    result = Everyday::RomanNumeralCalculator.new(input: "3999").call
    assert result[:valid]
    assert_equal "MMMCMXCIX", result[:roman]
  end

  test "converts I to 1" do
    result = Everyday::RomanNumeralCalculator.new(input: "I").call
    assert result[:valid]
    assert_equal :to_integer, result[:direction]
    assert_equal 1, result[:integer]
    assert_equal "I", result[:roman]
  end

  test "converts IV to 4" do
    result = Everyday::RomanNumeralCalculator.new(input: "IV").call
    assert result[:valid]
    assert_equal 4, result[:integer]
  end

  test "converts MCMXCIV to 1994" do
    result = Everyday::RomanNumeralCalculator.new(input: "MCMXCIV").call
    assert result[:valid]
    assert_equal 1994, result[:integer]
  end

  test "converts lowercase roman numeral" do
    result = Everyday::RomanNumeralCalculator.new(input: "xlii").call
    assert result[:valid]
    assert_equal 42, result[:integer]
  end

  test "converts MMMCMXCIX to 3999" do
    result = Everyday::RomanNumeralCalculator.new(input: "MMMCMXCIX").call
    assert result[:valid]
    assert_equal 3999, result[:integer]
  end

  test "returns error for number 0" do
    result = Everyday::RomanNumeralCalculator.new(input: "0").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("at least") }
  end

  test "returns error for negative number" do
    result = Everyday::RomanNumeralCalculator.new(input: "-1").call
    assert_not result[:valid]
  end

  test "returns error for number above 3999" do
    result = Everyday::RomanNumeralCalculator.new(input: "4000").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("at most") }
  end

  test "returns error for empty input" do
    result = Everyday::RomanNumeralCalculator.new(input: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Input cannot be empty"
  end

  test "returns error for invalid roman numeral" do
    result = Everyday::RomanNumeralCalculator.new(input: "ABCD").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid roman numeral") }
  end

  test "roundtrip integer to roman and back" do
    to_roman = Everyday::RomanNumeralCalculator.new(input: "2024").call
    from_roman = Everyday::RomanNumeralCalculator.new(input: to_roman[:roman]).call
    assert_equal 2024, from_roman[:integer]
  end

  test "converts 1000 to M" do
    result = Everyday::RomanNumeralCalculator.new(input: "1000").call
    assert result[:valid]
    assert_equal "M", result[:roman]
  end

  test "converts 500 to D" do
    result = Everyday::RomanNumeralCalculator.new(input: "500").call
    assert result[:valid]
    assert_equal "D", result[:roman]
  end

  test "converts 900 to CM" do
    result = Everyday::RomanNumeralCalculator.new(input: "900").call
    assert result[:valid]
    assert_equal "CM", result[:roman]
  end
end
