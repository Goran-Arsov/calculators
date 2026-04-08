class Rack::Attack
  # Throttle API rating submissions
  throttle("api/ratings", limit: 3, period: 60) do |req|
    req.ip if req.path.start_with?("/api/ratings") && req.post?
  end

  # Throttle general requests
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  MALICIOUS_PATTERNS = [
    %r{/etc/passwd}i,
    %r{/proc/self}i,
    %r{<\s*script[\s>]}i,
    %r{<\s*svg[\s/]}i,
    %r{on(?:load|error|click|mouseover)\s*=}i,
    %r{javascript\s*:}i,
    %r{\.\./\.\./}
  ].freeze

  # Block bad bots and malicious requests
  blocklist("block bad bots") do |req|
    Rack::Attack::Fail2Ban.filter("bad-bots-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
      decoded = CGI.unescape(req.query_string.to_s)
      MALICIOUS_PATTERNS.any? { |pattern| decoded.match?(pattern) }
    end
  end
end
