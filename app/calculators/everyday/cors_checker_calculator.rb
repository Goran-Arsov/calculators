# frozen_string_literal: true

module Everyday
  class CorsCheckerCalculator
    attr_reader :errors

    CORS_HEADERS = %w[
      access-control-allow-origin
      access-control-allow-methods
      access-control-allow-headers
      access-control-allow-credentials
      access-control-max-age
      access-control-expose-headers
    ].freeze

    def initialize(headers_text:, test_origin: "", test_method: "", test_headers: "")
      @headers_text = headers_text.to_s
      @test_origin = test_origin.to_s.strip
      @test_method = test_method.to_s.strip
      @test_headers = test_headers.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      parsed_headers = parse_headers
      cors_headers = extract_cors_headers(parsed_headers)
      cors_enabled = cors_headers.any?
      warnings = detect_warnings(cors_headers)
      test_result = run_test_scenario(cors_headers)

      {
        valid: true,
        cors_enabled: cors_enabled,
        cors_headers: cors_headers,
        allowed_origins: parse_list_value(cors_headers["access-control-allow-origin"]),
        allowed_methods: parse_list_value(cors_headers["access-control-allow-methods"]),
        allowed_headers: parse_list_value(cors_headers["access-control-allow-headers"]),
        exposed_headers: parse_list_value(cors_headers["access-control-expose-headers"]),
        allow_credentials: cors_headers["access-control-allow-credentials"]&.downcase == "true",
        max_age: cors_headers["access-control-max-age"]&.to_i,
        warnings: warnings,
        test_result: test_result
      }
    end

    private

    def validate!
      @errors << "Headers text cannot be empty" if @headers_text.strip.empty?
    end

    def parse_headers
      @headers_text.lines.filter_map do |line|
        line = line.strip
        next if line.empty?
        next if line.match?(/\AHTTP\/[\d.]+\s+\d+/)

        if line.include?(":")
          name, value = line.split(":", 2)
          { name: name.strip, value: value&.strip || "" }
        end
      end
    end

    def extract_cors_headers(parsed_headers)
      cors = {}
      parsed_headers.each do |header|
        key = header[:name].downcase
        cors[key] = header[:value] if CORS_HEADERS.include?(key)
      end
      cors
    end

    def parse_list_value(value)
      return [] if value.nil? || value.strip.empty?

      value.split(",").map(&:strip).reject(&:empty?)
    end

    def detect_warnings(cors_headers)
      warnings = []

      origin = cors_headers["access-control-allow-origin"]
      credentials = cors_headers["access-control-allow-credentials"]

      if origin == "*" && credentials&.downcase == "true"
        warnings << "Wildcard origin (*) with credentials is not allowed by browsers and will be rejected."
      end

      if origin == "*"
        warnings << "Wildcard origin (*) allows any website to make cross-origin requests. Consider restricting to specific origins."
      end

      if origin.present? && origin != "*"
        all_headers = @headers_text.lines.map { |l| l.strip.split(":", 2) }
        vary_header = all_headers.find { |parts| parts[0]&.strip&.downcase == "vary" }
        if vary_header.nil? || !vary_header[1]&.downcase&.include?("origin")
          warnings << "Missing 'Vary: Origin' header. When Access-Control-Allow-Origin is not a wildcard, the Vary header should include Origin to prevent caching issues."
        end
      end

      methods = cors_headers["access-control-allow-methods"]
      if methods&.include?("*")
        warnings << "Wildcard methods (*) allows all HTTP methods. Consider restricting to specific methods needed."
      end

      headers_val = cors_headers["access-control-allow-headers"]
      if headers_val&.include?("*")
        warnings << "Wildcard headers (*) allows all request headers. Consider restricting to specific headers needed."
      end

      max_age = cors_headers["access-control-max-age"]
      if max_age.present? && max_age.to_i > 86_400
        warnings << "Max-age of #{max_age} seconds exceeds 24 hours. Most browsers cap preflight caching at shorter durations."
      end

      warnings
    end

    def run_test_scenario(cors_headers)
      return nil if @test_origin.empty? && @test_method.empty? && @test_headers.empty?

      results = []
      overall_pass = true

      if @test_origin.present?
        origin_value = cors_headers["access-control-allow-origin"]
        origin_pass = origin_value == "*" || origin_value == @test_origin
        overall_pass = false unless origin_pass
        results << { check: "Origin '#{@test_origin}'", pass: origin_pass, header: "Access-Control-Allow-Origin", value: origin_value || "(missing)" }
      end

      if @test_method.present?
        methods_value = cors_headers["access-control-allow-methods"]
        allowed = parse_list_value(methods_value)
        method_pass = allowed.include?("*") || allowed.any? { |m| m.casecmp(@test_method).zero? }
        overall_pass = false unless method_pass
        results << { check: "Method '#{@test_method}'", pass: method_pass, header: "Access-Control-Allow-Methods", value: methods_value || "(missing)" }
      end

      if @test_headers.present?
        headers_value = cors_headers["access-control-allow-headers"]
        allowed = parse_list_value(headers_value)
        requested = @test_headers.split(",").map(&:strip)
        all_allowed = requested.all? do |rh|
          allowed.include?("*") || allowed.any? { |ah| ah.casecmp(rh).zero? }
        end
        overall_pass = false unless all_allowed
        results << { check: "Headers '#{@test_headers}'", pass: all_allowed, header: "Access-Control-Allow-Headers", value: headers_value || "(missing)" }
      end

      { pass: overall_pass, checks: results }
    end
  end
end
