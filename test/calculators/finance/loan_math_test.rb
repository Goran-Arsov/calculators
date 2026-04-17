require "test_helper"

class Finance::LoanMathTest < ActiveSupport::TestCase
  # LoanMath is a mixin; test through a dummy class that includes it.
  class DummyLoan
    include Finance::LoanMath
  end

  def setup
    @calc = DummyLoan.new
  end

  # --- Happy path ---

  test "standard 30-year loan at 6% annual rate" do
    result = @calc.calculate_amortization(300_000, 0.06, 30)

    assert_in_delta 1798.65, result[:monthly_payment], 0.01
    assert_equal 360, result[:num_payments]
    assert_in_delta 647_514.57, result[:total_paid], 1.0
    assert_in_delta 347_514.57, result[:total_interest], 1.0
  end

  test "15-year loan at 5% annual rate" do
    result = @calc.calculate_amortization(200_000, 0.05, 15)

    assert_equal 180, result[:num_payments]
    assert_in_delta 1581.59, result[:monthly_payment], 0.01
  end

  test "1-year loan at 12% annual rate" do
    result = @calc.calculate_amortization(12_000, 0.12, 1)

    assert_equal 12, result[:num_payments]
    assert_in_delta 1066.19, result[:monthly_payment], 0.01
  end

  # --- Zero-rate branch ---

  test "zero interest divides principal evenly across months" do
    result = @calc.calculate_amortization(120_000, 0, 10)

    assert_equal 120, result[:num_payments]
    assert_in_delta 1000.0, result[:monthly_payment], 0.01
    assert_in_delta 120_000.0, result[:total_paid], 0.01
    assert_in_delta 0.0, result[:total_interest], 0.01
  end

  # --- Structure / rounding ---

  test "returns monetary values rounded to two decimals" do
    result = @calc.calculate_amortization(100_000, 0.055, 20)

    %i[monthly_payment total_paid total_interest].each do |key|
      value = result[key]
      assert_equal value.round(2), value, "#{key} should be rounded to 2 decimal places"
    end
  end

  test "result hash contains all documented keys" do
    result = @calc.calculate_amortization(50_000, 0.04, 5)

    assert_equal %i[monthly_payment total_paid total_interest num_payments].sort,
      result.keys.sort
  end

  test "total_paid is approximately monthly_payment times num_payments" do
    # Both values are rounded independently, so they can drift by a small amount —
    # within a dollar is fine.
    result = @calc.calculate_amortization(250_000, 0.045, 25)

    expected = result[:monthly_payment] * result[:num_payments]
    assert_in_delta expected, result[:total_paid], 1.0
  end
end
