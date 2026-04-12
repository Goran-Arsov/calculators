# frozen_string_literal: true

module Pets
  class PuppyWeightPredictorCalculator
    attr_reader :errors

    VALID_BREED_SIZES = %w[toy small medium large giant].freeze

    # Growth multipliers by breed size: adult_weight ≈ current_weight × multiplier_for_age
    # Based on growth curves from veterinary research
    # The multiplier decreases as the puppy ages (closer to adult weight)
    BREED_ADULT_WEIGHTS = {
      "toy" => { min: 4, max: 10 },       # lbs
      "small" => { min: 10, max: 25 },
      "medium" => { min: 25, max: 55 },
      "large" => { min: 55, max: 90 },
      "giant" => { min: 90, max: 200 }
    }.freeze

    # Percentage of adult weight reached at each age in weeks
    # Based on breed size growth curves
    GROWTH_PERCENTAGES = {
      "toy" => { 8 => 0.47, 12 => 0.60, 16 => 0.72, 20 => 0.82, 24 => 0.90, 32 => 0.95, 40 => 0.98, 52 => 1.0 },
      "small" => { 8 => 0.42, 12 => 0.55, 16 => 0.67, 20 => 0.77, 24 => 0.85, 32 => 0.92, 40 => 0.97, 52 => 1.0 },
      "medium" => { 8 => 0.33, 12 => 0.45, 16 => 0.55, 20 => 0.65, 24 => 0.75, 32 => 0.85, 40 => 0.92, 52 => 0.97, 65 => 1.0 },
      "large" => { 8 => 0.25, 12 => 0.35, 16 => 0.45, 20 => 0.52, 24 => 0.60, 32 => 0.72, 40 => 0.82, 52 => 0.90, 65 => 0.95, 78 => 1.0 },
      "giant" => { 8 => 0.20, 12 => 0.28, 16 => 0.37, 20 => 0.44, 24 => 0.50, 32 => 0.60, 40 => 0.70, 52 => 0.80, 65 => 0.88, 78 => 0.95, 104 => 1.0 }
    }.freeze

    def initialize(current_weight_lbs:, age_weeks:, breed_size:)
      @current_weight_lbs = current_weight_lbs.to_f
      @age_weeks = age_weeks.to_i
      @breed_size = breed_size.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      growth_pct = interpolate_growth_percentage
      predicted_adult_weight = @current_weight_lbs / growth_pct
      weight_range = BREED_ADULT_WEIGHTS[@breed_size]

      # Clamp prediction to breed size range for realism
      clamped_weight = predicted_adult_weight.clamp(weight_range[:min].to_f, weight_range[:max].to_f * 1.2)

      remaining_growth_pct = ((1.0 - growth_pct) * 100)
      weeks_to_adult = estimate_weeks_to_adult

      {
        valid: true,
        current_weight_lbs: @current_weight_lbs,
        age_weeks: @age_weeks,
        breed_size: @breed_size,
        growth_percentage: (growth_pct * 100).round(1),
        predicted_adult_weight_lbs: clamped_weight.round(1),
        predicted_adult_weight_kg: (clamped_weight * 0.453592).round(1),
        remaining_growth_percentage: remaining_growth_pct.round(1),
        estimated_weeks_to_adult: weeks_to_adult,
        breed_weight_range_min: weight_range[:min],
        breed_weight_range_max: weight_range[:max]
      }
    end

    private

    def interpolate_growth_percentage
      curve = GROWTH_PERCENTAGES[@breed_size]
      weeks = curve.keys.sort

      return curve[weeks.first] if @age_weeks <= weeks.first
      return curve[weeks.last] if @age_weeks >= weeks.last

      # Find surrounding data points and interpolate
      lower_week = weeks.select { |w| w <= @age_weeks }.last
      upper_week = weeks.select { |w| w > @age_weeks }.first

      lower_pct = curve[lower_week]
      upper_pct = curve[upper_week]

      # Linear interpolation
      ratio = (@age_weeks - lower_week).to_f / (upper_week - lower_week)
      lower_pct + (upper_pct - lower_pct) * ratio
    end

    def estimate_weeks_to_adult
      curve = GROWTH_PERCENTAGES[@breed_size]
      adult_week = curve.keys.sort.find { |w| curve[w] >= 1.0 }
      remaining = adult_week ? [ adult_week - @age_weeks, 0 ].max : 0
      remaining
    end

    def validate!
      @errors << "Current weight must be positive" unless @current_weight_lbs > 0
      @errors << "Age must be at least 4 weeks" unless @age_weeks >= 4
      @errors << "Age cannot exceed 104 weeks for a puppy" if @age_weeks > 104
      @errors << "Breed size must be #{VALID_BREED_SIZES.join(', ')}" unless VALID_BREED_SIZES.include?(@breed_size)
    end
  end
end
