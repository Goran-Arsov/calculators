# frozen_string_literal: true

module Everyday
  class RegexBuilderCalculator
    attr_reader :errors

    COMMON_PATTERNS = {
      "email" => '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
      "url" => 'https?://[^\s/$.?#].[^\s]*',
      "phone" => '\+?[\d\s\-().]{7,15}',
      "ip_address" => '\b(?:\d{1,3}\.){3}\d{1,3}\b',
      "date" => '\d{4}[-/]\d{2}[-/]\d{2}'
    }.freeze

    def initialize(pattern:, test_text:, flags: "")
      @pattern = pattern.to_s
      @test_text = test_text.to_s
      @flags = flags.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      options = parse_flags
      begin
        regex = Regexp.new(@pattern, options)
      rescue RegexpError => e
        @errors << "Invalid regex pattern: #{e.message}"
        return { valid: false, errors: @errors }
      end

      matches = []
      @test_text.scan(regex) do
        match = Regexp.last_match
        groups = match.captures.each_with_index.map do |capture, idx|
          { index: idx + 1, text: capture }
        end
        matches << {
          text: match[0],
          start_position: match.begin(0),
          end_position: match.end(0),
          groups: groups
        }
      end

      {
        valid: true,
        pattern: @pattern,
        flags: @flags,
        pattern_valid: true,
        match_count: matches.size,
        matches: matches,
        has_groups: matches.any? { |m| m[:groups].any? }
      }
    end

    private

    def validate!
      @errors << "Pattern cannot be empty" if @pattern.strip.empty?
      @errors << "Test text cannot be empty" if @test_text.strip.empty?
    end

    def parse_flags
      options = 0
      options |= Regexp::IGNORECASE if @flags.include?("i")
      options |= Regexp::MULTILINE if @flags.include?("m")
      options |= Regexp::EXTENDED if @flags.include?("x")
      options
    end
  end
end
