# frozen_string_literal: true

module Construction
  class MiterAngleCalculator
    attr_reader :errors

    def initialize(sides:)
      @sides = sides.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Interior angle of a regular polygon
      interior_angle = (@sides - 2) * 180.0 / @sides
      # Miter angle = half the exterior angle (each of the two cuts meeting at a corner)
      miter_angle = 180.0 / @sides
      # Full corner turn (exterior angle)
      full_corner_angle = 360.0 / @sides

      {
        valid: true,
        sides: @sides,
        interior_angle: interior_angle.round(4),
        miter_angle: miter_angle.round(4),
        full_corner_angle: full_corner_angle.round(4)
      }
    end

    private

    def validate!
      @errors << "Number of sides must be at least 3" unless @sides >= 3
      @errors << "Number of sides must be 100 or fewer" if @sides > 100
    end
  end
end
