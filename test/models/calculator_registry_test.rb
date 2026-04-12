require "test_helper"

class CalculatorRegistryTest < ActiveSupport::TestCase
  test "ALL_CATEGORIES contains all categories" do
    expected = %w[finance math physics health construction textile everyday alcohol geography gardening relationships photography education pets cooking]
    assert_equal expected.sort, CalculatorRegistry::ALL_CATEGORIES.keys.sort
  end

  test "each category has title, description, and calculators" do
    CalculatorRegistry::ALL_CATEGORIES.each do |slug, category|
      assert category[:title].present?, "#{slug} missing title"
      assert category[:description].present?, "#{slug} missing description"
      assert category[:calculators].is_a?(Array), "#{slug} calculators should be an Array"
      assert category[:calculators].any?, "#{slug} should have at least one calculator"
    end
  end

  test "all_calculators returns a flat array of all calculators" do
    all = CalculatorRegistry.all_calculators
    assert all.is_a?(Array)
    assert all.length > 50, "Expected many calculators, got #{all.length}"

    total_from_categories = CalculatorRegistry::ALL_CATEGORIES.values.sum { |c| c[:calculators].length }
    assert_equal total_from_categories, all.length
  end

  test "find_by_slug returns matching calculator" do
    result = CalculatorRegistry.find_by_slug("mortgage-calculator")
    assert_not_nil result
    assert_equal "Mortgage Calculator", result[:name]
  end

  test "find_by_slug returns nil for unknown slug" do
    assert_nil CalculatorRegistry.find_by_slug("nonexistent-calculator")
  end

  test "calculators_for_category returns calculators for valid category" do
    calcs = CalculatorRegistry.calculators_for_category("finance")
    assert calcs.is_a?(Array)
    assert calcs.any?
    assert_equal CalculatorRegistry::FINANCE_CALCULATORS, calcs
  end

  test "calculators_for_category returns empty array for invalid category" do
    assert_equal [], CalculatorRegistry.calculators_for_category("nonexistent")
  end

  test "every calculator has required keys" do
    required_keys = %i[name slug path description icon_path]
    CalculatorRegistry.all_calculators.each do |calc|
      required_keys.each do |key|
        assert calc.key?(key), "Calculator '#{calc[:name] || calc[:slug]}' missing key :#{key}"
      end
    end
  end

  test "IT_TOOL_SLUGS is a frozen array of strings" do
    assert CalculatorRegistry::IT_TOOL_SLUGS.frozen?
    assert CalculatorRegistry::IT_TOOL_SLUGS.all? { |s| s.is_a?(String) }
  end

  test "SEASONAL_FEATURES covers all 12 months" do
    (1..12).each do |month|
      assert CalculatorRegistry::SEASONAL_FEATURES.key?(month),
        "SEASONAL_FEATURES missing month #{month}"
    end
  end

  test "CROSS_CATEGORY_LINKS values reference valid calculator slugs" do
    all_slugs = CalculatorRegistry.all_calculators.map { |c| c[:slug] }
    CalculatorRegistry::CROSS_CATEGORY_LINKS.each do |source, targets|
      targets.each do |target_slug|
        assert_includes all_slugs, target_slug,
          "CROSS_CATEGORY_LINKS['#{source}'] references '#{target_slug}' which is not a valid calculator slug"
      end
    end
  end

  test "CALCULATOR_BLOG_MAP keys are valid calculator slugs" do
    all_slugs = CalculatorRegistry.all_calculators.map { |c| c[:slug] }
    CalculatorRegistry::CALCULATOR_BLOG_MAP.each_key do |key|
      assert_includes all_slugs, key,
        "CALCULATOR_BLOG_MAP key '#{key}' is not a valid calculator slug"
    end
  end

  # --- NEXT_STEPS constant ---

  test "NEXT_STEPS is a frozen hash" do
    assert CalculatorRegistry::NEXT_STEPS.frozen?
    assert CalculatorRegistry::NEXT_STEPS.is_a?(Hash)
  end

  test "NEXT_STEPS keys are valid calculator slugs" do
    all_slugs = CalculatorRegistry.all_calculators.map { |c| c[:slug] }
    CalculatorRegistry::NEXT_STEPS.each_key do |key|
      assert_includes all_slugs, key,
        "NEXT_STEPS key '#{key}' is not a valid calculator slug"
    end
  end

  test "NEXT_STEPS values reference valid calculator slugs" do
    all_slugs = CalculatorRegistry.all_calculators.map { |c| c[:slug] }
    CalculatorRegistry::NEXT_STEPS.each do |source, steps|
      assert steps.is_a?(Array), "NEXT_STEPS['#{source}'] should be an Array"
      steps.each do |step|
        assert step.key?(:slug), "NEXT_STEPS['#{source}'] step missing :slug"
        assert step.key?(:label), "NEXT_STEPS['#{source}'] step missing :label"
        assert_includes all_slugs, step[:slug],
          "NEXT_STEPS['#{source}'] references '#{step[:slug]}' which is not a valid calculator slug"
      end
    end
  end

  test "NEXT_STEPS does not reference the source calculator in its own steps" do
    CalculatorRegistry::NEXT_STEPS.each do |source, steps|
      step_slugs = steps.map { |s| s[:slug] }
      refute_includes step_slugs, source,
        "NEXT_STEPS['#{source}'] should not reference itself"
    end
  end
end
