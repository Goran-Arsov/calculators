# frozen_string_literal: true

module Gardening
  class RaisedBedSoilCalculator
    include GardenDimensionInput

    attr_reader :errors

    CUBIC_FEET_PER_YARD = 27.0
    BAG_CUBIC_FEET = 1.5
    DEFAULT_TOPSOIL_PCT = 60
    DEFAULT_COMPOST_PCT = 30
    DEFAULT_AERATION_PCT = 10

    def initialize(length_ft: nil, width_ft: nil, height_in: nil,
                   length_m: nil, width_m: nil, height_cm: nil,
                   beds: 1,
                   topsoil_pct: DEFAULT_TOPSOIL_PCT,
                   compost_pct: DEFAULT_COMPOST_PCT,
                   aeration_pct: DEFAULT_AERATION_PCT,
                   unit_system: nil)
      @unit_system = detect_unit_system(unit_system, length_m, width_m, height_cm)
      @length_ft = to_feet(length_ft, length_m)
      @width_ft = to_feet(width_ft, width_m)
      @height_in = to_inches(height_in, height_cm)
      @beds = beds.to_i
      @topsoil_pct = topsoil_pct.to_f
      @compost_pct = compost_pct.to_f
      @aeration_pct = aeration_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      per_bed_cf = @length_ft * @width_ft * (@height_in / 12.0)
      total_cf = per_bed_cf * @beds

      cubic_m_per_cf = CUBIC_M_PER_CUBIC_FOOT
      {
        valid: true,
        unit_system: @unit_system,
        length_m: (@length_ft * M_PER_FOOT).round(2),
        width_m: (@width_ft * M_PER_FOOT).round(2),
        height_cm: (@height_in * CM_PER_INCH).round(1),
        per_bed_cubic_feet: per_bed_cf.round(2),
        per_bed_cubic_meters: (per_bed_cf * cubic_m_per_cf).round(3),
        total_cubic_feet: total_cf.round(2),
        total_cubic_yards: (total_cf / CUBIC_FEET_PER_YARD).round(2),
        total_cubic_meters: (total_cf * cubic_m_per_cf).round(3),
        total_bags: (total_cf / BAG_CUBIC_FEET).ceil,
        topsoil_cubic_feet: (total_cf * @topsoil_pct / 100.0).round(2),
        topsoil_cubic_meters: (total_cf * cubic_m_per_cf * @topsoil_pct / 100.0).round(3),
        compost_cubic_feet: (total_cf * @compost_pct / 100.0).round(2),
        compost_cubic_meters: (total_cf * cubic_m_per_cf * @compost_pct / 100.0).round(3),
        aeration_cubic_feet: (total_cf * @aeration_pct / 100.0).round(2),
        aeration_cubic_meters: (total_cf * cubic_m_per_cf * @aeration_pct / 100.0).round(3)
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Height must be greater than zero" unless @height_in.positive?
      @errors << "Number of beds must be at least 1" unless @beds >= 1
      total_pct = @topsoil_pct + @compost_pct + @aeration_pct
      unless (99.0..101.0).cover?(total_pct)
        @errors << "Mix percentages must add up to 100 (got #{total_pct.round(1)})"
      end
      [ @topsoil_pct, @compost_pct, @aeration_pct ].each do |pct|
        @errors << "Mix percentages cannot be negative" if pct.negative?
      end
    end
  end
end
