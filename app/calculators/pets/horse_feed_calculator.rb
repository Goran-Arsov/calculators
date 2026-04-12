# frozen_string_literal: true

module Pets
  class HorseFeedCalculator
    attr_reader :errors

    VALID_ACTIVITY_LEVELS = %w[maintenance light moderate heavy intense].freeze
    LBS_TO_KG = 0.453592

    # Forage (hay) as percentage of body weight per day
    FORAGE_PERCENTAGES = {
      "maintenance" => 0.015,  # 1.5% of body weight
      "light" => 0.018,        # 1.8%
      "moderate" => 0.020,     # 2.0%
      "heavy" => 0.020,        # 2.0%
      "intense" => 0.020       # 2.0%
    }.freeze

    # Concentrate (grain) in lbs per day based on activity and body weight
    # Expressed as percentage of body weight
    GRAIN_PERCENTAGES = {
      "maintenance" => 0.0,     # No grain needed at maintenance
      "light" => 0.003,         # 0.3% of body weight
      "moderate" => 0.005,      # 0.5%
      "heavy" => 0.008,         # 0.8%
      "intense" => 0.012        # 1.2%
    }.freeze

    # Daily digestible energy requirements in Mcal per kg body weight
    ENERGY_REQUIREMENTS = {
      "maintenance" => 0.0333,
      "light" => 0.0400,
      "moderate" => 0.0467,
      "heavy" => 0.0533,
      "intense" => 0.0600
    }.freeze

    # Salt: 1-2 oz per day for average horse (1000 lbs)
    SALT_OZ_PER_1000_LBS = 1.5
    # Mineral supplement: typically 1-2 oz per day
    MINERAL_OZ_PER_1000_LBS = 1.5

    def initialize(weight_lbs:, activity_level: "maintenance")
      @weight_lbs = weight_lbs.to_f
      @activity_level = activity_level.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      weight_kg = @weight_lbs * LBS_TO_KG
      forage_lbs = @weight_lbs * FORAGE_PERCENTAGES[@activity_level]
      grain_lbs = @weight_lbs * GRAIN_PERCENTAGES[@activity_level]
      total_feed_lbs = forage_lbs + grain_lbs
      daily_energy_mcal = weight_kg * ENERGY_REQUIREMENTS[@activity_level]

      weight_ratio = @weight_lbs / 1000.0
      salt_oz = SALT_OZ_PER_1000_LBS * weight_ratio
      mineral_oz = MINERAL_OZ_PER_1000_LBS * weight_ratio

      # Water: approximately 0.5-1 gallon per 100 lbs body weight per day
      water_gallons_min = (@weight_lbs / 100.0) * 0.5
      water_gallons_max = (@weight_lbs / 100.0) * 1.0

      forage_to_total_ratio = total_feed_lbs > 0 ? (forage_lbs / total_feed_lbs * 100) : 100

      {
        valid: true,
        weight_lbs: @weight_lbs,
        weight_kg: weight_kg.round(0),
        activity_level: @activity_level,
        forage_lbs_per_day: forage_lbs.round(1),
        forage_kg_per_day: (forage_lbs * LBS_TO_KG).round(1),
        grain_lbs_per_day: grain_lbs.round(1),
        grain_kg_per_day: (grain_lbs * LBS_TO_KG).round(1),
        total_feed_lbs_per_day: total_feed_lbs.round(1),
        daily_energy_mcal: daily_energy_mcal.round(1),
        salt_oz_per_day: salt_oz.round(1),
        mineral_oz_per_day: mineral_oz.round(1),
        water_gallons_min: water_gallons_min.round(1),
        water_gallons_max: water_gallons_max.round(1),
        forage_to_total_ratio: forage_to_total_ratio.round(0)
      }
    end

    private

    def validate!
      @errors << "Weight must be positive" unless @weight_lbs > 0
      @errors << "Horse weight must be realistic (200-2500 lbs)" unless @weight_lbs >= 200 && @weight_lbs <= 2500
      @errors << "Activity level must be #{VALID_ACTIVITY_LEVELS.join(', ')}" unless VALID_ACTIVITY_LEVELS.include?(@activity_level)
    end
  end
end
