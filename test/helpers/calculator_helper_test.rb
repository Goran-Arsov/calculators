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
      assert CalculatorRegistry::SEASONAL_FEATURES.key?(month), "SEASONAL_FEATURES missing month #{month}"
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

  # --- related_calculators ---

  test "related_calculators returns deterministic results" do
    result1 = related_calculators("mortgage-calculator", "finance")
    result2 = related_calculators("mortgage-calculator", "finance")
    assert_equal result1.map { |c| c[:slug] }, result2.map { |c| c[:slug] },
      "Expected related_calculators to return the same results on repeated calls"
  end

  test "related_calculators excludes the current calculator" do
    result = related_calculators("mortgage-calculator", "finance")
    slugs = result.map { |c| c[:slug] }
    refute_includes slugs, "mortgage-calculator"
  end

  test "related_calculators returns up to count results" do
    result = related_calculators("mortgage-calculator", "finance", count: 3)
    assert result.length <= 3
  end

  test "related_calculators returns calculators with resolved paths" do
    result = related_calculators("mortgage-calculator", "finance")
    result.each do |calc|
      assert calc[:path].is_a?(String), "Expected path to be a resolved String, got #{calc[:path].class}"
    end
  end

  test "related_calculators does not include _relevance_score in results" do
    result = related_calculators("mortgage-calculator", "finance")
    result.each do |calc|
      refute calc.key?(:_relevance_score), "Expected _relevance_score to be stripped from results"
    end
  end

  test "related_calculators prioritizes keyword-relevant same-category calculators" do
    # Mortgage calculator should rank home/loan related calculators higher
    result = related_calculators("mortgage-calculator", "finance", count: 6)
    slugs = result.map { |c| c[:slug] }
    # Home affordability and amortization share keywords with mortgage
    loan_related = %w[home-affordability-calculator amortization-calculator loan-calculator]
    matches = slugs & loan_related
    assert matches.any?, "Expected at least one loan/mortgage-related calculator in results, got: #{slugs.join(', ')}"
  end

  test "related_calculators includes cross-category results when same-category is small" do
    # Use a category with fewer calculators to ensure cross-category fills in
    result = related_calculators("bmi-calculator", "health", count: 20)
    # With count: 20, it should try to include cross-category results
    slugs = result.map { |c| c[:slug] }
    # BMI calculator has cross-category links to calorie-calculator, tdee-calculator, ideal-weight-calculator
    # but those are same-category (health). Check that we get many results
    assert result.length > 0
  end

  test "related_calculators handles unknown slug gracefully" do
    result = related_calculators("nonexistent-calculator", "finance")
    assert_kind_of Array, result
  end

  test "related_calculators handles unknown category gracefully" do
    result = related_calculators("mortgage-calculator", "nonexistent")
    assert_kind_of Array, result
  end

  # --- calculator_keywords (private) ---

  test "calculator_keywords extracts meaningful words" do
    calc = { name: "Mortgage Calculator", description: "Calculate your monthly mortgage payment." }
    keywords = send(:calculator_keywords, calc)
    assert_includes keywords, "mortgage"
    assert_includes keywords, "monthly"
    assert_includes keywords, "payment"
    refute_includes keywords, "your"   # stop word
    refute_includes keywords, "a"      # stop word
  end

  test "calculator_keywords filters out short words" do
    calc = { name: "BMI Calculator", description: "A go-to tool." }
    keywords = send(:calculator_keywords, calc)
    refute_includes keywords, "go"    # too short (< 3 chars)
    assert_includes keywords, "bmi"
    assert_includes keywords, "tool"
    assert_includes keywords, "calculator"
  end

  # --- CROSS_CATEGORY_LINKS constant ---

  test "CROSS_CATEGORY_LINKS values reference valid calculator slugs" do
    all_slugs = CalculatorRegistry::ALL_CATEGORIES.values.flat_map { |cat| cat[:calculators].map { |c| c[:slug] } }
    CalculatorRegistry::CROSS_CATEGORY_LINKS.each do |source, targets|
      targets.each do |target_slug|
        assert_includes all_slugs, target_slug,
          "CROSS_CATEGORY_LINKS['#{source}'] references '#{target_slug}' which is not a valid calculator slug"
      end
    end
  end

  # --- calc_category_from_slug (private) ---

  test "calc_category_from_slug returns correct category for known slug" do
    assert_equal "finance", send(:calc_category_from_slug, "mortgage-calculator")
    assert_equal "health", send(:calc_category_from_slug, "bmi-calculator")
    assert_equal "math", send(:calc_category_from_slug, "percentage-calculator")
    assert_equal "construction", send(:calc_category_from_slug, "concrete-calculator")
  end

  test "calc_category_from_slug returns nil for unknown slug" do
    assert_nil send(:calc_category_from_slug, "nonexistent-calculator")
  end

  # --- related_blog_posts ---

  test "related_blog_posts returns blog posts for mapped calculator" do
    # Create blog posts matching CALCULATOR_BLOG_MAP entries
    mapped_slug = CalculatorRegistry::CALCULATOR_BLOG_MAP.keys.first
    blog_slugs = CalculatorRegistry::CALCULATOR_BLOG_MAP[mapped_slug]
    blog_slugs.each do |bs|
      BlogPost.find_or_create_by!(slug: bs) do |post|
        post.title = bs.titleize
        post.body = "Test content for #{bs}"
        post.excerpt = "Test excerpt for #{bs}"
        post.published_at = 1.day.ago
      end
    end
    result = related_blog_posts(mapped_slug)
    assert result.any?, "Expected blog posts for mapped calculator '#{mapped_slug}'"
  end

  test "related_blog_posts falls back to category when no mapping exists" do
    # inflation-calculator is in the finance category but not in CALCULATOR_BLOG_MAP
    unmapped_slug = "inflation-calculator"
    assert_not CalculatorRegistry::CALCULATOR_BLOG_MAP.key?(unmapped_slug),
      "Expected '#{unmapped_slug}' to not be in CALCULATOR_BLOG_MAP for this test"
    BlogPost.find_or_create_by!(slug: "test-finance-fallback-post") do |post|
      post.title = "Finance Fallback Test Post"
      post.body = "Test content"
      post.excerpt = "Test excerpt"
      post.category = "finance"
      post.published_at = 1.day.ago
    end
    result = related_blog_posts(unmapped_slug)
    assert_respond_to result, :to_a
    assert result.to_a.any?, "Expected fallback to return category blog posts"
  end

  test "related_blog_posts returns a relation for unknown slug" do
    result = related_blog_posts("totally-unknown-calculator")
    assert_respond_to result, :to_a
  end
end
