require "test_helper"

class Relationships::AlimonyCalculatorTest < ActiveSupport::TestCase
  test "calculates positive alimony for income gap" do
    result = Relationships::AlimonyCalculator.new(
      payor_income: 120000, recipient_income: 40000, years_married: 12
    ).call
    assert result[:valid]
    assert result[:annual_amount].positive?
    assert result[:monthly_amount].positive?
  end

  test "no alimony when payor doesn't out-earn recipient" do
    result = Relationships::AlimonyCalculator.new(
      payor_income: 50000, recipient_income: 50000, years_married: 10
    ).call
    assert_equal false, result[:valid]
  end

  test "longer marriage gets longer duration" do
    short = Relationships::AlimonyCalculator.new(
      payor_income: 100000, recipient_income: 30000, years_married: 4
    ).call
    long = Relationships::AlimonyCalculator.new(
      payor_income: 100000, recipient_income: 30000, years_married: 20
    ).call
    assert long[:duration_years] > short[:duration_years]
  end

  test "negative payor income errors" do
    result = Relationships::AlimonyCalculator.new(
      payor_income: -1, recipient_income: 30000, years_married: 5
    ).call
    assert_equal false, result[:valid]
  end
end
