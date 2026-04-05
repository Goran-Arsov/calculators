# frozen_string_literal: true

module Construction
  class ConcreteCalculator
    attr_reader :errors

    CUBIC_FEET_PER_YARD = 27
    CUBIC_YARDS_PER_60LB_BAG = 0.0167
    CUBIC_YARDS_PER_80LB_BAG = 0.022

    def initialize(length_ft:, width_ft:, depth_in:)
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @depth_in = depth_in.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      depth_ft = @depth_in / 12.0
      cubic_feet = @length_ft * @width_ft * depth_ft
      cubic_yards = cubic_feet / CUBIC_FEET_PER_YARD.to_f
      bags_60lb = (cubic_yards / CUBIC_YARDS_PER_60LB_BAG).ceil
      bags_80lb = (cubic_yards / CUBIC_YARDS_PER_80LB_BAG).ceil

      {
        valid: true,
        cubic_feet: cubic_feet.round(2),
        cubic_yards: cubic_yards.round(2),
        bags_60lb: bags_60lb,
        bags_80lb: bags_80lb
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Depth must be greater than zero" unless @depth_in.positive?
    end
  end
end
