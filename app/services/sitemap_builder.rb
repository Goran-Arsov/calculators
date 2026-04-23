# frozen_string_literal: true

# Builds the list of sitemap URL entries for /sitemap-main.xml.
#
# Takes a URL-helper host (a controller instance that has access to the
# named route helpers) and returns an array of hashes shaped like:
#
#   { loc:, changefreq:, priority:, lastmod: }
#
# Extracted from SitemapController#show so the controller stays thin and
# the individual groups of URLs are independently readable and testable.
class SitemapBuilder
  MONTHLY = "monthly"
  WEEKLY = "weekly"
  YEARLY = "yearly"

  SUITE_ROUTES = %i[suite_home_buying_url suite_fitness_url suite_business_startup_url].freeze

  COMPARISON_ROUTES = %i[
    compare_mortgage_terms_url
    compare_bmi_vs_body_fat_url
    compare_stocks_vs_crypto_url
    compare_keto_vs_macros_url
    compare_simple_vs_compound_url
  ].freeze

  STATIC_SECONDARY_ROUTES = [
    { route: :about_url,            changefreq: MONTHLY, priority: "0.5" },
    { route: :privacy_policy_url,   changefreq: YEARLY,  priority: "0.3" },
    { route: :terms_of_service_url, changefreq: YEARLY,  priority: "0.3" },
    { route: :contact_url,          changefreq: YEARLY,  priority: "0.4" },
    { route: :disclaimer_url,       changefreq: YEARLY,  priority: "0.3" }
  ].freeze

  def initialize(url_helpers)
    @url_helpers = url_helpers
    @month_start = Date.current.beginning_of_month.to_s
    @today = Date.current.to_s
  end

  def build
    [
      homepage_url,
      *category_urls,
      *cross_category_browse_urls,
      *suite_urls,
      *comparison_urls,
      *calculator_urls,
      *programmatic_seo_urls,
      *blog_post_urls,
      blog_index_url,
      *static_secondary_urls
    ]
  end

  private

  attr_reader :url_helpers, :month_start, :today

  def homepage_url
    { loc: url_helpers.root_url, changefreq: WEEKLY, priority: "1.0", lastmod: month_start }
  end

  def category_urls
    CalculatorRegistry::ALL_CATEGORIES.each_key.map do |cat|
      { loc: url_helpers.category_url(cat), changefreq: WEEKLY, priority: "0.9", lastmod: month_start }
    end
  end

  def cross_category_browse_urls
    [
      { loc: url_helpers.browse_url,   changefreq: WEEKLY, priority: "0.7", lastmod: month_start },
      { loc: url_helpers.it_tools_url, changefreq: WEEKLY, priority: "0.7", lastmod: month_start }
    ]
  end

  def suite_urls
    SUITE_ROUTES.map do |route|
      { loc: url_helpers.send(route), changefreq: MONTHLY, priority: "0.7", lastmod: month_start }
    end
  end

  def comparison_urls
    COMPARISON_ROUTES.map do |route|
      { loc: url_helpers.send(route), changefreq: MONTHLY, priority: "0.7", lastmod: month_start }
    end
  end

  # Exclude noindexed Tier 4 pages so the sitemap doesn't send mixed signals
  # (sitemap inclusion + noindex is the canonical "mixed signal" that Search
  # Console flags). See lib/seo/noindex_list.rb.
  def calculator_urls
    CalculatorRegistry::ALL_CATEGORIES.each_value.flat_map do |category|
      category[:calculators].filter_map do |calc|
        loc = url_helpers.send(calc[:path].to_s.sub(/_path\z/, "_url"))
        next if Seo::NoindexList.include?(URI.parse(loc).path)

        { loc: loc, changefreq: MONTHLY, priority: "0.8", lastmod: month_start }
      end
    end
  end

  def programmatic_seo_urls
    ProgrammaticSeo::Registry.all_pages.filter_map do |page|
      next unless page[:indexable]

      {
        loc: url_helpers.send("#{page[:route_name]}_url"),
        changefreq: MONTHLY,
        priority: "0.7",
        lastmod: ProgrammaticSeo::Registry.lastmod_for(page[:slug])
      }
    end
  end

  def blog_post_urls
    BlogPost.published.recent.pluck(:slug, :updated_at).map do |slug, updated_at|
      { loc: url_helpers.blog_post_url(slug), changefreq: MONTHLY, priority: "0.6", lastmod: updated_at.to_date.to_s }
    end
  end

  def blog_index_url
    { loc: url_helpers.blog_url, changefreq: WEEKLY, priority: "0.7", lastmod: today }
  end

  def static_secondary_urls
    STATIC_SECONDARY_ROUTES.map do |entry|
      {
        loc: url_helpers.send(entry[:route]),
        changefreq: entry[:changefreq],
        priority: entry[:priority],
        lastmod: month_start
      }
    end
  end
end
