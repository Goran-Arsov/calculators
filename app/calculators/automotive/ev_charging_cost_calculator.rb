# frozen_string_literal: true

module Automotive
  class EvChargingCostCalculator
    attr_reader :errors

    def initialize(battery_capacity_kwh:, current_charge_pct: 10, target_charge_pct: 80,
                   electricity_rate_per_kwh: 0.13, charger_type: "level2",
                   charger_efficiency_pct: 90)
      @battery_capacity_kwh = battery_capacity_kwh.to_f
      @current_charge_pct = current_charge_pct.to_f / 100.0
      @target_charge_pct = target_charge_pct.to_f / 100.0
      @electricity_rate = electricity_rate_per_kwh.to_f
      @charger_type = charger_type.to_s
      @charger_efficiency = charger_efficiency_pct.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      energy_needed_kwh = @battery_capacity_kwh * (@target_charge_pct - @current_charge_pct)
      energy_from_grid_kwh = energy_needed_kwh / @charger_efficiency

      cost = energy_from_grid_kwh * @electricity_rate

      charger_power_kw = charger_power
      charge_time_hours = charger_power_kw > 0 ? energy_from_grid_kwh / charger_power_kw : 0

      # Cost per mile (assuming 3.5 miles per kWh average)
      miles_per_kwh = 3.5
      miles_added = energy_needed_kwh * miles_per_kwh
      cost_per_mile = miles_added > 0 ? cost / miles_added : 0

      # Monthly cost estimate (assuming daily commute of 40 miles)
      daily_commute_miles = 40
      daily_energy_kwh = daily_commute_miles / miles_per_kwh
      daily_grid_kwh = daily_energy_kwh / @charger_efficiency
      monthly_cost = daily_grid_kwh * @electricity_rate * 30

      {
        valid: true,
        battery_capacity_kwh: @battery_capacity_kwh.round(1),
        energy_needed_kwh: energy_needed_kwh.round(2),
        energy_from_grid_kwh: energy_from_grid_kwh.round(2),
        charging_cost: cost.round(2),
        charge_time_hours: charge_time_hours.round(1),
        charge_time_minutes: (charge_time_hours * 60).round(0),
        charger_type: @charger_type,
        charger_power_kw: charger_power_kw,
        cost_per_mile: cost_per_mile.round(3),
        miles_added: miles_added.round(1),
        estimated_monthly_cost: monthly_cost.round(2),
        electricity_rate: @electricity_rate.round(3),
        charger_efficiency_pct: (@charger_efficiency * 100).round(1)
      }
    end

    private

    def charger_power
      case @charger_type
      when "level1" then 1.4
      when "level2" then 7.2
      when "dc_fast" then 150.0
      when "supercharger" then 250.0
      else 7.2
      end
    end

    def validate!
      @errors << "Battery capacity must be positive" unless @battery_capacity_kwh > 0
      @errors << "Current charge must be between 0% and 100%" unless @current_charge_pct >= 0 && @current_charge_pct <= 1.0
      @errors << "Target charge must be between 0% and 100%" unless @target_charge_pct > 0 && @target_charge_pct <= 1.0
      @errors << "Target charge must be greater than current charge" unless @target_charge_pct > @current_charge_pct
      @errors << "Electricity rate must be positive" unless @electricity_rate > 0
      @errors << "Charger efficiency must be between 1% and 100%" unless @charger_efficiency > 0 && @charger_efficiency <= 1.0
      unless %w[level1 level2 dc_fast supercharger].include?(@charger_type)
        @errors << "Charger type must be level1, level2, dc_fast, or supercharger"
      end
    end
  end
end
