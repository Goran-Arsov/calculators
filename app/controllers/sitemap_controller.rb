class SitemapController < ApplicationController
  include CalculatorHelper

  def show
    @urls = []

    # Homepage
    @urls << { loc: root_url, changefreq: "weekly", priority: "1.0", lastmod: Date.current.to_s }

    # Category pages
    ALL_CATEGORIES.each_key do |cat|
      @urls << { loc: category_url(cat), changefreq: "weekly", priority: "0.9", lastmod: Date.current.to_s }
    end

    # All calculators from every category
    ALL_CATEGORIES.each_value do |category|
      category[:calculators].each do |calc|
        url_helper = calc[:path].to_s.sub(/_path\z/, "_url")
        @urls << { loc: send(url_helper), changefreq: "monthly", priority: "0.8", lastmod: Date.current.beginning_of_month.to_s }
      end
    end

    # Blog posts
    BlogPost.published.recent.each do |post|
      @urls << { loc: blog_post_url(post.slug), changefreq: "monthly", priority: "0.6", lastmod: post.updated_at.to_date.to_s }
    end

    # Static pages
    @urls << { loc: blog_url, changefreq: "weekly", priority: "0.7", lastmod: Date.current.to_s }
    @urls << { loc: about_url, changefreq: "monthly", priority: "0.5", lastmod: Date.current.beginning_of_month.to_s }
    @urls << { loc: privacy_policy_url, changefreq: "yearly", priority: "0.3", lastmod: Date.current.beginning_of_month.to_s }
    @urls << { loc: terms_of_service_url, changefreq: "yearly", priority: "0.3", lastmod: Date.current.beginning_of_month.to_s }
    @urls << { loc: contact_url, changefreq: "yearly", priority: "0.4", lastmod: Date.current.beginning_of_month.to_s }
    @urls << { loc: disclaimer_url, changefreq: "yearly", priority: "0.3", lastmod: Date.current.beginning_of_month.to_s }

    respond_to do |format|
      format.xml
    end
  end
end
