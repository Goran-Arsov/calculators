class RobotsController < ApplicationController
  def show
    domain = ENV.fetch("DOMAIN", request.base_url)
    render plain: <<~ROBOTS
      User-agent: *
      Allow: /
      Disallow: /admin/
      Disallow: /api/
      Disallow: /embed/
      Disallow: /search
      Disallow: /submit-calculator/
      Disallow: /up

      User-agent: Mediapartners-Google
      Allow: /

      User-agent: AdsBot-Google
      Allow: /

      # Crawl-delay for polite bots
      User-agent: Bingbot
      Crawl-delay: 5

      Sitemap: #{domain}/sitemap.xml
    ROBOTS
  end
end
