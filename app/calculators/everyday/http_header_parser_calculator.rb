# frozen_string_literal: true

module Everyday
  class HttpHeaderParserCalculator
    attr_reader :errors

    SECURITY_HEADERS = {
      "content-security-policy" => {
        name: "Content-Security-Policy",
        description: "Prevents XSS, clickjacking, and other code injection attacks by specifying allowed content sources."
      },
      "strict-transport-security" => {
        name: "Strict-Transport-Security",
        description: "Forces browsers to use HTTPS for all future requests to the domain."
      },
      "x-frame-options" => {
        name: "X-Frame-Options",
        description: "Prevents clickjacking by controlling whether the page can be embedded in frames."
      },
      "x-content-type-options" => {
        name: "X-Content-Type-Options",
        description: "Prevents MIME-type sniffing, forcing browsers to respect the declared Content-Type."
      },
      "x-xss-protection" => {
        name: "X-XSS-Protection",
        description: "Legacy XSS filter for older browsers. Modern browsers use CSP instead."
      },
      "referrer-policy" => {
        name: "Referrer-Policy",
        description: "Controls how much referrer information is sent with requests."
      },
      "permissions-policy" => {
        name: "Permissions-Policy",
        description: "Controls which browser features and APIs can be used on the page."
      },
      "x-permitted-cross-domain-policies" => {
        name: "X-Permitted-Cross-Domain-Policies",
        description: "Controls whether Flash and PDF documents can access data across domains."
      },
      "cross-origin-opener-policy" => {
        name: "Cross-Origin-Opener-Policy",
        description: "Isolates the browsing context to prevent cross-origin attacks."
      },
      "cross-origin-resource-policy" => {
        name: "Cross-Origin-Resource-Policy",
        description: "Controls which origins can load the resource."
      }
    }.freeze

    def initialize(headers_text:)
      @headers_text = headers_text.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      parsed_headers = parse_headers
      security_analysis = analyze_security(parsed_headers)

      {
        valid: true,
        headers: parsed_headers,
        header_count: parsed_headers.size,
        security_headers_present: security_analysis[:present],
        security_headers_missing: security_analysis[:missing],
        security_score: security_analysis[:score],
        security_grade: security_analysis[:grade]
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

        # Skip HTTP status lines (e.g., "HTTP/1.1 200 OK")
        next if line.match?(/\AHTTP\/[\d.]+\s+\d+/)

        if line.include?(":")
          name, value = line.split(":", 2)
          { name: name.strip, value: value&.strip || "" }
        else
          { name: line, value: "", malformed: true }
        end
      end
    end

    def analyze_security(parsed_headers)
      header_names_lower = parsed_headers.map { |h| h[:name].downcase }

      present = []
      missing = []

      SECURITY_HEADERS.each do |key, info|
        entry = {
          name: info[:name],
          description: info[:description]
        }

        if header_names_lower.include?(key)
          header = parsed_headers.find { |h| h[:name].downcase == key }
          entry[:value] = header[:value] if header
          present << entry
        else
          missing << entry
        end
      end

      total = SECURITY_HEADERS.size
      score = total.positive? ? ((present.size.to_f / total) * 100).round : 0
      grade = calculate_grade(score)

      { present: present, missing: missing, score: score, grade: grade }
    end

    def calculate_grade(score)
      case score
      when 90..100 then "A"
      when 70..89 then "B"
      when 50..69 then "C"
      when 30..49 then "D"
      else "F"
      end
    end
  end
end
