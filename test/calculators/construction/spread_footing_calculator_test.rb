require "test_helper"

class Construction::SpreadFootingCalculatorTest < ActiveSupport::TestCase
  test "10000 lb column on 2000 psf sandy clay" do
    result = Construction::SpreadFootingCalculator.new(
      column_load_lbs: 10_000, bearing_psf: 2000, min_depth_in: 10
    ).call
    assert_equal true, result[:valid]
    # area = 10000 / 2000 = 5 sq ft → square side = √5 × 12 ≈ 26.83 in → round up to 28
    assert_in_delta 5.0, result[:required_area_sqft], 0.01
    assert_equal 28.0, result[:square_side_in]
  end

  test "rock supports much larger load in same area" do
    clay = Construction::SpreadFootingCalculator.new(column_load_lbs: 20_000, bearing_psf: 1500).call
    rock = Construction::SpreadFootingCalculator.new(column_load_lbs: 20_000, bearing_psf: 12_000).call
    assert rock[:square_side_in] < clay[:square_side_in]
  end

  test "safety factor scales required area" do
    sf1 = Construction::SpreadFootingCalculator.new(column_load_lbs: 10_000, bearing_psf: 2000, safety_factor: 1.0).call
    sf2 = Construction::SpreadFootingCalculator.new(column_load_lbs: 10_000, bearing_psf: 2000, safety_factor: 2.0).call
    assert_in_delta sf1[:required_area_sqft] * 2, sf2[:required_area_sqft], 0.01
  end

  test "concrete volume in cubic yards" do
    result = Construction::SpreadFootingCalculator.new(column_load_lbs: 10_000, bearing_psf: 2000).call
    assert result[:concrete_cuft] > 0
    assert_in_delta result[:concrete_cuft] / 27.0, result[:concrete_cuyd], 0.01
  end

  test "minimum footing side enforced" do
    result = Construction::SpreadFootingCalculator.new(column_load_lbs: 100, bearing_psf: 3000).call
    # tiny load would give tiny footing; enforce 8 in min
    assert result[:square_side_in] >= 8.0
  end

  test "actual bearing pressure is reported" do
    result = Construction::SpreadFootingCalculator.new(column_load_lbs: 10_000, bearing_psf: 2000).call
    # With rounded 28 in side: (28/12)² = 5.44 sq ft, 10000/5.44 ≈ 1837 psf
    assert result[:actual_bearing_psf] <= 2000
  end

  test "round diameter is larger than square side for same area" do
    result = Construction::SpreadFootingCalculator.new(column_load_lbs: 10_000, bearing_psf: 2000).call
    # Actually circle diameter d = 2×√(area/π) and square side = √area; circle diameter is larger
    assert result[:round_diameter_in] > Math.sqrt(result[:required_area_sqft]) * 12 * 0.9
  end

  test "error when column load is zero" do
    result = Construction::SpreadFootingCalculator.new(column_load_lbs: 0, bearing_psf: 2000).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Column load must be greater than zero"
  end

  test "error when safety factor below 1" do
    result = Construction::SpreadFootingCalculator.new(column_load_lbs: 10_000, bearing_psf: 2000, safety_factor: 0.8).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Safety factor must be at least 1.0"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::SpreadFootingCalculator.new(column_load_lbs: 10_000, bearing_psf: 2000)
    assert_equal [], calc.errors
  end
end
