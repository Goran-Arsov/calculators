# frozen_string_literal: true

module Everyday
  class RegexTesterCalculator
    attr_reader :errors

    def initialize(pattern:, test_string:, flags: "")
      @pattern = pattern.to_s
      @test_string = test_string.to_s
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
      @test_string.scan(regex) do
        match = Regexp.last_match
        matches << {
          match: match[0],
          index: match.begin(0),
          length: match[0].length,
          captures: match.captures
        }
      end

      {
        valid: true,
        match_count: matches.size,
        matches: matches,
        pattern: @pattern,
        flags: @flags,
        has_captures: matches.any? { |m| m[:captures].any? }
      }
    end

    private

    def validate!
      @errors << "Pattern cannot be empty" if @pattern.strip.empty?
      @errors << "Test string cannot be empty" if @test_string.strip.empty?
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
