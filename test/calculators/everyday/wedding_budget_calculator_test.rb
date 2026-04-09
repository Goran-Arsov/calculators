require "test_helper"

class Everyday::WeddingBudgetCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "budget=30000, guests=150 → per_guest=200, venue=9000, catering=7500" do
    result = Everyday::WeddingBudgetCalculator.new(total_budget: 30000, guest_count: 150).call
    assert_equal true, result[:valid]
    assert_equal 200.0, result[:per_guest_cost]
    assert_equal 9000.0, result[:venue_budget]
    assert_equal 7500.0, result[:catering_budget]
    assert_equal 3600.0, result[:photography_budget]
    assert_equal 2400.0, result[:flowers_budget]
    assert_equal 2100.0, result[:music_budget]
    assert_equal 1800.0, result[:attire_budget]
    assert_equal 900.0, result[:stationery_budget]
    assert_equal 2700.0, result[:other_budget]
  end

  test "small budget with single guest" do
    result = Everyday::WeddingBudgetCalculator.new(total_budget: 10000, guest_count: 1).call
    assert_equal true, result[:valid]
    assert_equal 10000.0, result[:per_guest_cost]
  end

  test "budget breakdown percentages sum to 100%" do
    result = Everyday::WeddingBudgetCalculator.new(total_budget: 50000, guest_count: 100).call
    total = result[:venue_budget] + result[:catering_budget] + result[:photography_budget] +
            result[:flowers_budget] + result[:music_budget] + result[:attire_budget] +
            result[:stationery_budget] + result[:other_budget]
    assert_in_delta 50000.0, total, 0.01
  end

  test "handles string inputs" do
    result = Everyday::WeddingBudgetCalculator.new(total_budget: "25000", guest_count: "100").call
    assert_equal true, result[:valid]
    assert_equal 250.0, result[:per_guest_cost]
  end

  # --- Validation errors ---

  test "error when budget is zero" do
    result = Everyday::WeddingBudgetCalculator.new(total_budget: 0, guest_count: 100).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Total budget must be greater than zero"
  end

  test "error when guest count is zero" do
    result = Everyday::WeddingBudgetCalculator.new(total_budget: 30000, guest_count: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Guest count must be at least 1"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::WeddingBudgetCalculator.new(total_budget: 30000, guest_count: 100)
    assert_equal [], calc.errors
  end
end
