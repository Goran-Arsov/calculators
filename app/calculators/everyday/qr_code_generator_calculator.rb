# frozen_string_literal: true

module Everyday
  class QrCodeGeneratorCalculator
    attr_reader :errors

    MAX_LENGTH = 2048

    def initialize(text:)
      @text = text.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      {
        valid: true,
        text: @text,
        character_count: @text.length,
        type: detect_type(@text)
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
      @errors << "Text exceeds maximum length of #{MAX_LENGTH} characters" if @text.length > MAX_LENGTH
    end

    def detect_type(text)
      stripped = text.strip

      if stripped.match?(%r{\Ahttps?://}i)
        "url"
      elsif stripped.match?(/\A[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}\z/)
        "email"
      elsif stripped.match?(/\A\+?[\d\s\-().]{7,}\z/)
        "phone"
      else
        "text"
      end
    end
  end
end
