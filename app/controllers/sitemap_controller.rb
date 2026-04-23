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

  # Localized finance calculator slugs available under /:locale/finance/:slug
  LOCALIZED_FINANCE_SLUGS = %w[
    mortgage-calculator
    compound-interest-calculator
    loan-calculator
    investment-calculator
    retirement-calculator
  ].freeze

  # Localized health calculator slugs available under /:locale/health/:slug
  LOCALIZED_HEALTH_SLUGS = %w[
    bmi-calculator
    calorie-calculator
    body-fat-calculator
    tdee-calculator
    macro-calculator
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

    @urls = SitemapBuilder.new(self).build

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

    LOCALIZED_FINANCE_SLUGS.each do |slug|
      @urls << {
        loc: "#{domain}/#{locale_param}/finance/#{slug}",
        changefreq: "monthly",
        priority: "0.8",
        lastmod: Date.current.beginning_of_month.to_s
      }
    end

    LOCALIZED_HEALTH_SLUGS.each do |slug|
      @urls << {
        loc: "#{domain}/#{locale_param}/health/#{slug}",
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
