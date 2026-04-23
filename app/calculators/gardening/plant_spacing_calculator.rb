# frozen_string_literal: true

module Gardening
  class PlantSpacingCalculator
    SQM_PER_SQFT = 0.09290304
    INCHES_TO_CM = 2.54

    attr_reader :errors

    PATTERNS = %w[square triangular].freeze
    TRIANGULAR_ROW_FACTOR = Math.sqrt(3) / 2.0

    def initialize(length_ft: nil, width_ft: nil, spacing_in: nil,
                   length_m: nil, width_m: nil, spacing_cm: nil,
                   pattern: "square", unit_system: nil)
      @unit_system = detect_unit_system(unit_system, length_m, width_m, spacing_cm)
      @length_ft = length_ft ? length_ft.to_f : metric_to_feet(length_m)
      @width_ft = width_ft ? width_ft.to_f : metric_to_feet(width_m)
      @spacing_in = spacing_in ? spacing_in.to_f : metric_to_inches(spacing_cm)
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
      else
        rows = (width_in / @spacing_in).floor + 1
      end
      per_row = (length_in / @spacing_in).floor + 1
      plants = rows * per_row

      area_sqft = @length_ft * @width_ft

      {
        valid: true,
        unit_system: @unit_system,
        area_sqft: area_sqft.round(2),
        area_sqm: (area_sqft * SQM_PER_SQFT).round(2),
        length_m: (@length_ft * 0.3048).round(2),
        width_m: (@width_ft * 0.3048).round(2),
        spacing_cm: (@spacing_in * INCHES_TO_CM).round(1),
        plants: plants,
        rows: rows,
        plants_per_row: per_row,
        pattern: @pattern
      }
    end

    private

    def detect_unit_system(explicit, length_m, width_m, spacing_cm)
      return explicit if %w[imperial metric].include?(explicit.to_s)
      return "metric" if length_m || width_m || spacing_cm

      "imperial"
    end

    def metric_to_feet(meters)
      return 0.0 if meters.nil?

      meters.to_f / 0.3048
    end

    def metric_to_inches(centimeters)
      return 0.0 if centimeters.nil?

      centimeters.to_f / INCHES_TO_CM
    end

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
