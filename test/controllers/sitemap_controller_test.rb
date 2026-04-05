require "test_helper"

class SitemapControllerTest < ActionDispatch::IntegrationTest
  test "should get sitemap.xml with 200 and XML content type" do
    get "/sitemap.xml"
    assert_response :success
    assert_equal "application/xml; charset=utf-8", response.content_type
  end

  test "sitemap includes root URL" do
    get "/sitemap.xml"
    assert_includes response.body, root_url
  end

  test "sitemap includes at least one calculator URL" do
    get "/sitemap.xml"
    assert_includes response.body, finance_mortgage_url
  end

  test "sitemap includes all 6 category URLs" do
    get "/sitemap.xml"

    %w[finance math physics health construction everyday].each do |cat|
      assert_includes response.body, category_url(cat),
        "Expected sitemap to include category URL for #{cat}"
    end
  end

  test "sitemap includes blog post URLs" do
    post = BlogPost.create!(
      title: "Sitemap Blog Post",
      slug: "sitemap-blog-post",
      body: "<p>Body</p>",
      excerpt: "Excerpt",
      published_at: 1.day.ago
    )

    get "/sitemap.xml"
    assert_includes response.body, blog_post_url(post.slug)
  end

  test "sitemap includes static page URLs" do
    get "/sitemap.xml"

    assert_includes response.body, about_url
    assert_includes response.body, privacy_policy_url
    assert_includes response.body, terms_of_service_url
  end

  test "sitemap includes blog index URL" do
    get "/sitemap.xml"
    assert_includes response.body, blog_url
  end

  test "sitemap is valid XML with urlset root element" do
    get "/sitemap.xml"
    assert_match %r{<urlset xmlns="http://www\.sitemaps\.org/schemas/sitemap/0\.9">}, response.body
  end

  test "sitemap includes lastmod tags" do
    get "/sitemap.xml"
    assert_match %r{<lastmod>\d{4}-\d{2}-\d{2}</lastmod>}, response.body
  end

  test "sitemap homepage lastmod is today" do
    get "/sitemap.xml"
    assert_includes response.body, "<lastmod>#{Date.current.to_s}</lastmod>"
  end

  test "sitemap blog post lastmod uses updated_at" do
    post = BlogPost.create!(
      title: "Lastmod Blog Post",
      slug: "lastmod-blog-post",
      body: "<p>Body</p>",
      excerpt: "Excerpt",
      published_at: 1.day.ago
    )

    get "/sitemap.xml"
    assert_includes response.body, "<lastmod>#{post.updated_at.to_date.to_s}</lastmod>"
  end
end
