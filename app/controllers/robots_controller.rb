class RobotsController < ApplicationController
  def show
    domain = ENV.fetch("DOMAIN", request.base_url)
    render plain: <<~ROBOTS
      User-agent: *
      Allow: /
      Sitemap: #{domain}/sitemap.xml
    ROBOTS
  end
end
