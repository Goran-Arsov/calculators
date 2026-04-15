require "test_helper"

class Construction::StaticPressureCalculatorTest < ActiveSupport::TestCase
  test "typical 400 CFM 8 in duct 50 ft" do
    result = Construction::StaticPressureCalculator.new(
      cfm: 400, duct_length_ft: 50, duct_diameter_in: 8,
      fittings: 3, merv: 8
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:total_static_iwc] > 0
    assert result[:duct_drop_iwc] > 0
  end

  test "higher CFM increases friction" do
    low = Construction::StaticPressureCalculator.new(cfm: 300, duct_length_ft: 50, duct_diameter_in: 8).call
    high = Construction::StaticPressureCalculator.new(cfm: 800, duct_length_ft: 50, duct_diameter_in: 8).call
    assert high[:total_static_iwc] > low[:total_static_iwc]
  end

  test "larger duct reduces friction" do
    small = Construction::StaticPressureCalculator.new(cfm: 400, duct_length_ft: 50, duct_diameter_in: 6).call
    large = Construction::StaticPressureCalculator.new(cfm: 400, duct_length_ft: 50, duct_diameter_in: 12).call
    assert large[:total_static_iwc] < small[:total_static_iwc]
  end

  test "MERV 13 has higher filter drop than MERV 8" do
    low = Construction::StaticPressureCalculator.new(cfm: 400, duct_length_ft: 50, duct_diameter_in: 8, merv: 8).call
    high = Construction::StaticPressureCalculator.new(cfm: 400, duct_length_ft: 50, duct_diameter_in: 8, merv: 13).call
    assert high[:filter_drop_iwc] > low[:filter_drop_iwc]
  end

  test "fittings add to total" do
    no_fittings = Construction::StaticPressureCalculator.new(cfm: 400, duct_length_ft: 50, duct_diameter_in: 8, fittings: 0).call
    with_fittings = Construction::StaticPressureCalculator.new(cfm: 400, duct_length_ft: 50, duct_diameter_in: 8, fittings: 5).call
    assert with_fittings[:total_static_iwc] > no_fittings[:total_static_iwc]
  end

  test "total in Pa conversion" do
    result = Construction::StaticPressureCalculator.new(cfm: 400, duct_length_ft: 50, duct_diameter_in: 8).call
    assert_in_delta result[:total_static_iwc] * 249.089, result[:total_static_pa], 1
  end

  test "flags over 0.5 iwc" do
    bad = Construction::StaticPressureCalculator.new(cfm: 1000, duct_length_ft: 100, duct_diameter_in: 6, merv: 13).call
    assert bad[:over_0_5]
  end

  test "error when CFM is zero" do
    result = Construction::StaticPressureCalculator.new(cfm: 0, duct_length_ft: 50, duct_diameter_in: 8).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "CFM must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::StaticPressureCalculator.new(cfm: 400, duct_length_ft: 50, duct_diameter_in: 8)
    assert_equal [], calc.errors
  end
end
