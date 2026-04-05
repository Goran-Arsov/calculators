require "test_helper"

class Everyday::AgeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "birth date 30 years ago → years=30" do
    birth_date = (Date.today - (30 * 365 + 7)).to_s # approximate 30 years ago
    thirty_years_ago = Date.new(Date.today.year - 30, Date.today.month, Date.today.day)
    result = Everyday::AgeCalculator.new(birth_date: thirty_years_ago.to_s).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 30, result[:years]
  end

  test "returns total days" do
    birth_date = (Date.today - 100).to_s
    result = Everyday::AgeCalculator.new(birth_date: birth_date).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 100, result[:total_days]
  end

  test "returns next birthday" do
    birth_date = Date.new(Date.today.year - 25, Date.today.month, Date.today.day)
    result = Everyday::AgeCalculator.new(birth_date: birth_date.to_s).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:next_birthday] > Date.today
  end

  test "returns months and days breakdown" do
    birth_date = Date.new(1990, 1, 1)
    result = Everyday::AgeCalculator.new(birth_date: birth_date.to_s).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:years] > 0
    assert result[:months] >= 0
    assert result[:days] >= 0
  end

  # --- Validation errors ---

  test "error when birth date is in the future" do
    result = Everyday::AgeCalculator.new(birth_date: (Date.today + 1).to_s).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Birth date cannot be in the future"
  end

  test "error with invalid date format" do
    result = Everyday::AgeCalculator.new(birth_date: "not-a-date").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Invalid date format"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::AgeCalculator.new(birth_date: "1990-01-01")
    assert_equal [], calc.errors
  end
end
