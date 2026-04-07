# frozen_string_literal: true

module Everyday
  class DocxToOdtCalculator
    attr_reader :errors

    def initialize(paragraphs:)
      @paragraphs = paragraphs
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      word_count = @paragraphs.sum { |p| p[:text].to_s.split(/\s+/).reject(&:empty?).size }

      {
        valid: true,
        paragraph_count: @paragraphs.size,
        word_count: word_count
      }
    end

    private

    def validate!
      @errors << "No content provided" if @paragraphs.nil? || @paragraphs.empty?
      @errors << "Content must be an array" unless @paragraphs.is_a?(Array)
    end
  end
end
