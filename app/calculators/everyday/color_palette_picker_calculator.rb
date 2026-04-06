# frozen_string_literal: true

module Everyday
  class ColorPalettePickerCalculator
    attr_reader :errors

    def initialize(hex:)
      @hex = hex.to_s.strip.delete_prefix("#")
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      r, g, b = hex_to_rgb(@hex)

      {
        valid: true,
        hex: "##{@hex.upcase}",
        rgb: { r: r, g: g, b: b },
        rgb_string: "rgb(#{r}, #{g}, #{b})"
      }
    end

    private

    def hex_to_rgb(hex)
      hex = hex.chars.map { |c| "#{c}#{c}" }.join if hex.length == 3
      [hex[0..1], hex[2..3], hex[4..5]].map { |h| h.to_i(16) }
    end

    def validate!
      @errors << "Hex color cannot be empty" if @hex.empty?
      return if @hex.empty?

      @errors << "Invalid hex color" unless @hex.match?(/\A[0-9a-fA-F]{3}\z|\A[0-9a-fA-F]{6}\z/)
    end
  end
end
