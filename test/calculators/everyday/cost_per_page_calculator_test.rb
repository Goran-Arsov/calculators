require "test_helper"

class Everyday::CostPerPageCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "$30 cartridge, 500 pages = $0.06/page" do
    result = Everyday::CostPerPageCalculator.new(cartridge_cost: 30, page_yield: 500).call
    assert_nil result[:errors]
    assert_equal 0.06, result[:cost_per_page]
    assert_equal 6.0, result[:cost_per_100_pages]
  end

  test "monthly cost projection" do
    result = Everyday::CostPerPageCalculator.new(cartridge_cost: 30, page_yield: 500, pages_per_month: 200).call
    assert_nil result[:errors]
    assert_equal 12.0, result[:monthly_cost]
    assert_equal 144.0, result[:yearly_cost]
    assert_equal 4.8, result[:cartridges_per_year]
  end

  test "no monthly data when pages_per_month is zero" do
    result = Everyday::CostPerPageCalculator.new(cartridge_cost: 30, page_yield: 500, pages_per_month: 0).call
    assert_nil result[:errors]
    assert_nil result[:monthly_cost]
    assert_nil result[:yearly_cost]
  end

  test "expensive cartridge with high yield" do
    result = Everyday::CostPerPageCalculator.new(cartridge_cost: 100, page_yield: 10000).call
    assert_nil result[:errors]
    assert_equal 0.01, result[:cost_per_page]
    assert_equal 1.0, result[:cost_per_100_pages]
  end

  test "returns cartridge cost and page yield" do
    result = Everyday::CostPerPageCalculator.new(cartridge_cost: 25, page_yield: 250).call
    assert_nil result[:errors]
    assert_equal 25.0, result[:cartridge_cost]
    assert_equal 250, result[:page_yield]
  end

  # --- Validation errors ---

  test "error when cartridge cost is zero" do
    result = Everyday::CostPerPageCalculator.new(cartridge_cost: 0, page_yield: 500).call
    assert result[:errors].any?
    assert_includes result[:errors], "Cartridge cost must be greater than zero"
  end

  test "error when page yield is zero" do
    result = Everyday::CostPerPageCalculator.new(cartridge_cost: 30, page_yield: 0).call
    assert result[:errors].any?
    assert_includes result[:errors], "Page yield must be greater than zero"
  end

  test "error when pages per month is negative" do
    result = Everyday::CostPerPageCalculator.new(cartridge_cost: 30, page_yield: 500, pages_per_month: -10).call
    assert result[:errors].any?
    assert_includes result[:errors], "Pages per month cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::CostPerPageCalculator.new(cartridge_cost: "30", page_yield: "500").call
    assert_nil result[:errors]
    assert_equal 0.06, result[:cost_per_page]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::CostPerPageCalculator.new(cartridge_cost: 30, page_yield: 500)
    assert_equal [], calc.errors
  end

  test "very cheap per-page cost" do
    result = Everyday::CostPerPageCalculator.new(cartridge_cost: 50, page_yield: 50000).call
    assert_nil result[:errors]
    assert_equal 0.001, result[:cost_per_page]
  end

  test "multiple errors returned at once" do
    result = Everyday::CostPerPageCalculator.new(cartridge_cost: 0, page_yield: 0).call
    assert_equal 2, result[:errors].size
  end
end
