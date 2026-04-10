# frozen_string_literal: true

module Textile
  class QuiltBackingCalculator
    attr_reader :errors

    def initialize(quilt_width_in:, quilt_length_in:, overage_in: 4, fabric_width_in: 42)
      @quilt_width_in = quilt_width_in.to_f
      @quilt_length_in = quilt_length_in.to_f
      @overage_in = overage_in.to_f
      @fabric_width_in = fabric_width_in.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      backing_width = @quilt_width_in + (2 * @overage_in)
      backing_length = @quilt_length_in + (2 * @overage_in)

      if backing_width <= @fabric_width_in
        total_yards = backing_length / 36.0
        total_meters = (backing_length * 0.0254)

        return {
          valid: true,
          backing_width: backing_width.round(2),
          backing_length: backing_length.round(2),
          needs_seam: false,
          num_panels: 1,
          seam_orientation: "none",
          total_yards: total_yards.round(3),
          total_meters: total_meters.round(3)
        }
      end

      # Option A: vertical seam — panels run length-wise
      num_panels_a = (backing_width / @fabric_width_in).ceil
      fabric_length_a = num_panels_a * backing_length
      yards_a = fabric_length_a / 36.0

      # Option B: horizontal seam — panels run width-wise
      num_panels_b = (backing_length / @fabric_width_in).ceil
      fabric_length_b = num_panels_b * backing_width
      yards_b = fabric_length_b / 36.0

      if yards_a <= yards_b
        total_yards = yards_a
        num_panels = num_panels_a
        seam_orientation = "vertical"
        fabric_length = fabric_length_a
      else
        total_yards = yards_b
        num_panels = num_panels_b
        seam_orientation = "horizontal"
        fabric_length = fabric_length_b
      end

      total_meters = fabric_length * 0.0254

      {
        valid: true,
        backing_width: backing_width.round(2),
        backing_length: backing_length.round(2),
        needs_seam: true,
        num_panels: num_panels,
        seam_orientation: seam_orientation,
        total_yards: total_yards.round(3),
        total_meters: total_meters.round(3)
      }
    end

    private

    def validate!
      @errors << "Quilt width must be greater than zero" unless @quilt_width_in.positive?
      @errors << "Quilt length must be greater than zero" unless @quilt_length_in.positive?
      @errors << "Overage cannot be negative" if @overage_in.negative?
      @errors << "Fabric width must be greater than zero" unless @fabric_width_in.positive?
    end
  end
end
