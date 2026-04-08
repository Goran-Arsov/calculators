require "test_helper"

class SeoHelperTest < ActionView::TestCase
  include SeoHelper

  test "calculator_schema_with_ratings returns schema script tag" do
    result = calculator_schema_with_ratings(
      name: "Test Calculator",
      description: "A test calculator",
      url: "https://calcwise.com/test",
      category: "Test",
      calculator_slug: "nonexistent-slug"
    )
    assert_match %r{application/ld\+json}, result
    assert_match %r{SoftwareApplication}, result
  end

  test "calculator_schema_with_ratings includes rating when data exists" do
    CalculatorRating.create!(calculator_slug: "test-calc", direction: "up", score: 5, ip_hash: "hash1")
    CalculatorRating.create!(calculator_slug: "test-calc", direction: "up", score: 4, ip_hash: "hash2")
    CalculatorRating.create!(calculator_slug: "test-calc", direction: "up", score: 5, ip_hash: "hash3")

    result = calculator_schema_with_ratings(
      name: "Test Calculator",
      description: "A test calculator",
      url: "https://calcwise.com/test",
      category: "Test",
      calculator_slug: "test-calc"
    )
    assert_match %r{aggregateRating}, result
    assert_match %r{ratingCount}, result
  end

  test "calculator_schema_with_ratings omits rating when no data" do
    result = calculator_schema_with_ratings(
      name: "Test Calculator",
      description: "A test calculator",
      url: "https://calcwise.com/test",
      category: "Test",
      calculator_slug: "no-ratings-slug"
    )
    assert_no_match %r{aggregateRating}, result
  end

  test "organization_schema returns Organization JSON-LD script tag" do
    result = organization_schema
    assert_match %r{application/ld\+json}, result
    assert_match %r{"@type":"Organization"}, result
    assert_match %r{"name":"CalcWise"}, result
    assert_match %r{/icon\.png}, result
    assert_match %r{"sameAs":\[\]}, result
  end

  test "set_meta_tags_for_calculator without updated_at does not include article tag" do
    captured_tags = nil
    stub_method = ->(tags) { captured_tags = tags }
    self.define_singleton_method(:set_meta_tags, stub_method)

    set_meta_tags_for_calculator(
      title: "Test",
      description: "A test",
      url: "https://calcwise.com/test",
      category: "finance"
    )
    assert_equal "Test", captured_tags[:title]
    assert_nil captured_tags[:article]
  end

  test "set_meta_tags_for_calculator with updated_at includes article modified_time" do
    captured_tags = nil
    stub_method = ->(tags) { captured_tags = tags }
    self.define_singleton_method(:set_meta_tags, stub_method)

    timestamp = Time.utc(2026, 4, 1, 12, 0, 0)
    set_meta_tags_for_calculator(
      title: "Test",
      description: "A test",
      url: "https://calcwise.com/test",
      category: "finance",
      updated_at: timestamp
    )
    assert_equal({ modified_time: "2026-04-01T12:00:00Z" }, captured_tags[:article])
  end

  test "breadcrumb_schema returns valid JSON-LD with BreadcrumbList type" do
    items = [
      { name: "Home", url: "https://calcwise.com/" },
      { name: "Finance", url: "https://calcwise.com/finance" },
      { name: "Mortgage Calculator" }
    ]
    result = breadcrumb_schema(items)
    assert_match %r{application/ld\+json}, result
    parsed = JSON.parse(result.match(/>(.+)</m)[1])
    assert_equal "https://schema.org", parsed["@context"]
    assert_equal "BreadcrumbList", parsed["@type"]
    assert_equal 3, parsed["itemListElement"].length
    assert_equal 1, parsed["itemListElement"][0]["position"]
    assert_equal "Home", parsed["itemListElement"][0]["name"]
    assert_equal "https://calcwise.com/", parsed["itemListElement"][0]["item"]
    assert_nil parsed["itemListElement"][2]["item"], "Last breadcrumb item should not have a URL"
  end

  test "faq_schema returns valid JSON-LD with FAQPage type" do
    questions = [
      { question: "What is a mortgage?", answer: "A mortgage is a loan for buying property." },
      { question: "How do I calculate interest?", answer: "Multiply principal by rate and time." }
    ]
    result = faq_schema(questions)
    assert_match %r{application/ld\+json}, result
    parsed = JSON.parse(result.match(/>(.+)</m)[1])
    assert_equal "https://schema.org", parsed["@context"]
    assert_equal "FAQPage", parsed["@type"]
    assert_equal 2, parsed["mainEntity"].length
    assert_equal "Question", parsed["mainEntity"][0]["@type"]
    assert_equal "What is a mortgage?", parsed["mainEntity"][0]["name"]
    assert_equal "Answer", parsed["mainEntity"][0]["acceptedAnswer"]["@type"]
    assert_equal "A mortgage is a loan for buying property.", parsed["mainEntity"][0]["acceptedAnswer"]["text"]
  end

  test "calculator_schema includes all required fields" do
    result = calculator_schema(
      name: "Mortgage Calculator",
      description: "Calculate mortgage payments",
      url: "https://calcwise.com/finance/mortgage-calculator",
      category: "Finance"
    )
    assert_match %r{application/ld\+json}, result
    parsed = JSON.parse(result.match(/>(.+)</m)[1])
    assert_equal "https://schema.org", parsed["@context"]
    assert_equal "SoftwareApplication", parsed["@type"]
    assert_equal "Mortgage Calculator", parsed["name"]
    assert_equal "Calculate mortgage payments", parsed["description"]
    assert_equal "https://calcwise.com/finance/mortgage-calculator", parsed["url"]
    assert_equal "Finance", parsed["applicationCategory"]
    assert_equal "Web", parsed["operatingSystem"]
    assert_equal "Offer", parsed["offers"]["@type"]
    assert_equal "0", parsed["offers"]["price"]
    assert_equal "USD", parsed["offers"]["priceCurrency"]
  end

  test "calculator_schema includes aggregate rating when provided" do
    result = calculator_schema(
      name: "BMI Calculator",
      description: "Calculate BMI",
      url: "https://calcwise.com/health/bmi-calculator",
      category: "Health",
      rating_value: 4.5,
      rating_count: 120
    )
    parsed = JSON.parse(result.match(/>(.+)</m)[1])
    assert_equal "AggregateRating", parsed["aggregateRating"]["@type"]
    assert_equal 4.5, parsed["aggregateRating"]["ratingValue"]
    assert_equal 120, parsed["aggregateRating"]["ratingCount"]
    assert_equal "5", parsed["aggregateRating"]["bestRating"]
    assert_equal "1", parsed["aggregateRating"]["worstRating"]
  end

  test "calculator_schema omits aggregate rating when not provided" do
    result = calculator_schema(
      name: "Test Calc",
      description: "Test",
      url: "https://calcwise.com/test",
      category: "Test"
    )
    parsed = JSON.parse(result.match(/>(.+)</m)[1])
    assert_nil parsed["aggregateRating"]
  end

  test "organization_schema returns valid JSON-LD" do
    result = organization_schema
    parsed = JSON.parse(result.match(/>(.+)</m)[1])
    assert_equal "https://schema.org", parsed["@context"]
    assert_equal "Organization", parsed["@type"]
    assert_equal "CalcWise", parsed["name"]
    assert_match %r{/icon\.png}, parsed["logo"]
    assert_kind_of Array, parsed["sameAs"]
  end
end
