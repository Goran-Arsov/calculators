require "test_helper"

class Construction::AtticVentilationCalculatorTest < ActiveSupport::TestCase
  test "1800 sqft attic with 1:300 balanced method" do
    result = Construction::AtticVentilationCalculator.new(
      attic_sqft: 1800, method: "balanced_1_300"
    ).call
    assert_equal true, result[:valid]
    # 1800/300 = 6 sqft NFA total = 864 sq in
    assert_in_delta 6.0, result[:total_nfa_sqft], 0.01
    assert_in_delta 864.0, result[:total_nfa_sqin], 0.1
    assert_in_delta 432.0, result[:intake_nfa_sqin], 0.1
    assert_in_delta 432.0, result[:exhaust_nfa_sqin], 0.1
  end

  test "1:150 method doubles the requirement" do
    balanced = Construction::AtticVentilationCalculator.new(
      attic_sqft: 1800, method: "balanced_1_300"
    ).call
    unbalanced = Construction::AtticVentilationCalculator.new(
      attic_sqft: 1800, method: "unbalanced_1_150"
    ).call
    assert_in_delta balanced[:total_nfa_sqft] * 2, unbalanced[:total_nfa_sqft], 0.01
  end

  test "soffit pieces count rounds up" do
    result = Construction::AtticVentilationCalculator.new(
      attic_sqft: 1800, method: "balanced_1_300",
      soffit_nfa_per_piece: 65
    ).call
    # intake 432 / 65 = 6.64 → 7
    assert_equal 7, result[:soffit_vent_pieces]
  end

  test "ridge vent feet calculation" do
    result = Construction::AtticVentilationCalculator.new(
      attic_sqft: 1800, method: "balanced_1_300",
      ridge_vent_nfa_per_foot: 18
    ).call
    # exhaust 432 / 18 = 24
    assert_equal 24, result[:ridge_vent_feet]
  end

  test "zero area errors" do
    result = Construction::AtticVentilationCalculator.new(
      attic_sqft: 0, method: "balanced_1_300"
    ).call
    assert_equal false, result[:valid]
  end

  test "invalid method errors" do
    result = Construction::AtticVentilationCalculator.new(
      attic_sqft: 1800, method: "magic"
    ).call
    assert_equal false, result[:valid]
  end
end
