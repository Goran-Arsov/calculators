require "test_helper"

class Construction::RafterLengthCalculatorTest < ActiveSupport::TestCase
  test "6/12 pitch on 12 ft run" do
    result = Construction::RafterLengthCalculator.new(run_ft: 12, pitch_rise_per_12: 6).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # rise = 12 * 0.5 = 6 ft
    assert_in_delta 6.0, result[:rise_ft], 0.01
    # rafter = sqrt(12² + 6²) = sqrt(180) ≈ 13.42
    assert_in_delta 13.42, result[:rafter_length_ft], 0.01
    # angle = atan(0.5) ≈ 26.57°
    assert_in_delta 26.57, result[:angle_deg], 0.01
  end

  test "12/12 pitch gives 45° angle" do
    result = Construction::RafterLengthCalculator.new(run_ft: 10, pitch_rise_per_12: 12).call
    assert_in_delta 45.0, result[:angle_deg], 0.01
  end

  test "4/12 pitch grade percentage" do
    result = Construction::RafterLengthCalculator.new(run_ft: 12, pitch_rise_per_12: 4).call
    # 4/12 = 33.3% grade
    assert_in_delta 33.3, result[:grade_pct], 0.1
  end

  test "overhang adds to total rafter length" do
    base = Construction::RafterLengthCalculator.new(run_ft: 12, pitch_rise_per_12: 6).call
    with_overhang = Construction::RafterLengthCalculator.new(run_ft: 12, pitch_rise_per_12: 6, overhang_in: 24).call
    # overhang of 24 in = 2 ft added
    assert_in_delta base[:rafter_length_ft] + 2.0, with_overhang[:total_rafter_ft], 0.01
  end

  test "pitch notation is formatted" do
    result = Construction::RafterLengthCalculator.new(run_ft: 12, pitch_rise_per_12: 8).call
    assert_equal "8/12", result[:pitch_notation]
  end

  test "error when run is zero" do
    result = Construction::RafterLengthCalculator.new(run_ft: 0, pitch_rise_per_12: 6).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Run must be greater than zero"
  end

  test "error when pitch is zero" do
    result = Construction::RafterLengthCalculator.new(run_ft: 12, pitch_rise_per_12: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Pitch must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::RafterLengthCalculator.new(run_ft: 12, pitch_rise_per_12: 6)
    assert_equal [], calc.errors
  end
end
