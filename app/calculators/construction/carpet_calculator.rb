# frozen_string_literal: true

module Construction
  class CarpetCalculator
    attr_reader :errors

    SQFT_PER_SQYD = 9.0
    DEFAULT_ROLL_WIDTH_FT = 12.0

    def initialize(length_ft:, width_ft:, waste_pct: 10, roll_width_ft: DEFAULT_ROLL_WIDTH_FT, price_per_sqyd: nil)
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @waste_pct = waste_pct.to_f
      @roll_width_ft = roll_width_ft.to_f
      @price_per_sqyd = price_per_sqyd.to_f if price_per_sqyd && price_per_sqyd.to_s != ""
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      area_sqft = @length_ft * @width_ft
      area_with_waste = area_sqft * (1 + @waste_pct / 100.0)
      sqyd = area_with_waste / SQFT_PER_SQYD
      needs_seam = [ @length_ft, @width_ft ].min > @roll_width_ft
      linear_feet_off_roll = area_with_waste / @roll_width_ft
      total_cost = @price_per_sqyd ? sqyd * @price_per_sqyd : nil

      {
        valid: true,
        area_sqft: area_sqft.round(2),
        area_with_waste_sqft: area_with_waste.round(2),
        square_yards: sqyd.round(2),
        linear_feet_off_roll: linear_feet_off_roll.round(2),
        needs_seam: needs_seam,
        total_cost: total_cost&.round(2)
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Roll width must be greater than zero" unless @roll_width_ft.positive?
      @errors << "Waste percent cannot be negative" if @waste_pct.negative?
    end
  end
end
