require "test_helper"

class SitemapControllerTest < ActionDispatch::IntegrationTest
  # === Sitemap Index ===

  test "sitemap.xml returns sitemap index with 200 and XML content type" do
    get "/sitemap.xml"
    assert_response :success
    assert_equal "application/xml; charset=utf-8", response.content_type
  end

  test "sitemap index is valid XML with sitemapindex root element" do
    get "/sitemap.xml"
    assert_match %r{<sitemapindex xmlns="http://www\.sitemaps\.org/schemas/sitemap/0\.9">}, response.body
  end

  test "sitemap index includes main sitemap reference" do
    get "/sitemap.xml"
    assert_includes response.body, "/sitemap-main.xml"
  end

  test "sitemap index includes all locale sitemap references" do
    get "/sitemap.xml"
    %w[de fr es pt].each do |locale|
      assert_includes response.body, "/sitemap-#{locale}.xml",
        "Expected sitemap index to include sitemap-#{locale}.xml"
    end
  end

  test "sitemap index includes lastmod tags" do
    get "/sitemap.xml"
    assert_match %r{<lastmod>\d{4}-\d{2}-\d{2}</lastmod>}, response.body
  end

  # === Main Sitemap ===

  test "should get sitemap-main.xml with 200 and XML content type" do
    get "/sitemap-main.xml"
    assert_response :success
    assert_equal "application/xml; charset=utf-8", response.content_type
  end

  test "main sitemap includes root URL" do
    get "/sitemap-main.xml"
    assert_includes response.body, root_url
  end

  test "main sitemap includes at least one calculator URL" do
    get "/sitemap-main.xml"
    # Pension is intentionally indexable (not in Seo::NoindexList), unlike
    # mortgage/loan/etc. which are excluded from the sitemap by design.
    assert_includes response.body, finance_pension_url
  end

  test "main sitemap includes all 6 category URLs" do
    get "/sitemap-main.xml"

    %w[finance math physics health construction everyday].each do |cat|
      assert_includes response.body, category_url(cat),
        "Expected main sitemap to include category URL for #{cat}"
    end
  end

  test "main sitemap includes blog post URLs" do
    post = BlogPost.create!(
      title: "Sitemap Blog Post",
      slug: "sitemap-blog-post",
      body: "<p>Body</p>",
      excerpt: "Excerpt",
      published_at: 1.day.ago
    )

    get "/sitemap-main.xml"
    assert_includes response.body, blog_post_url(post.slug)
  end

  test "main sitemap includes static page URLs" do
    get "/sitemap-main.xml"

    assert_includes response.body, about_url
    assert_includes response.body, privacy_policy_url
    assert_includes response.body, terms_of_service_url
  end

  test "main sitemap includes blog index URL" do
    get "/sitemap-main.xml"
    assert_includes response.body, blog_url
  end

  test "main sitemap is valid XML with urlset root element" do
    get "/sitemap-main.xml"
    assert_match %r{<urlset xmlns="http://www\.sitemaps\.org/schemas/sitemap/0\.9">}, response.body
  end

  test "main sitemap includes lastmod tags" do
    get "/sitemap-main.xml"
    assert_match %r{<lastmod>\d{4}-\d{2}-\d{2}</lastmod>}, response.body
  end

  test "main sitemap homepage lastmod is anchored to beginning of month" do
    get "/sitemap-main.xml"
    assert_includes response.body, "<loc>#{root_url}</loc>"
    assert_includes response.body, "<lastmod>#{Date.current.beginning_of_month}</lastmod>"
  end

  test "main sitemap includes cross-category discovery pages" do
    get "/sitemap-main.xml"
    assert_includes response.body, browse_url
    assert_includes response.body, it_tools_url
  end

  test "main sitemap includes calculator suites" do
    get "/sitemap-main.xml"
    assert_includes response.body, suite_home_buying_url
    assert_includes response.body, suite_fitness_url
    assert_includes response.body, suite_business_startup_url
  end

  test "main sitemap includes comparison pages" do
    get "/sitemap-main.xml"
    assert_includes response.body, compare_mortgage_terms_url
    assert_includes response.body, compare_bmi_vs_body_fat_url
    assert_includes response.body, compare_stocks_vs_crypto_url
    assert_includes response.body, compare_keto_vs_macros_url
    assert_includes response.body, compare_simple_vs_compound_url
  end

  test "main sitemap blog post lastmod uses updated_at" do
    post = BlogPost.create!(
      title: "Lastmod Blog Post",
      slug: "lastmod-blog-post",
      body: "<p>Body</p>",
      excerpt: "Excerpt",
      published_at: 1.day.ago
    )

    get "/sitemap-main.xml"
    assert_includes response.body, "<lastmod>#{post.updated_at.to_date}</lastmod>"
  end

  # === Locale Sitemaps ===

  test "should get sitemap-de.xml with 200 and XML content type" do
    get "/sitemap-de.xml"
    assert_response :success
    assert_equal "application/xml; charset=utf-8", response.content_type
  end

  test "locale sitemap is valid XML with urlset root element" do
    get "/sitemap-fr.xml"
    assert_match %r{<urlset xmlns="http://www\.sitemaps\.org/schemas/sitemap/0\.9">}, response.body
  end

  test "locale sitemap includes localized calculator URLs" do
    get "/sitemap-de.xml"
    assert_includes response.body, "/de/everyday/base64-encoder-decoder"
    assert_includes response.body, "/de/everyday/json-validator"
    assert_includes response.body, "/de/everyday/svg-to-png-converter"
  end

  test "locale sitemap uses correct locale prefix" do
    %w[de fr es pt].each do |locale|
      get "/sitemap-#{locale}.xml"
      assert_response :success
      assert_includes response.body, "/#{locale}/everyday/",
        "Expected sitemap-#{locale}.xml to include /#{locale}/everyday/ URLs"
    end
  end

  test "locale sitemap does not include URLs from other locales" do
    get "/sitemap-de.xml"
    refute_includes response.body, "/fr/everyday/"
    refute_includes response.body, "/es/everyday/"
    refute_includes response.body, "/pt/everyday/"
  end

  test "locale sitemap includes all localized calculator slugs" do
    slugs = %w[
      base64-encoder-decoder url-encoder-decoder html-formatter-beautifier
      css-formatter-beautifier javascript-formatter-beautifier json-validator
      json-to-yaml-converter curl-to-code-converter json-to-typescript-generator
      html-to-jsx-converter hex-ascii-converter http-status-code-reference
      robots-txt-generator htaccess-generator regex-explainer
      open-graph-preview svg-to-png-converter
    ]

    get "/sitemap-es.xml"
    slugs.each do |slug|
      assert_includes response.body, "/es/everyday/#{slug}",
        "Expected sitemap-es.xml to include /es/everyday/#{slug}"
    end
  end

  test "locale sitemap includes lastmod and priority" do
    get "/sitemap-pt.xml"
    assert_match %r{<lastmod>\d{4}-\d{2}-\d{2}</lastmod>}, response.body
    assert_includes response.body, "<priority>0.8</priority>"
  end

  test "invalid locale returns 404 for locale sitemap" do
    get "/sitemap-xx.xml"
    assert_response :not_found
  end

  # === URL Contract Guards ===
  # These guard against accidental regression when adding categories or
  # programmatic SEO pages — sitemap completeness directly affects indexation.

  test "main sitemap includes every registered category" do
    get "/sitemap-main.xml"

    CalculatorRegistry::ALL_CATEGORIES.each_key do |category|
      assert_includes response.body, category_url(category),
        "Expected main sitemap to include category URL for #{category}"
    end
  end

  test "main sitemap excludes noindexed calculator paths" do
    get "/sitemap-main.xml"
    domain = URI.parse(root_url).origin

    Seo::NoindexList::PATHS.first(5).each do |path|
      refute_includes response.body, "<loc>#{domain}#{path}</loc>",
        "Noindexed path #{path} must not appear in sitemap (mixed signal)"
    end
  end

  test "main sitemap includes programmatic SEO pages when indexable" do
    indexable_page = ProgrammaticSeo::Registry.all_pages.find { |p| p[:indexable] }
    skip "no indexable programmatic SEO pages registered" unless indexable_page

    get "/sitemap-main.xml"
    url = url_for(controller: "programmatic", action: "show", only_path: false,
                  programmatic_slug: indexable_page[:slug])
    assert_includes response.body, url
  end

  test "locale sitemap includes finance and health localized URLs" do
    get "/sitemap-fr.xml"

    assert_includes response.body, "/fr/finance/mortgage-calculator"
    assert_includes response.body, "/fr/finance/invoice-generator"
    assert_includes response.body, "/fr/health/bmi-calculator"
    assert_includes response.body, "/fr/health/macro-calculator"
  end

  test "locale sitemap entry count matches registry" do
    expected = Localization::TranslatableRegistry.all_entries.count

    %w[de fr es pt mk].each do |locale|
      get "/sitemap-#{locale}.xml"
      actual = response.body.scan(%r{<url>}).size
      assert_equal expected, actual,
        "sitemap-#{locale}.xml should have one <url> per registry entry"
    end
  end
end
