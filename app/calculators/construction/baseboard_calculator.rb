# frozen_string_literal: true

module Construction
  class BaseboardCalculator
    attr_reader :errors

    DEFAULT_DOOR_WIDTH_FT = 3.0
    DEFAULT_STICK_LENGTH_FT = 8.0

    def initialize(length_ft:, width_ft:, doors: 0, door_width_ft: DEFAULT_DOOR_WIDTH_FT,
                   waste_pct: 10, stick_length_ft: DEFAULT_STICK_LENGTH_FT,
                   price_per_foot: nil)
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @doors = doors.to_i
      @door_width_ft = door_width_ft.to_f
      @waste_pct = waste_pct.to_f
      @stick_length_ft = stick_length_ft.to_f
      @price_per_foot = price_per_foot.to_f if price_per_foot && price_per_foot.to_s != ""
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      perimeter = 2.0 * (@length_ft + @width_ft)
      door_deduction = @doors * @door_width_ft
      linear_feet = [ perimeter - door_deduction, 0 ].max
      with_waste = linear_feet * (1 + @waste_pct / 100.0)
      sticks = (with_waste / @stick_length_ft).ceil
      total_cost = @price_per_foot ? with_waste * @price_per_foot : nil

      {
        valid: true,
        perimeter_ft: perimeter.round(2),
        door_deduction_ft: door_deduction.round(2),
        linear_feet: linear_feet.round(2),
        linear_feet_with_waste: with_waste.round(2),
        sticks: sticks,
        total_cost: total_cost&.round(2)
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Doors cannot be negative" if @doors.negative?
      @errors << "Stick length must be greater than zero" unless @stick_length_ft.positive?
      @errors << "Waste percent cannot be negative" if @waste_pct.negative?
    end
  end
end
