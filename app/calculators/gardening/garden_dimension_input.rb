# frozen_string_literal: true

module Gardening
  # Shared unit handling for gardening calculators that take bed dimensions
  # (length, width, depth/height) in feet/inches with optional metric alternatives.
  #
  # Expects the including class to set @length_ft, @width_ft, and @depth_in
  # (via to_feet / to_inches) during initialization, then call with_metric_dimensions
  # inside #call to add area_sqm, cubic_meters, length_m, width_m, depth_cm fields
  # to the result hash.
  module GardenDimensionInput
    SQM_PER_SQFT = 0.09290304
    M_PER_FOOT = 0.3048
    CM_PER_INCH = 2.54
    CUBIC_M_PER_CUBIC_FOOT = 0.028316846592

    private

    def detect_unit_system(explicit, *metric_values)
      return explicit if %w[imperial metric].include?(explicit.to_s)
      return "metric" if metric_values.compact.any?

      "imperial"
    end

    def to_feet(feet_value, meter_value)
      return feet_value.to_f if feet_value
      return meter_value.to_f / M_PER_FOOT if meter_value

      0.0
    end

    def to_inches(inch_value, centimeter_value)
      return inch_value.to_f if inch_value
      return centimeter_value.to_f / CM_PER_INCH if centimeter_value

      0.0
    end

    # Enrich a result hash with metric equivalents. Safe to call even when
    # the input was imperial — the metric fields simply provide a readable
    # cross-reference for metric-using gardeners.
    def with_metric_dimensions(hash)
      hash.merge(
        length_m: (@length_ft * M_PER_FOOT).round(2),
        width_m: (@width_ft * M_PER_FOOT).round(2),
        depth_cm: ((@depth_in || @height_in || 0) * CM_PER_INCH).round(1),
        area_sqm: (hash[:area_sqft] * SQM_PER_SQFT).round(2),
        cubic_meters: (hash[:cubic_feet] * CUBIC_M_PER_CUBIC_FOOT).round(3)
      )
    end
  end
end
