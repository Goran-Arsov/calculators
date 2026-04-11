# frozen_string_literal: true

module Gardening
  class PlantSpacingCalculator
    attr_reader :errors

    PATTERNS = %w[square triangular].freeze
    TRIANGULAR_ROW_FACTOR = Math.sqrt(3) / 2.0

    def initialize(length_ft:, width_ft:, spacing_in:, pattern: "square")
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @spacing_in = spacing_in.to_f
      @pattern = pattern.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      length_in = @length_ft * 12.0
      width_in = @width_ft * 12.0

      if @pattern == "triangular"
        row_spacing = @spacing_in * TRIANGULAR_ROW_FACTOR
        rows = (width_in / row_spacing).floor + 1
        per_row = (length_in / @spacing_in).floor + 1
        plants = rows * per_row
      else
        rows = (width_in / @spacing_in).floor + 1
        per_row = (length_in / @spacing_in).floor + 1
        plants = rows * per_row
      end

      {
        valid: true,
        area_sqft: (@length_ft * @width_ft).round(2),
        plants: plants,
        rows: rows,
        plants_per_row: per_row,
        pattern: @pattern
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Spacing must be greater than zero" unless @spacing_in.positive?
      unless PATTERNS.include?(@pattern)
        @errors << "Pattern must be one of: #{PATTERNS.join(', ')}"
      end
    end
  end
end
