class Rack::Attack
  # Throttle API rating submissions
  throttle("api/ratings", limit: 3, period: 60) do |req|
    req.ip if req.path.start_with?("/api/ratings") && req.post?
  end

  # Throttle general requests
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Throttle embed requests — third-party sites could inadvertently cause high traffic
  throttle("embeds/ip", limit: 60, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/embed/")
  end

  # Throttle newsletter signups by email to prevent spam
  throttle("newsletter/email", limit: 3, period: 1.day) do |req|
    if req.path == "/newsletter" && req.post?
      req.params.dig("newsletter_subscriber", "email")&.downcase&.strip
    end
  end

  # Throttle newsletter signups by IP to prevent enumeration
  throttle("newsletter/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/newsletter" && req.post?
  end

  # Strict throttle on admin login to prevent brute force
  throttle("admin/login", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/admin/login" && req.post?
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

  # Persist blocked IPs to a file for review / external firewall ingestion
  BLOCKED_IPS_FILE = Rails.root.join("log", "blocked_ips.txt")
  BLOCKED_IPS_MUTEX = Mutex.new

  ActiveSupport::Notifications.subscribe("blocklist.rack_attack") do |*, payload|
    ip = payload[:request].ip

    BLOCKED_IPS_MUTEX.synchronize do
      existing = File.exist?(BLOCKED_IPS_FILE) ? File.read(BLOCKED_IPS_FILE).split(",").map(&:strip).reject(&:empty?) : []

      unless existing.include?(ip)
        existing << ip
        File.write(BLOCKED_IPS_FILE, existing.join(","))
      end
    end
  end
end
