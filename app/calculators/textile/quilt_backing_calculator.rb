# frozen_string_literal: true

module Textile
  class QuiltBackingCalculator
    INCHES_TO_CM = 2.54

    attr_reader :errors

    def initialize(quilt_width_in: nil, quilt_length_in: nil,
                   quilt_width_cm: nil, quilt_length_cm: nil,
                   overage_in: nil, overage_cm: nil,
                   fabric_width_in: nil, fabric_width_cm: nil,
                   unit_system: nil)
      @unit_system = detect_unit_system(unit_system, quilt_width_cm, quilt_length_cm)
      @quilt_width_in = to_inches(quilt_width_in, quilt_width_cm)
      @quilt_length_in = to_inches(quilt_length_in, quilt_length_cm)
      @overage_in = to_inches(overage_in, overage_cm, default_in: 4, default_cm: 10)
      @fabric_width_in = to_inches(fabric_width_in, fabric_width_cm, default_in: 42, default_cm: 106)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      backing_width = @quilt_width_in + (2 * @overage_in)
      backing_length = @quilt_length_in + (2 * @overage_in)

      if backing_width <= @fabric_width_in
        return build_result(
          backing_width: backing_width,
          backing_length: backing_length,
          fabric_length: backing_length,
          needs_seam: false,
          num_panels: 1,
          seam_orientation: "none"
        )
      end

      # Option A: vertical seam — panels run length-wise
      num_panels_a = (backing_width / @fabric_width_in).ceil
      fabric_length_a = num_panels_a * backing_length

      # Option B: horizontal seam — panels run width-wise
      num_panels_b = (backing_length / @fabric_width_in).ceil
      fabric_length_b = num_panels_b * backing_width

      if fabric_length_a <= fabric_length_b
        build_result(
          backing_width: backing_width,
          backing_length: backing_length,
          fabric_length: fabric_length_a,
          needs_seam: true,
          num_panels: num_panels_a,
          seam_orientation: "vertical"
        )
      else
        build_result(
          backing_width: backing_width,
          backing_length: backing_length,
          fabric_length: fabric_length_b,
          needs_seam: true,
          num_panels: num_panels_b,
          seam_orientation: "horizontal"
        )
      end
    end

    private

    def detect_unit_system(explicit, width_cm, length_cm)
      return explicit if %w[imperial metric].include?(explicit.to_s)
      return "metric" if width_cm || length_cm

      "imperial"
    end

    # Resolve a dimension in inches regardless of which unit variant the caller supplied.
    # Picks imperial value when provided; falls back to converting cm; then to defaults.
    def to_inches(in_value, cm_value, default_in: nil, default_cm: nil)
      return in_value.to_f if in_value
      return cm_value.to_f / INCHES_TO_CM if cm_value
      return default_in.to_f if @unit_system == "imperial" && default_in
      return default_cm.to_f / INCHES_TO_CM if @unit_system == "metric" && default_cm

      0.0
    end

    def build_result(backing_width:, backing_length:, fabric_length:,
                     needs_seam:, num_panels:, seam_orientation:)
      {
        valid: true,
        unit_system: @unit_system,
        backing_width: backing_width.round(2),
        backing_length: backing_length.round(2),
        backing_width_cm: (backing_width * INCHES_TO_CM).round(1),
        backing_length_cm: (backing_length * INCHES_TO_CM).round(1),
        needs_seam: needs_seam,
        num_panels: num_panels,
        seam_orientation: seam_orientation,
        total_yards: (fabric_length / 36.0).round(3),
        total_meters: (fabric_length * INCHES_TO_CM / 100.0).round(3)
      }
    end

    def validate!
      @errors << "Quilt width must be greater than zero" unless @quilt_width_in.positive?
      @errors << "Quilt length must be greater than zero" unless @quilt_length_in.positive?
      @errors << "Overage cannot be negative" if @overage_in.negative?
      @errors << "Fabric width must be greater than zero" unless @fabric_width_in.positive?
    end
  end
end
