# frozen_string_literal: true

module Everyday
  class WordCounterCalculator
    attr_reader :errors

    READING_WPM = 238.0
    SPEAKING_WPM = 150.0

    def initialize(text:)
      @text = text.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      words = @text.split(/\s+/).reject(&:empty?)
      sentences = @text.scan(/[.!?]+/).size
      paragraphs = @text.split(/\n\s*\n/).reject(&:empty?).size
      paragraphs = 1 if paragraphs.zero? && words.any?

      {
        valid: true,
        word_count: words.size,
        character_count: @text.length,
        character_count_no_spaces: @text.gsub(/\s/, "").length,
        sentence_count: sentences,
        paragraph_count: paragraphs,
        reading_time_minutes: (words.size / READING_WPM).ceil,
        speaking_time_minutes: (words.size / SPEAKING_WPM).ceil
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end
  end
end
