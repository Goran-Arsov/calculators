require "test_helper"

class Relationships::DaysUntilWeddingCalculatorTest < ActiveSupport::TestCase
  test "future wedding date" do
    future = Date.today + 100
    result = Relationships::DaysUntilWeddingCalculator.new(wedding_date: future.to_s).call
    assert result[:valid]
    assert_equal 100, result[:days]
    assert_equal false, result[:is_past]
  end

  test "past wedding flagged" do
    result = Relationships::DaysUntilWeddingCalculator.new(wedding_date: "2020-01-01").call
    assert result[:valid]
    assert result[:is_past]
  end

  test "milestone returned" do
    future = Date.today + 30
    result = Relationships::DaysUntilWeddingCalculator.new(wedding_date: future.to_s).call
    assert result[:milestone].present?
  end

  test "invalid date errors" do
    result = Relationships::DaysUntilWeddingCalculator.new(wedding_date: "not-a-date").call
    assert_equal false, result[:valid]
  end
end
