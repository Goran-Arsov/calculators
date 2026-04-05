class Rack::Attack
  # Throttle API rating submissions
  throttle("api/ratings", limit: 10, period: 60) do |req|
    req.ip if req.path.start_with?("/api/ratings") && req.post?
  end

  # Throttle general requests
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Block bad bots
  blocklist("block bad bots") do |req|
    Rack::Attack::Fail2Ban.filter("bad-bots-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
      CGI.unescape(req.query_string) =~ %r{/etc/passwd|/proc/self|<script}i
    end
  end
end
