# frozen_string_literal: true

module Textile
  class BindingStripsCalculator
    INCHES_TO_CM = 2.54

    attr_reader :errors

    def initialize(quilt_width_in: nil, quilt_length_in: nil,
                   quilt_width_cm: nil, quilt_length_cm: nil,
                   strip_width_in: nil, strip_width_cm: nil,
                   fabric_width_in: nil, fabric_width_cm: nil,
                   overage_in: nil, overage_cm: nil,
                   unit_system: nil)
      @unit_system = detect_unit_system(unit_system, quilt_width_cm, quilt_length_cm)
      @quilt_width_in = to_inches(quilt_width_in, quilt_width_cm)
      @quilt_length_in = to_inches(quilt_length_in, quilt_length_cm)
      @strip_width_in = to_inches(strip_width_in, strip_width_cm, default_in: 2.5, default_cm: 6.35)
      @fabric_width_in = to_inches(fabric_width_in, fabric_width_cm, default_in: 42, default_cm: 106.68)
      @overage_in = to_inches(overage_in, overage_cm, default_in: 10, default_cm: 25.4)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      perimeter = 2 * (@quilt_width_in + @quilt_length_in)
      total_length_needed = perimeter + @overage_in

      # Strips are cut selvage-to-selvage, so each strip is fabric_width_in long
      strips_needed = (total_length_needed / @fabric_width_in).ceil

      # Fabric used along the lengthwise grain = num strips * strip width
      fabric_used_in = strips_needed * @strip_width_in
      fabric_yards = fabric_used_in / 36.0
      fabric_meters = fabric_used_in * INCHES_TO_CM / 100.0

      {
        valid: true,
        unit_system: @unit_system,
        perimeter: perimeter.round(2),
        perimeter_cm: (perimeter * INCHES_TO_CM).round(1),
        total_length_needed: total_length_needed.round(2),
        total_length_needed_cm: (total_length_needed * INCHES_TO_CM).round(1),
        strips_needed: strips_needed,
        fabric_used_in: fabric_used_in.round(3),
        fabric_used_cm: (fabric_used_in * INCHES_TO_CM).round(1),
        fabric_yards: fabric_yards.round(3),
        fabric_meters: fabric_meters.round(3)
      }
    end

    private

    def detect_unit_system(explicit, width_cm, length_cm)
      return explicit if %w[imperial metric].include?(explicit.to_s)
      return "metric" if width_cm || length_cm

      "imperial"
    end

    def to_inches(in_value, cm_value, default_in: nil, default_cm: nil)
      return in_value.to_f if in_value
      return cm_value.to_f / INCHES_TO_CM if cm_value
      return default_in.to_f if @unit_system == "imperial" && default_in
      return default_cm.to_f / INCHES_TO_CM if @unit_system == "metric" && default_cm

      0.0
    end

    def validate!
      @errors << "Quilt width must be greater than zero" unless @quilt_width_in.positive?
      @errors << "Quilt length must be greater than zero" unless @quilt_length_in.positive?
      @errors << "Strip width must be greater than zero" unless @strip_width_in.positive?
      @errors << "Fabric width must be greater than zero" unless @fabric_width_in.positive?
      @errors << "Overage cannot be negative" if @overage_in.negative?
    end
  end
end
