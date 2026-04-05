class CategoriesController < ApplicationController
  include CalculatorHelper

  def show
    @slug = params[:category]
    @category = ALL_CATEGORIES[@slug]
    raise ActionController::RoutingError, "Not Found" unless @category

    @calculators = @category[:calculators].map do |calc|
      calc.merge(path: resolve_calculator_path(calc))
    end

    @programmatic_calculators = ProgrammaticSeo::Registry.pages_for_category(@slug).map do |page|
      {
        name: page[:h1],
        description: page[:meta_description],
        path: send("#{page[:route_name]}_path"),
        icon_path: page[:icon_path]
      }
    end

    set_meta_tags(
      title: @category[:title],
      description: @category[:description],
      canonical: category_url(@slug),
      og: {
        title: "#{@category[:title]} | CalcWise",
        description: @category[:description],
        url: category_url(@slug),
        type: "website",
        site_name: "CalcWise"
      }
    )
  end

  private

  # Category pages include DB-backed blog posts, so use a shorter TTL
  # and include the latest blog post timestamp in the ETag.
  def set_http_cache
    return unless request.get? || request.head?

    blog_latest = BlogPost.published.maximum(:updated_at)&.to_i || 0

    expires_in 2.hours, public: true,
      stale_while_revalidate: 1.hour,
      stale_if_error: 1.day

    fresh_when etag: [CACHE_VERSION, request.path, blog_latest], public: true
  end
end
