# frozen_string_literal: true

module Construction
  class ElectricalLoadCalculator
    attr_reader :errors

    WATTS_PER_SQFT_LIGHTING = 3
    SMALL_APPLIANCE_WATTS = 3000
    LAUNDRY_WATTS = 1500
    RANGE_WATTS = 8000
    DRYER_WATTS = 5000
    WATER_HEATER_WATTS = 4500
    WATTS_PER_AC_TON = 3517
    WATTS_PER_SQFT_HEAT = 10
    VOLTAGE = 240

    DEMAND_FACTOR_FIRST = 3000
    DEMAND_FACTOR_REMAINDER_RATE = 0.35

    def initialize(square_footage:, has_electric_range: false, has_electric_dryer: false, has_electric_water_heater: false, ac_tons: 0, has_electric_heat: false)
      @square_footage = square_footage.to_f
      @has_electric_range = to_bool(has_electric_range)
      @has_electric_dryer = to_bool(has_electric_dryer)
      @has_electric_water_heater = to_bool(has_electric_water_heater)
      @ac_tons = ac_tons.to_f
      @has_electric_heat = to_bool(has_electric_heat)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      general_lighting = @square_footage * WATTS_PER_SQFT_LIGHTING
      general_load = general_lighting + SMALL_APPLIANCE_WATTS + LAUNDRY_WATTS

      # Apply demand factor: first 3000W at 100%, remainder at 35%
      if general_load <= DEMAND_FACTOR_FIRST
        demand_adjusted = general_load
      else
        demand_adjusted = DEMAND_FACTOR_FIRST + ((general_load - DEMAND_FACTOR_FIRST) * DEMAND_FACTOR_REMAINDER_RATE)
      end

      total_watts = demand_adjusted

      total_watts += RANGE_WATTS if @has_electric_range
      total_watts += DRYER_WATTS if @has_electric_dryer
      total_watts += WATER_HEATER_WATTS if @has_electric_water_heater

      ac_watts = @ac_tons * WATTS_PER_AC_TON
      heat_watts = @has_electric_heat ? @square_footage * WATTS_PER_SQFT_HEAT : 0
      # Use larger of AC or heat, not both
      total_watts += [ac_watts, heat_watts].max

      total_amps = (total_watts / VOLTAGE.to_f).round(1)
      recommended_panel = determine_panel_size(total_amps)

      {
        valid: true,
        general_lighting_watts: general_lighting.round(0),
        total_load_watts: total_watts.round(0),
        total_amps_240v: total_amps,
        recommended_panel_amps: recommended_panel
      }
    end

    private

    def validate!
      @errors << "Square footage must be greater than zero" unless @square_footage.positive?
      @errors << "AC tons cannot be negative" if @ac_tons.negative?
      @errors << "AC tons cannot exceed 5" if @ac_tons > 5
    end

    def determine_panel_size(amps)
      if amps <= 100
        100
      elsif amps <= 150
        150
      elsif amps <= 200
        200
      else
        400
      end
    end

    def to_bool(value)
      return value if value.is_a?(TrueClass) || value.is_a?(FalseClass)

      %w[true 1 yes on].include?(value.to_s.downcase)
    end
  end
end
