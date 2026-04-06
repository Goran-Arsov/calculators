# frozen_string_literal: true

module Everyday
  class TxtToPdfCalculator
    attr_reader :errors

    def initialize(text:)
      @text = text.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      lines = @text.split("\n")
      word_count = @text.split(/\s+/).reject(&:empty?).size

      {
        valid: true,
        line_count: lines.size,
        word_count: word_count,
        char_count: @text.length
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end
  end
end
