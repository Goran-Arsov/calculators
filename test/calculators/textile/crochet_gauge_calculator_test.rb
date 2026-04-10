require "test_helper"

class Textile::CrochetGaugeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "standard sc gauge 14 st / 16 rows → correct base + chain + rows" do
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 14,
      rows_per_4in: 16,
      target_width_in: 20,
      target_length_in: 24,
      starting_chain_extra: 1
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 3.5, result[:stitches_per_inch]
    assert_equal 4.0, result[:rows_per_inch]
    assert_equal 70, result[:base_stitches] # 3.5 * 20
    assert_equal 71, result[:starting_chain] # 70 + 1 for sc
    assert_equal 96, result[:total_rows] # 4 * 24
  end

  test "double crochet adds 3 turning chains" do
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 12,
      rows_per_4in: 8,
      target_width_in: 10,
      target_length_in: 10,
      starting_chain_extra: 3
    ).call
    assert_equal true, result[:valid]
    assert_equal 30, result[:base_stitches] # 3 * 10
    assert_equal 33, result[:starting_chain] # 30 + 3
    assert_equal 20, result[:total_rows]
  end

  test "defaults to starting_chain_extra of 1 for sc" do
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 16,
      rows_per_4in: 20,
      target_width_in: 10,
      target_length_in: 10
    ).call
    assert_equal true, result[:valid]
    assert_equal 40, result[:base_stitches]
    assert_equal 41, result[:starting_chain]
  end

  test "base stitches rounded to nearest whole" do
    # 15/4 = 3.75 st/in * 10 = 37.5 → rounds to 38
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 15,
      rows_per_4in: 16,
      target_width_in: 10,
      target_length_in: 10,
      starting_chain_extra: 2
    ).call
    assert_equal 38, result[:base_stitches]
    assert_equal 40, result[:starting_chain]
  end

  test "metric 10cm values are accurate" do
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 14,
      rows_per_4in: 16,
      target_width_in: 20,
      target_length_in: 24
    ).call
    # 3.5 * (10 / 2.54) ≈ 13.78
    assert_in_delta 13.78, result[:stitches_per_10cm], 0.02
    assert_in_delta 15.75, result[:rows_per_10cm], 0.02
  end

  test "string inputs are coerced" do
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: "14",
      rows_per_4in: "16",
      target_width_in: "20",
      target_length_in: "24",
      starting_chain_extra: "3"
    ).call
    assert_equal true, result[:valid]
    assert_equal 70, result[:base_stitches]
    assert_equal 73, result[:starting_chain]
  end

  test "zero starting_chain_extra is allowed" do
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 14,
      rows_per_4in: 16,
      target_width_in: 20,
      target_length_in: 24,
      starting_chain_extra: 0
    ).call
    assert_equal true, result[:valid]
    assert_equal 70, result[:base_stitches]
    assert_equal 70, result[:starting_chain]
  end

  # --- Validation errors ---

  test "error when stitches_per_4in is zero" do
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 0,
      rows_per_4in: 16,
      target_width_in: 20,
      target_length_in: 24
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Stitches per 4 inches must be greater than zero"
  end

  test "error when rows_per_4in is zero" do
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 14,
      rows_per_4in: 0,
      target_width_in: 20,
      target_length_in: 24
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Rows per 4 inches must be greater than zero"
  end

  test "error when target width is zero" do
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 14,
      rows_per_4in: 16,
      target_width_in: 0,
      target_length_in: 24
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Target width must be greater than zero"
  end

  test "error when target length is zero" do
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 14,
      rows_per_4in: 16,
      target_width_in: 20,
      target_length_in: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Target length must be greater than zero"
  end

  test "error when starting_chain_extra is negative" do
    result = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 14,
      rows_per_4in: 16,
      target_width_in: 20,
      target_length_in: 24,
      starting_chain_extra: -1
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Starting chain extra cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::CrochetGaugeCalculator.new(
      stitches_per_4in: 14,
      rows_per_4in: 16,
      target_width_in: 20,
      target_length_in: 24
    )
    assert_equal [], calc.errors
  end
end
