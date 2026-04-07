# frozen_string_literal: true

module Everyday
  class RobotsTxtCalculator
    attr_reader :errors

    SUPPORTED_ACTIONS = %w[generate test].freeze

    COMMON_BOTS = %w[Googlebot Bingbot Slurp DuckDuckBot Baiduspider YandexBot facebot ia_archiver].freeze

    def initialize(action: "generate", rules: [], sitemap_url: "", test_url: "", test_robots: "")
      @action = action.to_s.downcase
      @rules = rules.is_a?(Array) ? rules : []
      @sitemap_url = sitemap_url.to_s.strip
      @test_url = test_url.to_s.strip
      @test_robots = test_robots.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @action == "generate"
        generate_robots
      else
        test_robots
      end
    end

    private

    def validate!
      @errors << "Unsupported action: #{@action}" unless SUPPORTED_ACTIONS.include?(@action)
      if @action == "test"
        @errors << "robots.txt content cannot be empty" if @test_robots.strip.empty?
        @errors << "Test URL cannot be empty" if @test_url.strip.empty?
      end
    end

    def generate_robots
      lines = []

      if @rules.empty?
        lines << "User-agent: *"
        lines << "Allow: /"
      else
        @rules.each do |rule|
          next unless rule.is_a?(Hash)
          agent = rule["user_agent"] || rule[:user_agent] || "*"
          lines << "User-agent: #{agent}"
          disallows = Array(rule["disallow"] || rule[:disallow])
          allows = Array(rule["allow"] || rule[:allow])
          disallows.each { |path| lines << "Disallow: #{path}" }
          allows.each { |path| lines << "Allow: #{path}" }
          lines << ""
        end
      end

      lines << ""
      lines << "Sitemap: #{@sitemap_url}" unless @sitemap_url.empty?

      output = lines.join("\n").strip + "\n"

      {
        valid: true,
        action: "generate",
        output: output,
        rule_count: @rules.empty? ? 1 : @rules.size,
        has_sitemap: !@sitemap_url.empty?
      }
    end

    def test_robots
      path = extract_path(@test_url)
      rules = parse_robots(@test_robots)
      results = []

      rules.each do |agent, directives|
        allowed = evaluate_directives(directives, path)
        results << { user_agent: agent, allowed: allowed }
      end

      # If no rules matched, default is allowed
      results = [ { user_agent: "*", allowed: true } ] if results.empty?

      {
        valid: true,
        action: "test",
        test_url: @test_url,
        path: path,
        results: results,
        rule_count: rules.size
      }
    end

    def extract_path(url)
      return url if url.start_with?("/")
      uri = URI.parse(url)
      uri.path.empty? ? "/" : uri.path
    rescue URI::InvalidURIError
      url
    end

    def parse_robots(content)
      rules = {}
      current_agent = nil

      content.each_line do |line|
        line = line.strip.sub(/#.*/, "").strip
        next if line.empty?

        if line.start_with?("User-agent:")
          current_agent = line.sub("User-agent:", "").strip
          rules[current_agent] ||= []
        elsif current_agent
          if line.start_with?("Disallow:")
            path = line.sub("Disallow:", "").strip
            rules[current_agent] << { type: :disallow, path: path } unless path.empty?
          elsif line.start_with?("Allow:")
            path = line.sub("Allow:", "").strip
            rules[current_agent] << { type: :allow, path: path } unless path.empty?
          end
        end
      end

      rules
    end

    def evaluate_directives(directives, path)
      # More specific paths take priority; if equal, Allow wins
      best_match = nil
      best_length = -1

      directives.each do |directive|
        if path_matches?(directive[:path], path)
          if directive[:path].length > best_length ||
             (directive[:path].length == best_length && directive[:type] == :allow)
            best_match = directive
            best_length = directive[:path].length
          end
        end
      end

      best_match.nil? || best_match[:type] == :allow
    end

    def path_matches?(pattern, path)
      if pattern.end_with?("*")
        path.start_with?(pattern.chomp("*"))
      elsif pattern.include?("*")
        regex = Regexp.new("\\A" + Regexp.escape(pattern).gsub("\\*", ".*") + "\\z")
        regex.match?(path)
      else
        path.start_with?(pattern)
      end
    end
  end
end
