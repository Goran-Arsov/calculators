# frozen_string_literal: true

module Gardening
  class GreenhouseHeaterCalculator
    attr_reader :errors

    # U-values (BTU per sqft per °F per hour) for common greenhouse glazing materials.
    U_VALUES = {
      "single_poly" => 1.15,
      "double_poly" => 0.70,
      "single_glass" => 1.13,
      "double_glass" => 0.65,
      "polycarbonate_twin" => 0.65,
      "polycarbonate_triple" => 0.58,
      "fiberglass" => 1.00
    }.freeze

    def initialize(length_ft:, width_ft:, height_ft:, desired_temp_f:, outside_temp_f:, glazing:)
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @height_ft = height_ft.to_f
      @desired_temp_f = desired_temp_f.to_f
      @outside_temp_f = outside_temp_f.to_f
      @glazing = glazing.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      surface_area = 2 * (@length_ft * @width_ft + @length_ft * @height_ft + @width_ft * @height_ft)
      delta_t = @desired_temp_f - @outside_temp_f
      u = U_VALUES[@glazing]
      btu_per_hour = surface_area * delta_t * u
      watts = btu_per_hour * 0.293071

      {
        valid: true,
        surface_area_sqft: surface_area.round(1),
        delta_t: delta_t.round(1),
        u_value: u,
        btu_per_hour: btu_per_hour.round(0),
        watts: watts.round(0)
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Height must be greater than zero" unless @height_ft.positive?
      @errors << "Desired temperature must be higher than outside temperature" if @desired_temp_f <= @outside_temp_f
      unless U_VALUES.key?(@glazing)
        @errors << "Glazing must be one of: #{U_VALUES.keys.join(', ')}"
      end
    end
  end
end
