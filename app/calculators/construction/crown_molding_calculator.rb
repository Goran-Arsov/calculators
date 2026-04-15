# frozen_string_literal: true

module Construction
  class CrownMoldingCalculator
    attr_reader :errors

    STANDARD_STICK_LENGTHS_FT = [ 8, 10, 12, 14, 16 ].freeze
    DEFAULT_WASTE_PCT = 10.0

    def initialize(length_ft:, width_ft:, door_openings_ft: 0.0, stick_length_ft: 12, waste_pct: DEFAULT_WASTE_PCT)
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @door_openings_ft = door_openings_ft.to_f
      @stick_length_ft = stick_length_ft.to_i
      @waste_pct = waste_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      perimeter = 2.0 * (@length_ft + @width_ft)
      net_ft = [ perimeter - @door_openings_ft, 0 ].max
      with_waste_ft = net_ft * (1 + @waste_pct / 100.0)
      sticks = (with_waste_ft / @stick_length_ft).round(6).ceil

      {
        valid: true,
        perimeter_ft: perimeter.round(2),
        door_openings_ft: @door_openings_ft.round(2),
        net_linear_ft: net_ft.round(2),
        linear_ft_with_waste: with_waste_ft.round(2),
        stick_length_ft: @stick_length_ft,
        sticks_needed: sticks
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Door openings cannot be negative" if @door_openings_ft.negative?
      unless STANDARD_STICK_LENGTHS_FT.include?(@stick_length_ft)
        @errors << "Stick length must be #{STANDARD_STICK_LENGTHS_FT.join(', ')} feet"
      end
      @errors << "Waste percent cannot be negative" if @waste_pct.negative?
    end
  end
end
