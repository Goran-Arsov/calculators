# frozen_string_literal: true

module Automotive
  class ZeroToSixtyCalculator
    attr_reader :errors

    def initialize(horsepower:, curb_weight_lbs:, drivetrain: "rwd", tire_type: "all_season")
      @horsepower = horsepower.to_f
      @curb_weight_lbs = curb_weight_lbs.to_f
      @drivetrain = drivetrain.to_s
      @tire_type = tire_type.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      power_to_weight = @curb_weight_lbs / @horsepower

      # Empirical 0-60 formula based on power-to-weight ratio
      # Base: t = (weight/hp)^0.75 * constant
      base_zero_to_sixty = (power_to_weight ** 0.75) * 0.95

      # Drivetrain adjustment
      drivetrain_factor = case @drivetrain
      when "awd" then 0.90
      when "fwd" then 1.05
      else 1.00 # rwd baseline
      end

      # Tire adjustment
      tire_factor = case @tire_type
      when "summer" then 0.95
      when "performance" then 0.90
      when "winter" then 1.10
      else 1.00 # all_season baseline
      end

      zero_to_sixty = base_zero_to_sixty * drivetrain_factor * tire_factor

      # Quarter mile estimation using Roger Huntington formula
      # ET = 6.290 * (weight/hp)^(1/3)
      quarter_mile_time = 6.290 * (power_to_weight ** (1.0 / 3.0))

      # Quarter mile trap speed (mph)
      # Speed = 224 / (weight/hp)^(1/3)
      quarter_mile_speed = 224.0 / (power_to_weight ** (1.0 / 3.0))

      # Estimated 0-30 time (roughly 35-40% of 0-60)
      zero_to_thirty = zero_to_sixty * 0.37

      {
        valid: true,
        zero_to_sixty_seconds: zero_to_sixty.round(2),
        zero_to_thirty_seconds: zero_to_thirty.round(2),
        quarter_mile_seconds: quarter_mile_time.round(2),
        quarter_mile_mph: quarter_mile_speed.round(1),
        power_to_weight_ratio: power_to_weight.round(2),
        horsepower: @horsepower.round(0),
        curb_weight_lbs: @curb_weight_lbs.round(0),
        drivetrain: @drivetrain,
        tire_type: @tire_type
      }
    end

    private

    def validate!
      @errors << "Horsepower must be positive" unless @horsepower > 0
      @errors << "Curb weight must be positive" unless @curb_weight_lbs > 0
      unless %w[rwd fwd awd].include?(@drivetrain)
        @errors << "Drivetrain must be rwd, fwd, or awd"
      end
      unless %w[all_season summer performance winter].include?(@tire_type)
        @errors << "Tire type must be all_season, summer, performance, or winter"
      end
    end
  end
end
