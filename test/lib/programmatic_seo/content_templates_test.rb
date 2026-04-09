require "test_helper"

class ProgrammaticSeo::ContentTemplatesTest < ActiveSupport::TestCase
  # Helper to build a page with a specific pattern_key for testing
  def build_page_with_pattern(pattern_key, category: "everyday")
    base_config = {
      category: category, controller: "test-calculator",
      noun: "test value", verb: "calculate test values"
    }
    pattern_config = ProgrammaticSeo::Generator::PATTERNS[pattern_key]
    ProgrammaticSeo::ContentTemplates.build_page("test", base_config, pattern_key, pattern_config)
  end

  # --- content_hash tests ---

  test "build_page includes content_hash key" do
    page = build_page_with_pattern(:per_month)
    assert page.key?(:content_hash), "Page should include :content_hash"
  end

  test "content_hash is an 8-character hex string" do
    page = build_page_with_pattern(:per_month)
    assert_match(/\A[0-9a-f]{8}\z/, page[:content_hash], "content_hash should be 8 hex chars")
  end

  test "content_hash differs between different pages" do
    page_a = build_page_with_pattern(:per_month)
    page_b = build_page_with_pattern(:per_year)
    refute_equal page_a[:content_hash], page_b[:content_hash],
      "Different pages should produce different content hashes"
  end

  test "content_hash is deterministic for the same inputs" do
    page_1 = build_page_with_pattern(:per_day)
    page_2 = build_page_with_pattern(:per_day)
    assert_equal page_1[:content_hash], page_2[:content_hash],
      "Same inputs should produce the same content hash"
  end

  # --- Pattern-specific FAQ tests ---

  test "per_ pattern adds per-unit FAQ entries" do
    page = build_page_with_pattern(:per_month)
    questions = page[:faq].map { |f| f[:question] }
    assert questions.any? { |q| q.include?("per-month rate") },
      "per_month pattern should add per-unit rate FAQ"
    assert questions.any? { |q| q.include?("per-month test value useful") },
      "per_month pattern should add per-unit tracking FAQ"
  end

  test "for_ pattern adds audience-specific FAQ entries" do
    page = build_page_with_pattern(:for_women, category: "health")
    questions = page[:faq].map { |f| f[:question] }
    assert questions.any? { |q| q.include?("different for women") },
      "for_women pattern should add audience-specific FAQ"
    assert questions.any? { |q| q.include?("women use the standard") },
      "for_women pattern should add standard vs specialized FAQ"
  end

  test "default pattern adds fallback FAQ entry" do
    page = build_page_with_pattern(:road_trip)
    questions = page[:faq].map { |f| f[:question] }
    assert questions.any? { |q| q.include?("should I use the") },
      "Default pattern should add a 'when to use' FAQ"
  end

  test "pattern-specific FAQs are appended after generic FAQs" do
    page = build_page_with_pattern(:per_month)
    # First 5 should be generic, additional ones should be pattern-specific
    assert page[:faq].length > 5, "Should have more than 5 FAQs with pattern-specific additions"
    # The first FAQ should be the generic "How do I calculate..." one
    assert page[:faq].first[:question].start_with?("How do I calculate"),
      "First FAQ should be the generic 'How do I calculate' question"
  end

  test "per_ pattern adds exactly 2 extra FAQs" do
    page = build_page_with_pattern(:per_month)
    assert_equal 7, page[:faq].length, "per_ pattern should have 5 generic + 2 pattern-specific FAQs"
  end

  test "for_ pattern adds exactly 2 extra FAQs" do
    page = build_page_with_pattern(:for_women, category: "health")
    assert_equal 7, page[:faq].length, "for_ pattern should have 5 generic + 2 pattern-specific FAQs"
  end

  test "default pattern adds exactly 1 extra FAQ" do
    page = build_page_with_pattern(:road_trip)
    assert_equal 6, page[:faq].length, "Default pattern should have 5 generic + 1 pattern-specific FAQ"
  end

  # --- Example with actual numbers tests ---

  test "finance example includes dollar amounts" do
    page = build_page_with_pattern(:per_month, category: "finance")
    scenario = page[:example][:scenario]
    steps = page[:example][:steps]
    assert scenario.include?("$250,000"), "Finance example scenario should include $250,000"
    assert steps.any? { |s| s.include?("6%") }, "Finance example steps should include 6%"
    assert steps.any? { |s| s.include?("5.5%") }, "Finance example steps should include comparison rate"
  end

  test "health example includes body measurements" do
    page = build_page_with_pattern(:for_women, category: "health")
    scenario = page[:example][:scenario]
    assert scenario.include?("30-year-old"), "Health example should include age"
    assert scenario.include?("178 cm"), "Health example should include height in cm"
    assert scenario.include?("75 kg"), "Health example should include weight in kg"
  end

  test "construction example includes room dimensions" do
    page = build_page_with_pattern(:per_room, category: "construction")
    scenario = page[:example][:scenario]
    assert scenario.include?("12 ft"), "Construction example should include room length"
    assert scenario.include?("14 ft"), "Construction example should include room width"
    assert scenario.include?("168 square feet"), "Construction example should include total area"
  end

  test "math example includes specific numbers" do
    page = build_page_with_pattern(:per_month, category: "math")
    scenario = page[:example][:scenario]
    steps = page[:example][:steps]
    assert scenario.include?("48"), "Math example scenario should include number 48"
    assert steps.any? { |s| s.include?("12") }, "Math example steps should include number 12"
  end

  test "physics example includes mass and velocity" do
    page = build_page_with_pattern(:per_month, category: "physics")
    scenario = page[:example][:scenario]
    assert scenario.include?("5 kg"), "Physics example should include mass"
    assert scenario.include?("10 m/s"), "Physics example should include velocity"
  end

  test "default category example has generic but structured steps" do
    page = build_page_with_pattern(:per_month, category: "everyday")
    steps = page[:example][:steps]
    assert_equal 4, steps.length, "Example should have 4 steps"
    assert steps.first.include?("primary value"), "First step should mention primary value"
  end

  test "example steps contain numbers for all specific categories" do
    %w[finance health construction math physics].each do |cat|
      page = build_page_with_pattern(:per_month, category: cat)
      steps = page[:example][:steps]
      assert steps.any? { |s| s.match?(/\d/) },
        "#{cat} example steps should contain actual numbers"
    end
  end
end
