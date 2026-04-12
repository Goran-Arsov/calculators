module Automotive
  class EvRangeCalculator
    attr_reader :errors

    def initialize(battery_capacity_kwh:, efficiency_wh_per_mile: 250, speed_mph: 65,
                   temperature_f: 70, hvac_on: false, cargo_weight_lbs: 0)
      @battery_capacity_kwh = battery_capacity_kwh.to_f
      @efficiency_wh_per_mile = efficiency_wh_per_mile.to_f
      @speed_mph = speed_mph.to_f
      @temperature_f = temperature_f.to_f
      @hvac_on = hvac_on.to_s == "true" || hvac_on == true
      @cargo_weight_lbs = cargo_weight_lbs.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Base range at rated efficiency
      base_range = (@battery_capacity_kwh * 1000.0) / @efficiency_wh_per_mile

      # Speed adjustment: efficiency degrades above ~55 mph due to aerodynamic drag
      speed_factor = if @speed_mph <= 55
        1.0
      elsif @speed_mph <= 75
        1.0 - ((@speed_mph - 55) * 0.012) # ~1.2% loss per mph above 55
      else
        1.0 - (20 * 0.012) - ((@speed_mph - 75) * 0.018) # steeper loss above 75
      end

      # Temperature adjustment
      temp_factor = if @temperature_f >= 60 && @temperature_f <= 80
        1.0
      elsif @temperature_f < 60
        # Cold weather reduces range
        1.0 - [ ((60 - @temperature_f) * 0.005), 0.40 ].min
      else
        # Hot weather slightly reduces range
        1.0 - [ ((@temperature_f - 80) * 0.003), 0.15 ].min
      end

      # HVAC adjustment
      hvac_factor = @hvac_on ? 0.90 : 1.0

      # Cargo weight adjustment (roughly 1% range loss per 100 lbs)
      cargo_factor = 1.0 - (@cargo_weight_lbs / 100.0 * 0.01)
      cargo_factor = [ cargo_factor, 0.70 ].max

      adjusted_range = base_range * speed_factor * temp_factor * hvac_factor * cargo_factor
      adjusted_efficiency = @battery_capacity_kwh * 1000.0 / adjusted_range

      # Estimated charge time (Level 2 at 7.2kW, DC fast at 150kW)
      level2_charge_hours = @battery_capacity_kwh / 7.2
      dc_fast_charge_minutes = (@battery_capacity_kwh * 0.8 / 150.0) * 60 # 80% charge

      {
        valid: true,
        battery_capacity_kwh: @battery_capacity_kwh.round(1),
        rated_efficiency_wh_per_mile: @efficiency_wh_per_mile.round(0),
        base_range_miles: base_range.round(1),
        adjusted_range_miles: adjusted_range.round(1),
        adjusted_efficiency_wh_per_mile: adjusted_efficiency.round(0),
        speed_factor: speed_factor.round(3),
        temperature_factor: temp_factor.round(3),
        hvac_on: @hvac_on,
        cargo_weight_lbs: @cargo_weight_lbs.round(0),
        level2_charge_hours: level2_charge_hours.round(1),
        dc_fast_charge_minutes: dc_fast_charge_minutes.round(0),
        range_loss_pct: ((1.0 - adjusted_range / base_range) * 100).round(1)
      }
    end

    private

    def validate!
      @errors << "Battery capacity must be positive" unless @battery_capacity_kwh > 0
      @errors << "Efficiency must be positive" unless @efficiency_wh_per_mile > 0
      @errors << "Speed must be positive" unless @speed_mph > 0
      @errors << "Cargo weight cannot be negative" if @cargo_weight_lbs < 0
    end
  end
end
