require "test_helper"

class Relationships::AnniversaryCalculatorTest < ActiveSupport::TestCase
  test "calculates years from a known date" do
    result = Relationships::AnniversaryCalculator.new(start_date: "2020-06-15", reference_date: "2025-06-15").call
    assert result[:valid]
    assert_equal 5, result[:years]
    assert_equal 0, result[:months]
    assert_equal 0, result[:days]
  end

  test "next anniversary calculated" do
    result = Relationships::AnniversaryCalculator.new(start_date: "2020-06-15", reference_date: "2025-06-20").call
    assert result[:valid]
    assert_equal Date.new(2026, 6, 15), result[:next_anniversary]
  end

  test "future start errors" do
    result = Relationships::AnniversaryCalculator.new(start_date: "2999-01-01").call
    assert_equal false, result[:valid]
  end

  test "traditional gift returned for known years" do
    result = Relationships::AnniversaryCalculator.new(start_date: "2020-01-01", reference_date: "2024-06-15").call
    assert result[:valid]
    assert result[:traditional_gift].present?
  end
end
