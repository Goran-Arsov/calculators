# frozen_string_literal: true

module Construction
  class HeatPumpCapacityCalculator
    attr_reader :errors

    # Heat pump heating capacity falls off as outdoor temperature drops.
    # These capacity fractions at each outdoor temp are typical AHRI data
    # for modern split-system heat pumps, expressed as a fraction of the
    # rated 47 °F capacity.
    #
    # "Standard" = typical single-stage or 2-stage residential HP.
    # "Cold_climate" = variable-speed inverter HP rated per NEEP cold-climate
    # heat pump list (retains much more capacity at low temperatures).
    #
    # Values below -13 °F are extrapolated; real manufacturer tables should
    # be checked for critical applications.
    CURVES = {
      "standard" => {
        65 => 1.10,
        47 => 1.00,
        35 => 0.88,
        17 => 0.70,
        5  => 0.55,
        -5 => 0.40,
        -13 => 0.30,
        -25 => 0.15
      },
      "cold_climate" => {
        65 => 1.10,
        47 => 1.00,
        35 => 0.98,
        17 => 0.90,
        5  => 0.80,
        -5 => 0.70,
        -13 => 0.58,
        -25 => 0.40
      }
    }.freeze

    def initialize(rated_btu_hr:, outdoor_f:, hp_type: "standard")
      @rated_btu_hr = rated_btu_hr.to_f
      @outdoor_f = outdoor_f.to_f
      @hp_type = hp_type.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      curve = CURVES[@hp_type]
      fraction = interpolate_capacity(curve, @outdoor_f)
      actual_btu_hr = @rated_btu_hr * fraction
      derating_pct = (1.0 - fraction) * 100.0

      {
        valid: true,
        hp_type: @hp_type,
        outdoor_f: @outdoor_f.round(1),
        rated_btu_hr: @rated_btu_hr.round(0),
        capacity_fraction: fraction.round(3),
        actual_btu_hr: actual_btu_hr.round(0),
        actual_tons: (actual_btu_hr / 12_000.0).round(2),
        derating_pct: derating_pct.round(1)
      }
    end

    private

    def validate!
      @errors << "Rated BTU/hr must be greater than zero" unless @rated_btu_hr.positive?
      @errors << "Outdoor temperature out of range (-40 to 100 °F)" unless (-40.0..100.0).cover?(@outdoor_f)
      @errors << "Heat pump type must be standard or cold_climate" unless CURVES.key?(@hp_type)
    end

    def interpolate_capacity(curve, temp)
      sorted = curve.sort_by { |t, _| t }
      # If at or below the lowest listed temp, use the lowest fraction.
      return sorted.first[1] if temp <= sorted.first[0]
      # If at or above the highest listed temp, use the highest fraction.
      return sorted.last[1] if temp >= sorted.last[0]

      # Linear interpolation between adjacent points.
      sorted.each_cons(2) do |(t1, f1), (t2, f2)|
        if temp.between?(t1, t2)
          return f1 + (f2 - f1) * (temp - t1) / (t2 - t1)
        end
      end
      1.0
    end
  end
end
