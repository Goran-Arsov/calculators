class SitemapController < ApplicationController
  include CalculatorHelper

  def show
    @urls = []

    # Homepage
    @urls << { loc: root_url, changefreq: "weekly", priority: "1.0" }

    # Category pages
    ALL_CATEGORIES.each_key do |cat|
      @urls << { loc: category_url(cat), changefreq: "weekly", priority: "0.9" }
    end

    # All calculators from every category
    ALL_CATEGORIES.each_value do |category|
      category[:calculators].each do |calc|
        url_helper = calc[:path].to_s.sub(/_path\z/, "_url")
        @urls << { loc: send(url_helper), changefreq: "monthly", priority: "0.8" }
      end
    end

    # Blog posts
    BlogPost.published.recent.each do |post|
      @urls << { loc: blog_post_url(post.slug), changefreq: "monthly", priority: "0.6" }
    end

    # Static pages
    @urls << { loc: blog_url, changefreq: "weekly", priority: "0.7" }
    @urls << { loc: about_url, changefreq: "monthly", priority: "0.5" }
    @urls << { loc: privacy_policy_url, changefreq: "yearly", priority: "0.3" }
    @urls << { loc: terms_of_service_url, changefreq: "yearly", priority: "0.3" }
    @urls << { loc: contact_url, changefreq: "yearly", priority: "0.4" }
    @urls << { loc: disclaimer_url, changefreq: "yearly", priority: "0.3" }

    respond_to do |format|
      format.xml
    end
  end
end
