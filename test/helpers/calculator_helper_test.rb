require "test_helper"

class CalculatorHelperTest < ActionView::TestCase
  include CalculatorHelper

  # --- seasonal_calculators ---

  test "seasonal_calculators returns up to count calculators" do
    result = seasonal_calculators(count: 3)
    assert_kind_of Array, result
    assert result.length <= 3
  end

  test "seasonal_calculators returns calculators with path resolved" do
    result = seasonal_calculators(count: 3)
    result.each do |calc|
      assert calc[:path].is_a?(String), "Expected path to be a resolved String, got #{calc[:path].class}"
    end
  end

  test "seasonal_calculators returns different calculators per month" do
    # Verify that the SEASONAL_FEATURES constant covers all 12 months
    (1..12).each do |month|
      assert CalculatorHelper::SEASONAL_FEATURES.key?(month), "SEASONAL_FEATURES missing month #{month}"
    end
  end

  # --- cross_category_calculators ---

  test "cross_category_calculators returns results for mapped slug" do
    result = cross_category_calculators("mortgage-calculator")
    assert result.length > 0
    assert result.length <= 3
  end

  test "cross_category_calculators returns empty array for unknown slug" do
    result = cross_category_calculators("nonexistent-calculator")
    assert_equal [], result
  end

  test "cross_category_calculators returns calculators with resolved paths" do
    result = cross_category_calculators("bmi-calculator")
    result.each do |calc|
      assert calc[:path].is_a?(String), "Expected path to be a resolved String, got #{calc[:path].class}"
    end
  end

  test "cross_category_calculators respects count parameter" do
    result = cross_category_calculators("mortgage-calculator", count: 1)
    assert result.length <= 1
  end

  # --- CROSS_CATEGORY_LINKS constant ---

  test "CROSS_CATEGORY_LINKS values reference valid calculator slugs" do
    all_slugs = ALL_CATEGORIES.values.flat_map { |cat| cat[:calculators].map { |c| c[:slug] } }
    CalculatorHelper::CROSS_CATEGORY_LINKS.each do |source, targets|
      targets.each do |target_slug|
        assert_includes all_slugs, target_slug,
          "CROSS_CATEGORY_LINKS['#{source}'] references '#{target_slug}' which is not a valid calculator slug"
      end
    end
  end
end
