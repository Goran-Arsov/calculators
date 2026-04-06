# frozen_string_literal: true

module Everyday
  class MarkdownToPdfCalculator
    attr_reader :errors

    def initialize(markdown:)
      @markdown = markdown.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      lines = @markdown.split("\n")
      headings = lines.count { |l| l.match?(/\A\#{1,6}\s/) }
      code_blocks = @markdown.scan(/```/).size / 2
      word_count = @markdown.split(/\s+/).reject(&:empty?).size

      {
        valid: true,
        line_count: lines.size,
        word_count: word_count,
        heading_count: headings,
        code_block_count: code_blocks
      }
    end

    private

    def validate!
      @errors << "Markdown text cannot be empty" if @markdown.strip.empty?
    end
  end
end
