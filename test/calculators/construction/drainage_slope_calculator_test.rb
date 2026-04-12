require "test_helper"

class Construction::DrainageSlopeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "50ft run with 4-inch pipe produces valid results" do
    result = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 50, pipe_diameter_in: 4
    ).call
    assert_equal true, result[:valid]
    assert result[:slope_pct] > 0
    assert result[:total_drop_in] > 0
    assert result[:estimated_velocity_fps] > 0
  end

  test "4-inch pipe uses 1.04% minimum slope" do
    result = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 50, pipe_diameter_in: 4
    ).call
    assert_equal 1.04, result[:slope_pct]
    assert_equal 1.04, result[:minimum_slope_pct]
    assert_equal true, result[:meets_minimum]
  end

  test "2-inch pipe uses 2.08% minimum slope" do
    result = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 50, pipe_diameter_in: 2
    ).call
    assert_equal 2.08, result[:slope_pct]
    assert_equal 2.08, result[:minimum_slope_pct]
  end

  test "total drop calculated correctly for 4-inch pipe" do
    result = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 100, pipe_diameter_in: 4
    ).call
    # slope_in_per_ft = (1.04/100) * 12 = 0.1248
    # total_drop = 0.1248 * 100 = 12.48 inches
    assert_in_delta 12.48, result[:total_drop_in], 0.1
  end

  test "custom slope overrides minimum" do
    result = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 50, pipe_diameter_in: 4, slope_pct: 2.0
    ).call
    assert_equal 2.0, result[:slope_pct]
    assert_equal true, result[:meets_minimum]
  end

  test "custom slope below minimum flags as not meeting minimum" do
    result = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 50, pipe_diameter_in: 4, slope_pct: 0.5
    ).call
    assert_equal 0.5, result[:slope_pct]
    assert_equal false, result[:meets_minimum]
  end

  test "8-inch pipe has lowest minimum slope" do
    result = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 50, pipe_diameter_in: 8
    ).call
    assert_equal 0.52, result[:slope_pct]
    assert_equal 0.0625, result[:minimum_drop_in_per_ft]
  end

  test "velocity is positive for valid inputs" do
    result = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 50, pipe_diameter_in: 4
    ).call
    assert result[:estimated_velocity_fps] > 0
  end

  test "all pipe diameters produce valid results" do
    [ 2, 3, 4, 6, 8 ].each do |dia|
      result = Construction::DrainageSlopeCalculator.new(
        run_length_ft: 50, pipe_diameter_in: dia
      ).call
      assert_equal true, result[:valid], "Pipe diameter #{dia} should produce valid results"
    end
  end

  # --- Validation errors ---

  test "error when run length is zero" do
    result = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 0, pipe_diameter_in: 4
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Run length must be greater than zero"
  end

  test "error when pipe diameter is invalid" do
    result = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 50, pipe_diameter_in: 5
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Pipe diameter") }
  end

  test "error when custom slope is negative" do
    result = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 50, pipe_diameter_in: 4, slope_pct: -1
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Slope percentage must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::DrainageSlopeCalculator.new(
      run_length_ft: 50, pipe_diameter_in: 4
    )
    assert_equal [], calc.errors
  end
end
