# frozen_string_literal: true

module Everyday
  class CharacterCounterCalculator
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
        character_count: @text.length,
        character_count_no_spaces: @text.gsub(/\s/, "").length,
        letter_count: @text.scan(/\p{L}/).size,
        digit_count: @text.scan(/\d/).size,
        special_character_count: @text.gsub(/[\p{L}\d\s]/, "").length,
        line_count: @text.split("\n").size,
        word_count: @text.split(/\s+/).reject(&:empty?).size
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end
  end
end
