class BlogController < ApplicationController
  before_action :set_cache_headers

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
    @post = BlogPost.published.find_by!(slug: params[:slug])

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

  def set_cache_headers
    expires_in 30.minutes, public: true, stale_while_revalidate: 15.minutes
  end
end
