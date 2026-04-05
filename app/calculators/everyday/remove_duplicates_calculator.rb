# frozen_string_literal: true

module Everyday
  class RemoveDuplicatesCalculator
    attr_reader :errors

    def initialize(text:)
      @text = text.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      lines = @text.split("\n")
      unique_lines = lines.uniq
      duplicates_removed = lines.size - unique_lines.size

      {
        valid: true,
        original_line_count: lines.size,
        unique_line_count: unique_lines.size,
        duplicates_removed: duplicates_removed,
        unique_lines: unique_lines.join("\n")
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end
  end
end
