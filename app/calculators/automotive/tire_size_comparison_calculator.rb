# frozen_string_literal: true

module Automotive
  class TireSizeComparisonCalculator
    attr_reader :errors

    # Tire size format: width/aspect_ratio R rim_diameter
    # e.g. 225/45R17 means 225mm width, 45% aspect ratio, 17" rim
    def initialize(tire1_width:, tire1_aspect:, tire1_rim:, tire2_width:, tire2_aspect:, tire2_rim:)
      @tire1_width = tire1_width.to_f
      @tire1_aspect = tire1_aspect.to_f
      @tire1_rim = tire1_rim.to_f
      @tire2_width = tire2_width.to_f
      @tire2_aspect = tire2_aspect.to_f
      @tire2_rim = tire2_rim.to_f
      @errors = []
    end

    MM_TO_INCHES = 25.4

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      tire1 = compute_tire(@tire1_width, @tire1_aspect, @tire1_rim)
      tire2 = compute_tire(@tire2_width, @tire2_aspect, @tire2_rim)

      diameter_diff = tire2[:overall_diameter_inches] - tire1[:overall_diameter_inches]
      circumference_diff = tire2[:circumference_inches] - tire1[:circumference_inches]
      revs_per_mile_diff = tire2[:revolutions_per_mile] - tire1[:revolutions_per_mile]

      # Speedometer error: if actual tire is larger, speedometer reads low
      speedometer_difference_pct = tire1[:overall_diameter_inches] > 0 ?
        ((tire2[:overall_diameter_inches] - tire1[:overall_diameter_inches]) / tire1[:overall_diameter_inches] * 100.0) : 0.0

      {
        valid: true,
        tire1: tire1,
        tire2: tire2,
        diameter_difference_inches: diameter_diff.round(2),
        circumference_difference_inches: circumference_diff.round(2),
        revolutions_per_mile_difference: revs_per_mile_diff.round(1),
        speedometer_difference_pct: speedometer_difference_pct.round(2),
        actual_speed_at_60: (60.0 * (1.0 + speedometer_difference_pct / 100.0)).round(1)
      }
    end

    private

    def compute_tire(width_mm, aspect_ratio, rim_diameter_inches)
      sidewall_mm = width_mm * (aspect_ratio / 100.0)
      sidewall_inches = sidewall_mm / MM_TO_INCHES
      overall_diameter_inches = (rim_diameter_inches + 2.0 * sidewall_inches)
      circumference_inches = Math::PI * overall_diameter_inches
      revolutions_per_mile = 63_360.0 / circumference_inches # 63360 inches in a mile

      {
        width_mm: width_mm.round(1),
        aspect_ratio: aspect_ratio.round(1),
        rim_diameter_inches: rim_diameter_inches.round(1),
        sidewall_height_mm: sidewall_mm.round(1),
        sidewall_height_inches: sidewall_inches.round(2),
        overall_diameter_inches: overall_diameter_inches.round(2),
        overall_diameter_mm: (overall_diameter_inches * MM_TO_INCHES).round(1),
        circumference_inches: circumference_inches.round(2),
        revolutions_per_mile: revolutions_per_mile.round(1),
        width_inches: (width_mm / MM_TO_INCHES).round(2)
      }
    end

    def validate!
      @errors << "Tire 1 width must be positive" unless @tire1_width > 0
      @errors << "Tire 1 aspect ratio must be positive" unless @tire1_aspect > 0
      @errors << "Tire 1 rim diameter must be positive" unless @tire1_rim > 0
      @errors << "Tire 2 width must be positive" unless @tire2_width > 0
      @errors << "Tire 2 aspect ratio must be positive" unless @tire2_aspect > 0
      @errors << "Tire 2 rim diameter must be positive" unless @tire2_rim > 0
    end
  end
end
