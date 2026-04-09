require "test_helper"

class ProgrammaticControllerTest < ActionDispatch::IntegrationTest
  test "first programmatic page returns 200" do
    slug = ProgrammaticSeo::Registry.all_slugs.first
    get "/#{slug}"
    assert_response :success
  end

  test "page has correct h1" do
    slug = ProgrammaticSeo::Registry.all_slugs.first
    page = ProgrammaticSeo::Registry.find(slug)
    get "/#{slug}"
    assert_select "h1", page[:h1]
  end

  test "page includes breadcrumb schema" do
    slug = ProgrammaticSeo::Registry.all_slugs.first
    get "/#{slug}"
    assert_includes response.body, "BreadcrumbList"
  end

  test "page includes FAQ schema" do
    slug = ProgrammaticSeo::Registry.all_slugs.first
    get "/#{slug}"
    assert_includes response.body, "FAQPage"
  end

  test "page includes calculator schema" do
    slug = ProgrammaticSeo::Registry.all_slugs.first
    get "/#{slug}"
    assert_includes response.body, "SoftwareApplication"
  end

  test "page includes HowTo schema" do
    slug = ProgrammaticSeo::Registry.all_slugs.first
    get "/#{slug}"
    assert_includes response.body, "HowTo"
    assert_includes response.body, "HowToStep"
  end

  test "page includes calculator form with stimulus controller" do
    slug = ProgrammaticSeo::Registry.all_slugs.first
    page = ProgrammaticSeo::Registry.find(slug)
    get "/#{slug}"
    assert_select "[data-controller='#{page[:stimulus_controller]}']"
  end

  test "page includes how it works section" do
    slug = ProgrammaticSeo::Registry.all_slugs.first
    page = ProgrammaticSeo::Registry.find(slug)
    get "/#{slug}"
    assert_includes response.body, page[:how_it_works][:heading]
  end

  test "page includes FAQ content" do
    slug = ProgrammaticSeo::Registry.all_slugs.first
    page = ProgrammaticSeo::Registry.find(slug)
    get "/#{slug}"
    page[:faq].each do |faq_item|
      assert_includes response.body, faq_item[:question]
    end
  end

  test "page includes related calculators" do
    slug = ProgrammaticSeo::Registry.all_slugs.first
    page = ProgrammaticSeo::Registry.find(slug)
    get "/#{slug}"
    assert_includes response.body, "full-featured version" if page[:base_calculator_path]
  end

  test "page sets cache headers" do
    slug = ProgrammaticSeo::Registry.all_slugs.first
    get "/#{slug}"
    assert_includes response.headers["Cache-Control"], "public"
  end

  test "nonexistent slug does not match programmatic routes" do
    # Nonexistent slugs fall through to the category constraint, which also rejects them
    get "/this-slug-does-not-exist-anywhere-at-all"
    assert_response :not_found
  end

  # Smoke test: every programmatic page returns 200
  ProgrammaticSeo::Registry.all_slugs.each do |slug|
    test "programmatic page #{slug} returns 200" do
      get "/#{slug}"
      assert_response :success
    end
  end
end
