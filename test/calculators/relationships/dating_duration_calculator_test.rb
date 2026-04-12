require "test_helper"

class Relationships::DatingDurationCalculatorTest < ActiveSupport::TestCase
  test "calculates total days" do
    result = Relationships::DatingDurationCalculator.new(first_date: "2024-01-01", reference_date: "2024-12-31").call
    assert result[:valid]
    assert_equal 365, result[:total_days]
  end

  test "future date errors" do
    result = Relationships::DatingDurationCalculator.new(first_date: "2999-01-01").call
    assert_equal false, result[:valid]
  end

  test "all unit fields present" do
    result = Relationships::DatingDurationCalculator.new(first_date: "2023-01-01", reference_date: "2024-06-15").call
    assert result[:total_hours].positive?
    assert result[:total_minutes].positive?
    assert result[:total_weeks].positive?
    assert result[:total_months].positive?
    assert result[:total_years].positive?
  end
end
