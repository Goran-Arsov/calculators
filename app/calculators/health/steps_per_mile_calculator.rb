# frozen_string_literal: true

module Health
  class StepsPerMileCalculator
    attr_reader :errors

    KM_PER_MILE = 1.60934
    FEET_PER_MILE = 5_280.0
    METERS_PER_FOOT = 0.3048
    # Rough calorie burn per step (average for walking)
    CALORIES_PER_STEP = 0.04

    def initialize(total_steps:, distance:, unit: "miles")
      @total_steps = total_steps.to_f
      @distance = distance.to_f
      @unit = unit.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      distance_miles = @unit == "km" ? @distance / KM_PER_MILE : @distance
      distance_km = @unit == "km" ? @distance : @distance * KM_PER_MILE

      steps_per_mile = @total_steps / distance_miles
      steps_per_km = @total_steps / distance_km
      estimated_calories = @total_steps * CALORIES_PER_STEP

      stride_length_ft = (FEET_PER_MILE / steps_per_mile).round(2)
      stride_length_m = (stride_length_ft * METERS_PER_FOOT).round(2)

      {
        valid: true,
        steps_per_mile: steps_per_mile.round(0).to_i,
        steps_per_km: steps_per_km.round(0).to_i,
        estimated_calories: estimated_calories.round(0).to_i,
        stride_length_ft: stride_length_ft,
        stride_length_m: stride_length_m,
        total_steps: @total_steps.round(0).to_i,
        distance_miles: distance_miles.round(2),
        distance_km: distance_km.round(2)
      }
    end

    private

    def validate!
      @errors << "Total steps must be positive" unless @total_steps > 0
      @errors << "Distance must be positive" unless @distance > 0
      @errors << "Unit must be miles or km" unless %w[miles km].include?(@unit)
    end
  end
end
