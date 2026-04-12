require "test_helper"

class Cooking::FreezerStorageCalculatorTest < ActiveSupport::TestCase
  test "happy path: beef steaks" do
    calc = Cooking::FreezerStorageCalculator.new(food_category: "beef", food_item: "steaks")
    result = calc.call

    assert result[:valid]
    assert_equal 12, result[:months]
    assert_equal 360, result[:days]
    assert result[:note].present?
    assert result[:general_tips].is_a?(Array)
    assert_equal 5, result[:general_tips].length
  end

  test "happy path: pork bacon" do
    calc = Cooking::FreezerStorageCalculator.new(food_category: "pork", food_item: "bacon")
    result = calc.call

    assert result[:valid]
    assert_equal 1, result[:months]
  end

  test "happy path: prepared foods soups" do
    calc = Cooking::FreezerStorageCalculator.new(food_category: "prepared_foods", food_item: "soups_stews")
    result = calc.call

    assert result[:valid]
    assert_equal 3, result[:months]
  end

  test "unknown category returns error" do
    calc = Cooking::FreezerStorageCalculator.new(food_category: "unknown", food_item: "steaks")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Unknown food category: unknown"
  end

  test "unknown item returns error" do
    calc = Cooking::FreezerStorageCalculator.new(food_category: "beef", food_item: "unknown")
    result = calc.call

    refute result[:valid]
    assert calc.errors.any? { |e| e.include?("Unknown food item") }
  end

  test "all_categories returns full data" do
    categories = Cooking::FreezerStorageCalculator.all_categories
    assert categories.key?("beef")
    assert categories.key?("poultry")
    assert categories.key?("seafood")
    assert categories.key?("dairy")
    assert categories.key?("fruits_vegetables")
    assert categories.key?("prepared_foods")
  end

  test "berries store for 12 months" do
    calc = Cooking::FreezerStorageCalculator.new(food_category: "fruits_vegetables", food_item: "berries")
    result = calc.call

    assert result[:valid]
    assert_equal 12, result[:months]
  end
end
