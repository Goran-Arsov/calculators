# frozen_string_literal: true

module Construction
  class ExcavationCalculator
    attr_reader :errors

    # Swell factor: soil expands when excavated because the grains lose
    # their compacted arrangement. Typical ranges in % bulking:
    #   sand 12%, loam 25%, clay 35%, hard rock 50-65%.
    # Default 25% is reasonable for mixed residential soil.
    DEFAULT_SWELL_PCT = 25.0
    CUBIC_FEET_PER_YARD = 27.0
    TRUCK_CUYD_DEFAULT = 10.0

    def initialize(length_ft:, width_ft:, depth_ft:, shape: "rectangular", swell_pct: DEFAULT_SWELL_PCT)
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @depth_ft = depth_ft.to_f
      @shape = shape.to_s.downcase
      @swell_pct = swell_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      bank_cubic_feet =
        if @shape == "circular"
          # Treat length as diameter for circular pit.
          radius = @length_ft / 2.0
          Math::PI * radius * radius * @depth_ft
        else
          @length_ft * @width_ft * @depth_ft
        end

      bank_cubic_yards = bank_cubic_feet / CUBIC_FEET_PER_YARD
      loose_cubic_yards = bank_cubic_yards * (1.0 + @swell_pct / 100.0)
      truckloads = (loose_cubic_yards / TRUCK_CUYD_DEFAULT).ceil

      {
        valid: true,
        shape: @shape,
        bank_cubic_feet: bank_cubic_feet.round(2),
        bank_cubic_yards: bank_cubic_yards.round(2),
        loose_cubic_yards: loose_cubic_yards.round(2),
        swell_pct: @swell_pct.round(1),
        truckloads: truckloads
      }
    end

    private

    def validate!
      @errors << "Length (or diameter) must be greater than zero" unless @length_ft.positive?
      if @shape != "circular"
        @errors << "Width must be greater than zero" unless @width_ft.positive?
      end
      @errors << "Depth must be greater than zero" unless @depth_ft.positive?
      @errors << "Swell percent cannot be negative" if @swell_pct.negative?
      unless %w[rectangular circular].include?(@shape)
        @errors << "Shape must be rectangular or circular"
      end
    end
  end
end
