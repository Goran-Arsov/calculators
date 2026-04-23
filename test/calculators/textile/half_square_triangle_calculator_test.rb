require "test_helper"

class Textile::HalfSquareTriangleCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "2 at a time with 3 inch finished returns 3.875 cut" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 3, method: "2_at_a_time").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 3.875, result[:cut_size_in]
    assert_equal "3 7/8\"", result[:cut_size_fraction]
    assert_equal 2, result[:num_hsts_per_pair]
  end

  test "2 at a time with 4 inch finished returns 4 7/8" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 4, method: "2_at_a_time").call
    assert_equal true, result[:valid]
    assert_equal 4.875, result[:cut_size_in]
    assert_equal "4 7/8\"", result[:cut_size_fraction]
  end

  test "8 at a time with 3 inch finished returns 7.75 cut" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 3, method: "8_at_a_time").call
    assert_equal true, result[:valid]
    assert_equal 7.75, result[:cut_size_in]
    assert_equal "7 3/4\"", result[:cut_size_fraction]
    assert_equal 8, result[:num_hsts_per_pair]
  end

  test "4 at a time with 4 inch finished returns sqrt(2)*4+1.25" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 4, method: "4_at_a_time").call
    assert_equal true, result[:valid]
    expected = (4 * Math.sqrt(2)) + 1.25
    assert_in_delta expected, result[:cut_size_in], 0.0001
    assert_equal 4, result[:num_hsts_per_pair]
  end

  test "all_methods comparison table is populated" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 3, method: "2_at_a_time").call
    assert_equal true, result[:valid]
    assert_equal 3.875, result[:all_methods]["2_at_a_time"][:cut_size_in]
    assert_equal 7.75, result[:all_methods]["8_at_a_time"][:cut_size_in]
    assert_kind_of Float, result[:all_methods]["4_at_a_time"][:cut_size_in]
  end

  test "integer result produces plain inches string" do
    # Using 8 at a time with finished = 1.125 → 2*1.125 + 1.75 = 4.0
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 1.125, method: "8_at_a_time").call
    assert_equal true, result[:valid]
    assert_equal 4.0, result[:cut_size_in]
    assert_equal "4\"", result[:cut_size_fraction]
  end

  test "fractional finished size works" do
    # 2.5 finished + 7/8 = 3.375 → "3 3/8""
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 2.5, method: "2_at_a_time").call
    assert_equal true, result[:valid]
    assert_equal 3.375, result[:cut_size_in]
    assert_equal "3 3/8\"", result[:cut_size_fraction]
  end

  test "rounding to nearest eighth" do
    # 4 at a time with 3 inch: 3 * 1.4142... + 1.25 = ~5.4926 → rounds to 5.5 ("5 1/2")
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 3, method: "4_at_a_time").call
    assert_equal true, result[:valid]
    assert_equal "5 1/2\"", result[:cut_size_fraction]
  end

  test "method_description is set" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 3, method: "4_at_a_time").call
    assert_equal true, result[:valid]
    assert_includes result[:method_description], "Four at a time"
  end

  # --- Validation errors ---

  test "error when finished_size is zero" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Finished size must be greater than zero"
  end

  test "error when finished_size is negative" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: -2).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Finished size must be greater than zero"
  end

  test "error when method is unknown" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 3, method: "16_at_a_time").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Method must be 2_at_a_time, 4_at_a_time, or 8_at_a_time"
  end

  test "default method is 2_at_a_time" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 3).call
    assert_equal true, result[:valid]
    assert_equal "2_at_a_time", result[:method]
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 3)
    assert_equal [], calc.errors
  end

  # --- Metric support ---

  test "finished_size_cm input produces same cut as equivalent inch input" do
    metric = Textile::HalfSquareTriangleCalculator.new(finished_size_cm: 7.62).call
    imperial = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 3).call

    assert_in_delta imperial[:cut_size_in], metric[:cut_size_in], 0.001
    assert_equal "metric", metric[:unit_system]
    assert_equal "imperial", imperial[:unit_system]
  end

  test "metric result exposes cut_size_cm on top result and every method variant" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_cm: 10, method: "2_at_a_time").call
    assert_in_delta result[:cut_size_in] * 2.54, result[:cut_size_cm], 0.01

    result[:all_methods].each_value do |m|
      assert m.key?(:cut_size_cm), "metric cut size missing from #{m.inspect}"
    end
  end

  test "imperial result still exposes cut_size_cm for cross-unit reference" do
    result = Textile::HalfSquareTriangleCalculator.new(finished_size_in: 3).call
    assert_in_delta 3.875 * 2.54, result[:cut_size_cm], 0.01
  end

  test "explicit unit_system wins over the input-key heuristic" do
    result = Textile::HalfSquareTriangleCalculator.new(
      finished_size_in: 3, finished_size_cm: 99, unit_system: "imperial"
    ).call
    assert_equal "imperial", result[:unit_system]
    assert_equal 3.875, result[:cut_size_in]
  end
end
