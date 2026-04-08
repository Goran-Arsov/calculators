class SitemapController < ApplicationController
  include CalculatorHelper

  skip_before_action :set_locale, only: :locale

  # Localized calculator slugs available under /:locale/everyday/:slug
  LOCALIZED_CALCULATOR_SLUGS = %w[
    base64-encoder-decoder
    url-encoder-decoder
    html-formatter-beautifier
    css-formatter-beautifier
    javascript-formatter-beautifier
    json-validator
    json-to-yaml-converter
    curl-to-code-converter
    json-to-typescript-generator
    html-to-jsx-converter
    hex-ascii-converter
    http-status-code-reference
    robots-txt-generator
    htaccess-generator
    regex-explainer
    open-graph-preview
    svg-to-png-converter
  ].freeze

  # GET /sitemap.xml — sitemap index pointing to per-locale sitemaps
  def index
    expires_in 6.hours, public: true,
      stale_while_revalidate: 2.hours,
      stale_if_error: 1.day

    domain = ENV.fetch("DOMAIN", request.base_url)
    @sitemaps = []

    # Main (English/default) sitemap
    @sitemaps << { loc: "#{domain}/sitemap-main.xml", lastmod: Date.current.to_s }

    # Per-locale sitemaps
    SUPPORTED_LOCALES.each do |locale|
      @sitemaps << { loc: "#{domain}/sitemap-#{locale}.xml", lastmod: Date.current.to_s }
    end

    respond_to do |format|
      format.xml
    end
  end

  # GET /sitemap-main.xml — the original English/default sitemap
  def show
    expires_in 6.hours, public: true,
      stale_while_revalidate: 2.hours,
      stale_if_error: 1.day

    @urls = []

    # Homepage
    @urls << { loc: root_url, changefreq: "weekly", priority: "1.0", lastmod: Date.current.to_s }

    # Category pages
    CalculatorRegistry::ALL_CATEGORIES.each_key do |cat|
      @urls << { loc: category_url(cat), changefreq: "weekly", priority: "0.9", lastmod: Date.current.to_s }
    end

    # All calculators from every category
    CalculatorRegistry::ALL_CATEGORIES.each_value do |category|
      category[:calculators].each do |calc|
        url_helper = calc[:path].to_s.sub(/_path\z/, "_url")
        @urls << { loc: send(url_helper), changefreq: "monthly", priority: "0.8", lastmod: Date.current.beginning_of_month.to_s }
      end
    end

    # Programmatic SEO pages
    ProgrammaticSeo::Registry.all_pages.each do |page|
      @urls << { loc: send("#{page[:route_name]}_url"), changefreq: "monthly", priority: "0.7", lastmod: Date.current.beginning_of_month.to_s }
    end

    # Blog posts
    BlogPost.published.recent.pluck(:slug, :updated_at).each do |slug, updated_at|
      @urls << { loc: blog_post_url(slug), changefreq: "monthly", priority: "0.6", lastmod: updated_at.to_date.to_s }
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

  # GET /sitemap-:locale.xml — sitemap for a specific locale
  def locale
    locale_param = params[:locale]
    unless SUPPORTED_LOCALES.include?(locale_param)
      head :not_found
      return
    end

    expires_in 6.hours, public: true,
      stale_while_revalidate: 2.hours,
      stale_if_error: 1.day

    domain = ENV.fetch("DOMAIN", request.base_url)
    @urls = []

    LOCALIZED_CALCULATOR_SLUGS.each do |slug|
      @urls << {
        loc: "#{domain}/#{locale_param}/everyday/#{slug}",
        changefreq: "monthly",
        priority: "0.8",
        lastmod: Date.current.beginning_of_month.to_s
      }
    end

    respond_to do |format|
      format.xml { render :show }
    end
  end
end
