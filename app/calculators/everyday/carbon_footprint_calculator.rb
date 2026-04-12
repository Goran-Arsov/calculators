# frozen_string_literal: true

module Everyday
  class CarbonFootprintCalculator
    attr_reader :errors

    # Emission factors (kg CO2 per unit)
    DRIVING_KG_PER_KM = 0.21
    ELECTRICITY_KG_PER_KWH = 0.42
    FLIGHT_KG_PER_KM = 0.255
    NATURAL_GAS_KG_PER_THERM = 5.3

    # Diet factors (kg CO2 per year)
    DIET_FACTORS = {
      "meat_heavy" => 3300,
      "average" => 2500,
      "low_meat" => 1900,
      "vegetarian" => 1700,
      "vegan" => 1500
    }.freeze

    # Global averages for comparison (tonnes CO2/year)
    GLOBAL_AVERAGE_TONNES = 4.0
    US_AVERAGE_TONNES = 16.0
    EU_AVERAGE_TONNES = 6.0
    PARIS_TARGET_TONNES = 2.0

    def initialize(driving_km_per_week: 0, electricity_kwh_per_month: 0,
                   short_flights_per_year: 0, long_flights_per_year: 0,
                   diet: "average", natural_gas_therms_per_month: 0)
      @driving_km_per_week = driving_km_per_week.to_f
      @electricity_kwh_per_month = electricity_kwh_per_month.to_f
      @short_flights_per_year = short_flights_per_year.to_i
      @long_flights_per_year = long_flights_per_year.to_i
      @diet = diet.to_s.strip.downcase.presence || "average"
      @natural_gas_therms_per_month = natural_gas_therms_per_month.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      driving_annual = @driving_km_per_week * 52 * DRIVING_KG_PER_KM
      electricity_annual = @electricity_kwh_per_month * 12 * ELECTRICITY_KG_PER_KWH

      short_flight_km = 1500 # average short-haul one-way
      long_flight_km = 7000  # average long-haul one-way
      flights_annual = (@short_flights_per_year * short_flight_km * 2 * FLIGHT_KG_PER_KM) +
                       (@long_flights_per_year * long_flight_km * 2 * FLIGHT_KG_PER_KM)

      diet_annual = DIET_FACTORS.fetch(@diet, 2500).to_f
      gas_annual = @natural_gas_therms_per_month * 12 * NATURAL_GAS_KG_PER_THERM

      total_kg = driving_annual + electricity_annual + flights_annual + diet_annual + gas_annual
      total_tonnes = (total_kg / 1000.0).round(2)

      {
        valid: true,
        driving_kg: driving_annual.round(0),
        electricity_kg: electricity_annual.round(0),
        flights_kg: flights_annual.round(0),
        diet_kg: diet_annual.round(0),
        natural_gas_kg: gas_annual.round(0),
        total_kg: total_kg.round(0),
        total_tonnes: total_tonnes,
        breakdown: {
          driving_percent: percentage(driving_annual, total_kg),
          electricity_percent: percentage(electricity_annual, total_kg),
          flights_percent: percentage(flights_annual, total_kg),
          diet_percent: percentage(diet_annual, total_kg),
          natural_gas_percent: percentage(gas_annual, total_kg)
        },
        comparisons: {
          vs_global: (total_tonnes / GLOBAL_AVERAGE_TONNES * 100).round(0),
          vs_us: (total_tonnes / US_AVERAGE_TONNES * 100).round(0),
          vs_eu: (total_tonnes / EU_AVERAGE_TONNES * 100).round(0),
          vs_paris_target: (total_tonnes / PARIS_TARGET_TONNES * 100).round(0)
        },
        diet: @diet
      }
    end

    private

    def validate!
      @errors << "Driving km per week cannot be negative" if @driving_km_per_week.negative?
      @errors << "Electricity kWh per month cannot be negative" if @electricity_kwh_per_month.negative?
      @errors << "Short flights per year cannot be negative" if @short_flights_per_year.negative?
      @errors << "Long flights per year cannot be negative" if @long_flights_per_year.negative?
      @errors << "Invalid diet type" unless DIET_FACTORS.key?(@diet)
      @errors << "Natural gas therms cannot be negative" if @natural_gas_therms_per_month.negative?
    end

    def percentage(part, total)
      return 0 if total.zero?

      (part / total * 100).round(1)
    end
  end
end
