# frozen_string_literal: true

module Everyday
  class TextToSpeechCalculator
    attr_reader :errors

    AVERAGE_WORDS_PER_MINUTE = 150

    def initialize(text:)
      @text = text.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      words = @text.split(/\s+/).reject(&:empty?)
      word_count = words.length
      char_count = @text.length
      estimated_duration_seconds = (word_count / AVERAGE_WORDS_PER_MINUTE.to_f * 60).round(1)

      {
        valid: true,
        word_count: word_count,
        char_count: char_count,
        estimated_duration_seconds: estimated_duration_seconds
      }
    end

    private

    def validate!
      if @text.strip.empty?
        @errors << "Text cannot be empty"
      end
    end
  end
end
