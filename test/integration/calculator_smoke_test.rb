# frozen_string_literal: true

require "test_helper"

class CalculatorSmokeTest < ActionDispatch::IntegrationTest
  include CalculatorHelper

  # Smoke test: every calculator page renders with required SEO and structural elements.
  # This catches broken views, missing partials, and SEO regressions across all 500+ calculators.

  CalculatorRegistry::ALL_CATEGORIES.each do |category_slug, category|
    category[:calculators].each do |calc|
      test "#{category_slug}/#{calc[:slug]} has h1 and meta description" do
        path = send(calc[:path])
        get path
        assert_response :success, "#{calc[:name]} returned non-200 at #{path}"

        # Every calculator must have exactly one h1
        assert_select "h1", { count: 1 }, "#{calc[:name]} should have exactly one h1"

        # Every calculator must have a meta description
        assert_select 'meta[name="description"]', { count: 1 },
          "#{calc[:name]} is missing meta description"

        # Every calculator must have a canonical link
        assert_select 'link[rel="canonical"]', { count: 1 },
          "#{calc[:name]} is missing canonical link"
      end
    end
  end

  # Category landing pages
  CalculatorRegistry::ALL_CATEGORIES.each_key do |slug|
    test "category #{slug} has h1 and meta description" do
      get category_path(slug)
      assert_response :success
      assert_select "h1", { count: 1 }, "Category #{slug} should have exactly one h1"
      assert_select 'meta[name="description"]', { count: 1 },
        "Category #{slug} is missing meta description"
    end
  end
end
