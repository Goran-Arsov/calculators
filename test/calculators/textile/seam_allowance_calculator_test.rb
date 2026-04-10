require "test_helper"

class Textile::SeamAllowanceCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "inches with 5/8 SA and 2 seams" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 10, seam_allowance: 0.625, unit: "in", seams_per_edge: 2
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1.25, result[:total_sa]
    assert_equal 11.25, result[:cut_size]
    assert_equal 11.25, result[:cut_size_in]
    assert_equal 28.575, result[:cut_size_cm]
    assert_equal 0.625, result[:sa_in]
    assert_equal 1.5875, result[:sa_cm]
  end

  test "centimeters with 1 cm SA and 2 seams" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 20, seam_allowance: 1, unit: "cm", seams_per_edge: 2
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 2.0, result[:total_sa]
    assert_equal 22.0, result[:cut_size]
    assert_equal 22.0, result[:cut_size_cm]
    assert_equal 1.0, result[:sa_cm]
  end

  test "quilting 1/4 inch SA" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 4, seam_allowance: 0.25, unit: "in", seams_per_edge: 2
    ).call
    assert_equal true, result[:valid]
    assert_equal 0.5, result[:total_sa]
    assert_equal 4.5, result[:cut_size]
  end

  test "one seam per edge" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 10, seam_allowance: 0.5, unit: "in", seams_per_edge: 1
    ).call
    assert_equal true, result[:valid]
    assert_equal 0.5, result[:total_sa]
    assert_equal 10.5, result[:cut_size]
  end

  test "zero seams per edge (fold)" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 10, seam_allowance: 0.5, unit: "in", seams_per_edge: 0
    ).call
    assert_equal true, result[:valid]
    assert_equal 0.0, result[:total_sa]
    assert_equal 10.0, result[:cut_size]
  end

  test "zero seam allowance is allowed" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 10, seam_allowance: 0, unit: "in", seams_per_edge: 2
    ).call
    assert_equal true, result[:valid]
    assert_equal 0.0, result[:total_sa]
    assert_equal 10.0, result[:cut_size]
  end

  test "provides both unit conversions" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 10, seam_allowance: 0.625, unit: "in"
    ).call
    assert_not_nil result[:cut_size_in]
    assert_not_nil result[:cut_size_cm]
    assert_not_nil result[:sa_in]
    assert_not_nil result[:sa_cm]
  end

  test "common SA table is included" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 10, seam_allowance: 0.625
    ).call
    assert_equal true, result[:valid]
    assert_kind_of Hash, result[:common_sa_table]
    assert_includes result[:common_sa_table].keys, "1/4\""
    assert_includes result[:common_sa_table].keys, "1.5 cm"
  end

  test "string inputs are coerced" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: "10", seam_allowance: "0.625", unit: "in", seams_per_edge: "2"
    ).call
    assert_equal true, result[:valid]
    assert_equal 11.25, result[:cut_size]
  end

  # --- Validations ---

  test "error when finished size is zero" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 0, seam_allowance: 0.625
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Finished size must be greater than zero"
  end

  test "error when seam allowance is negative" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 10, seam_allowance: -0.25
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Seam allowance cannot be negative"
  end

  test "error when unit is invalid" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 10, seam_allowance: 0.5, unit: "mm"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Unit must be \"in\" or \"cm\""
  end

  test "error when seams per edge is invalid" do
    result = Textile::SeamAllowanceCalculator.new(
      finished_size: 10, seam_allowance: 0.5, seams_per_edge: 3
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Seams per edge must be 0, 1, or 2"
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::SeamAllowanceCalculator.new(finished_size: 10, seam_allowance: 0.5)
    assert_equal [], calc.errors
  end
end
