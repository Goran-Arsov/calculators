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
    CalculatorRating.create!(calculator_slug: "test-calc", direction: "up", ip_hash: "hash1")
    CalculatorRating.create!(calculator_slug: "test-calc", direction: "up", ip_hash: "hash2")
    CalculatorRating.create!(calculator_slug: "test-calc", direction: "up", ip_hash: "hash3")

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
end
