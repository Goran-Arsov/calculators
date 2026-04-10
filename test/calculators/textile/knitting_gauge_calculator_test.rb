require "test_helper"

class Textile::KnittingGaugeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "standard worsted gauge 20 st / 28 rows per 4in → 5 st per inch" do
    result = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: 20,
      rows_per_4in: 28,
      target_width_in: 20,
      target_length_in: 24
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 5.0, result[:stitches_per_inch]
    assert_equal 7.0, result[:rows_per_inch]
    assert_equal 100, result[:cast_on_stitches]
    assert_equal 168, result[:total_rows]
  end

  test "cast on stitches rounded to nearest whole" do
    # 22 / 4 = 5.5 st/in * 10 in = 55 stitches
    result = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: 22,
      rows_per_4in: 30,
      target_width_in: 10,
      target_length_in: 10
    ).call
    assert_equal true, result[:valid]
    assert_equal 55, result[:cast_on_stitches]
    assert_equal 75, result[:total_rows]
  end

  test "total rows rounded to nearest whole" do
    # 28/4 = 7 rows/in * 5 in = 35
    result = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: 20,
      rows_per_4in: 28,
      target_width_in: 8,
      target_length_in: 5
    ).call
    assert_equal 35, result[:total_rows]
    assert_equal 40, result[:cast_on_stitches]
  end

  test "metric gauge 10cm values are accurate" do
    # 5 st/in * (10 / 2.54) = ~19.685
    result = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: 20,
      rows_per_4in: 28,
      target_width_in: 20,
      target_length_in: 24
    ).call
    assert_in_delta 19.69, result[:stitches_per_10cm], 0.02
    assert_in_delta 27.56, result[:rows_per_10cm], 0.02
  end

  test "fractional gauge values handled" do
    result = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: 18.5,
      rows_per_4in: 24.5,
      target_width_in: 16,
      target_length_in: 20
    ).call
    assert_equal true, result[:valid]
    assert_equal 4.625, result[:stitches_per_inch]
    assert_equal 74, result[:cast_on_stitches] # 4.625 * 16 = 74
  end

  test "echoes target dimensions" do
    result = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: 20,
      rows_per_4in: 28,
      target_width_in: 15,
      target_length_in: 18
    ).call
    assert_equal 15.0, result[:target_width_in]
    assert_equal 18.0, result[:target_length_in]
  end

  test "string inputs are coerced" do
    result = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: "20",
      rows_per_4in: "28",
      target_width_in: "20",
      target_length_in: "24"
    ).call
    assert_equal true, result[:valid]
    assert_equal 100, result[:cast_on_stitches]
  end

  # --- Validation errors ---

  test "error when stitches_per_4in is zero" do
    result = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: 0,
      rows_per_4in: 28,
      target_width_in: 20,
      target_length_in: 24
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Stitches per 4 inches must be greater than zero"
  end

  test "error when rows_per_4in is negative" do
    result = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: 20,
      rows_per_4in: -5,
      target_width_in: 20,
      target_length_in: 24
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Rows per 4 inches must be greater than zero"
  end

  test "error when target width is zero" do
    result = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: 20,
      rows_per_4in: 28,
      target_width_in: 0,
      target_length_in: 24
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Target width must be greater than zero"
  end

  test "error when target length is zero" do
    result = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: 20,
      rows_per_4in: 28,
      target_width_in: 20,
      target_length_in: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Target length must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::KnittingGaugeCalculator.new(
      stitches_per_4in: 20,
      rows_per_4in: 28,
      target_width_in: 20,
      target_length_in: 24
    )
    assert_equal [], calc.errors
  end
end
