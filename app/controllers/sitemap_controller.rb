class SitemapController < ApplicationController
  include CalculatorHelper

  skip_before_action :set_locale, only: :locale

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
    month_start = Date.current.beginning_of_month.to_s

    @urls = Localization::TranslatableRegistry.all_entries.map do |entry|
      {
        loc: "#{domain}/#{locale_param}/#{entry[:scope]}/#{entry[:slug]}",
        changefreq: "monthly",
        priority: "0.8",
        lastmod: month_start
      }
    end

    respond_to do |format|
      format.xml { render :show }
    end
  end
end
