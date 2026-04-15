require "test_helper"

class Construction::PlywoodSheetsCalculatorTest < ActiveSupport::TestCase
  test "20x10 surface at 4x8 sheets" do
    result = Construction::PlywoodSheetsCalculator.new(
      length_ft: 20, width_ft: 10, sheet_type: "4x8", waste_pct: 0
    ).call
    assert_equal true, result[:valid]
    # 20*10 = 200 sq ft / 32 sq ft per sheet = 6.25 → 7 full sheets
    assert_equal 7, result[:full_sheets]
  end

  test "waste rounds up sheets" do
    result = Construction::PlywoodSheetsCalculator.new(
      length_ft: 20, width_ft: 10, sheet_type: "4x8", waste_pct: 10
    ).call
    # 6.25 * 1.10 = 6.875 → ceil 7
    assert_equal 7, result[:sheets_with_waste]
  end

  test "larger sheets use fewer units" do
    r_4x8 = Construction::PlywoodSheetsCalculator.new(
      length_ft: 40, width_ft: 20, sheet_type: "4x8", waste_pct: 0
    ).call
    r_5x10 = Construction::PlywoodSheetsCalculator.new(
      length_ft: 40, width_ft: 20, sheet_type: "5x10", waste_pct: 0
    ).call
    # 5x10 = 50 sq ft > 4x8 = 32 sq ft, so fewer needed
    assert r_5x10[:full_sheets] < r_4x8[:full_sheets]
  end

  test "sheet label is returned" do
    result = Construction::PlywoodSheetsCalculator.new(
      length_ft: 20, width_ft: 10, sheet_type: "4x10"
    ).call
    assert_match(/4 × 10/, result[:sheet_label])
  end

  test "error when length is zero" do
    result = Construction::PlywoodSheetsCalculator.new(
      length_ft: 0, width_ft: 10
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "error for invalid sheet type" do
    result = Construction::PlywoodSheetsCalculator.new(
      length_ft: 20, width_ft: 10, sheet_type: "bogus"
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.start_with?("Sheet type must") }
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::PlywoodSheetsCalculator.new(length_ft: 20, width_ft: 10)
    assert_equal [], calc.errors
  end
end
