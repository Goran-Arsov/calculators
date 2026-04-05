class BlogController < ApplicationController
  skip_before_action :set_http_cache
  before_action :load_post, only: :show
  before_action :set_blog_cache

  def index
    @posts = BlogPost.published.recent.by_category(params[:category])

    set_meta_tags(
      title: "Blog — Financial Tips, Math Guides & Health Insights",
      description: "Read expert articles about personal finance, math concepts, and health metrics. Practical guides and tips from CalcWise.",
      canonical: blog_url,
      og: {
        title: "CalcWise Blog",
        description: "Expert articles about personal finance, math concepts, and health metrics.",
        url: blog_url,
        type: "website",
        site_name: "CalcWise"
      }
    )
  end

  def show
    set_meta_tags(
      title: @post.meta_title.presence || @post.title,
      description: @post.meta_description.presence || @post.excerpt,
      canonical: blog_post_url(@post.slug),
      og: {
        title: "#{@post.title} | CalcWise",
        description: @post.meta_description.presence || @post.excerpt,
        url: blog_post_url(@post.slug),
        type: "article",
        site_name: "CalcWise"
      }
    )
  end

  private

  def load_post
    @post = BlogPost.published.find_by!(slug: params[:slug])
  end

  # Blog content changes without deploys, so use shorter TTLs and
  # include post timestamps in the ETag for precise invalidation.
  def set_blog_cache
    return unless request.get? || request.head?

    expires_in 30.minutes, public: true,
      stale_while_revalidate: 15.minutes,
      stale_if_error: 1.hour

    etag_parts = [CACHE_VERSION, request.path]
    if @post
      etag_parts << @post.updated_at.to_i
    else
      etag_parts << BlogPost.published.maximum(:updated_at)&.to_i
      etag_parts << params[:category]
    end

    fresh_when etag: etag_parts, public: true
  end
end
