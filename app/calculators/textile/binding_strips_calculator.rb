# frozen_string_literal: true

module Textile
  class BindingStripsCalculator
    attr_reader :errors

    def initialize(quilt_width_in:, quilt_length_in:, strip_width_in: 2.5, fabric_width_in: 42, overage_in: 10)
      @quilt_width_in = quilt_width_in.to_f
      @quilt_length_in = quilt_length_in.to_f
      @strip_width_in = strip_width_in.to_f
      @fabric_width_in = fabric_width_in.to_f
      @overage_in = overage_in.to_f
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
      fabric_meters = fabric_used_in * 0.0254

      {
        valid: true,
        perimeter: perimeter.round(2),
        total_length_needed: total_length_needed.round(2),
        strips_needed: strips_needed,
        fabric_used_in: fabric_used_in.round(3),
        fabric_yards: fabric_yards.round(3),
        fabric_meters: fabric_meters.round(3)
      }
    end

    private

    def validate!
      @errors << "Quilt width must be greater than zero" unless @quilt_width_in.positive?
      @errors << "Quilt length must be greater than zero" unless @quilt_length_in.positive?
      @errors << "Strip width must be greater than zero" unless @strip_width_in.positive?
      @errors << "Fabric width must be greater than zero" unless @fabric_width_in.positive?
      @errors << "Overage cannot be negative" if @overage_in.negative?
    end
  end
end
