# frozen_string_literal: true

module Everyday
  class CaseConverterCalculator
    attr_reader :errors

    def initialize(text:)
      @text = text.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      {
        valid: true,
        uppercase: @text.upcase,
        lowercase: @text.downcase,
        title_case: title_case(@text),
        sentence_case: sentence_case(@text),
        camel_case: camel_case(@text),
        snake_case: snake_case(@text),
        kebab_case: kebab_case(@text)
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end

    def title_case(text)
      text.gsub(/\b\w/) { |match| match.upcase }
    end

    def sentence_case(text)
      text.downcase.gsub(/(?:^|[.!?]\s+)\w/) { |match| match.upcase }
    end

    def camel_case(text)
      words = text.strip.split(/[\s_\-]+/)
      return "" if words.empty?

      words.first.downcase + words[1..].map(&:capitalize).join
    end

    def snake_case(text)
      text.strip
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .gsub(/[\s\-]+/, "_")
          .downcase
    end

    def kebab_case(text)
      text.strip
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1-\2')
          .gsub(/([a-z\d])([A-Z])/, '\1-\2')
          .gsub(/[\s_]+/, "-")
          .downcase
    end
  end
end
