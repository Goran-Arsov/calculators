# frozen_string_literal: true

module Relationships
  class DatingPoolCalculator
    attr_reader :errors

    # Demographic assumptions
    PERCENT_IN_AGE_RANGE = 0.015 # approx per year of age for adult population
    SINGLE_RATE = 0.45
    COMPATIBLE_RATE = 0.20 # interests, values, preferences
    ATTRACTION_RATE = 0.10

    def initialize(city_population:, age_min:, age_max:, gender_preference_pct: 0.5)
      @city_population = city_population.to_f
      @age_min = age_min.to_i
      @age_max = age_max.to_i
      @gender_pct = gender_preference_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      years_spread = @age_max - @age_min + 1
      in_age_range = @city_population * (years_spread * PERCENT_IN_AGE_RANGE)
      of_preferred_gender = in_age_range * @gender_pct
      singles = of_preferred_gender * SINGLE_RATE
      compatible = singles * COMPATIBLE_RATE
      mutually_attracted = compatible * ATTRACTION_RATE

      {
        valid: true,
        in_age_range: in_age_range.round,
        of_preferred_gender: of_preferred_gender.round,
        singles: singles.round,
        compatible: compatible.round,
        mutually_attracted: mutually_attracted.round
      }
    end

    private

    def validate!
      @errors << "City population must be greater than zero" unless @city_population.positive?
      @errors << "Age range is invalid" if @age_min < 18 || @age_max < @age_min
      @errors << "Gender preference must be between 0 and 1" unless (0.0..1.0).cover?(@gender_pct)
    end
  end
end
