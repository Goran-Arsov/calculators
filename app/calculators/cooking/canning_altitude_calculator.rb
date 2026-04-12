# frozen_string_literal: true

module Cooking
  class CanningAltitudeCalculator
    attr_reader :errors

    # Water bath canning: add time at altitude
    # Pressure canning: increase pressure at altitude
    #
    # USDA guidelines:
    # Water bath: +5 min for 1001-3000 ft, +10 min for 3001-6000 ft, +15 min for 6001-8000 ft, +20 min for 8001-10000 ft
    # Pressure canning (dial gauge): +0.5 psi per 1000 ft above 1000 ft
    # Pressure canning (weighted gauge): use 15 psi above 1000 ft instead of 10 psi

    ALTITUDE_BRACKETS_WATER_BATH = [
      { range: 0..1000, extra_minutes: 0 },
      { range: 1001..3000, extra_minutes: 5 },
      { range: 3001..6000, extra_minutes: 10 },
      { range: 6001..8000, extra_minutes: 15 },
      { range: 8001..10_000, extra_minutes: 20 }
    ].freeze

    ALTITUDE_BRACKETS_PRESSURE_DIAL = [
      { range: 0..1000, extra_psi: 0 },
      { range: 1001..2000, extra_psi: 1 },
      { range: 2001..4000, extra_psi: 2 },
      { range: 4001..6000, extra_psi: 3 },
      { range: 6001..8000, extra_psi: 4 },
      { range: 8001..10_000, extra_psi: 5 }
    ].freeze

    def initialize(altitude_ft:, base_processing_time:, canning_method:, base_pressure: 10)
      @altitude_ft = altitude_ft.to_i
      @base_processing_time = base_processing_time.to_i
      @canning_method = canning_method.to_s.strip
      @base_pressure = base_pressure.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @canning_method
      when "water_bath"
        calculate_water_bath
      when "pressure_dial"
        calculate_pressure_dial
      when "pressure_weighted"
        calculate_pressure_weighted
      end
    end

    private

    def validate!
      @errors << "Altitude must be non-negative" if @altitude_ft < 0
      @errors << "Altitude must be 10,000 feet or less" if @altitude_ft > 10_000
      @errors << "Base processing time must be positive" unless @base_processing_time > 0
      unless %w[water_bath pressure_dial pressure_weighted].include?(@canning_method)
        @errors << "Unknown canning method: #{@canning_method}. Use water_bath, pressure_dial, or pressure_weighted."
      end
    end

    def calculate_water_bath
      bracket = ALTITUDE_BRACKETS_WATER_BATH.find { |b| b[:range].include?(@altitude_ft) }
      extra = bracket ? bracket[:extra_minutes] : 20
      adjusted_time = @base_processing_time + extra

      {
        valid: true,
        canning_method: "water_bath",
        altitude_ft: @altitude_ft,
        base_processing_time: @base_processing_time,
        extra_minutes: extra,
        adjusted_processing_time: adjusted_time,
        note: water_bath_note(extra)
      }
    end

    def calculate_pressure_dial
      bracket = ALTITUDE_BRACKETS_PRESSURE_DIAL.find { |b| b[:range].include?(@altitude_ft) }
      extra_psi = bracket ? bracket[:extra_psi] : 5
      adjusted_pressure = @base_pressure + extra_psi

      {
        valid: true,
        canning_method: "pressure_dial",
        altitude_ft: @altitude_ft,
        base_pressure: @base_pressure,
        extra_psi: extra_psi,
        adjusted_pressure: adjusted_pressure,
        base_processing_time: @base_processing_time,
        adjusted_processing_time: @base_processing_time,
        note: "Dial gauge: increase pressure by #{extra_psi} PSI at #{@altitude_ft} ft. Process at #{adjusted_pressure} PSI for #{@base_processing_time} minutes."
      }
    end

    def calculate_pressure_weighted
      adjusted_pressure = @altitude_ft > 1000 ? 15 : 10

      {
        valid: true,
        canning_method: "pressure_weighted",
        altitude_ft: @altitude_ft,
        base_pressure: @base_pressure,
        adjusted_pressure: adjusted_pressure,
        base_processing_time: @base_processing_time,
        adjusted_processing_time: @base_processing_time,
        note: "Weighted gauge: use #{adjusted_pressure} PSI at #{@altitude_ft} ft. Process for #{@base_processing_time} minutes."
      }
    end

    def water_bath_note(extra)
      if extra == 0
        "No adjustment needed at your altitude."
      else
        "Add #{extra} minutes to processing time at #{@altitude_ft} ft altitude."
      end
    end
  end
end
