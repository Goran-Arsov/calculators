# frozen_string_literal: true

module Pets
  class CatAgeCalculator
    attr_reader :errors

    # Veterinary-standard cat age conversion formula
    # First year = 15 human years, second year = +9, each year after = +4
    FIRST_YEAR_EQUIVALENT = 15
    SECOND_YEAR_ADDITION = 9
    SUBSEQUENT_YEAR_ADDITION = 4
    MAX_CAT_AGE = 35

    def initialize(cat_age:, unit: "years")
      @cat_age = cat_age.to_f
      @unit = unit.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      age_in_years = convert_to_years
      human_age = calculate_human_age(age_in_years)
      life_stage = determine_life_stage(age_in_years)

      {
        valid: true,
        cat_age: @cat_age,
        unit: @unit,
        age_in_years: age_in_years.round(2),
        human_age: human_age.round(1),
        life_stage: life_stage
      }
    end

    private

    def convert_to_years
      case @unit
      when "months"
        @cat_age / 12.0
      else
        @cat_age
      end
    end

    def calculate_human_age(years)
      if years <= 1
        years * FIRST_YEAR_EQUIVALENT
      elsif years <= 2
        FIRST_YEAR_EQUIVALENT + (years - 1) * SECOND_YEAR_ADDITION
      else
        FIRST_YEAR_EQUIVALENT + SECOND_YEAR_ADDITION + (years - 2) * SUBSEQUENT_YEAR_ADDITION
      end
    end

    def determine_life_stage(years)
      case years
      when 0...0.5 then "Kitten"
      when 0.5...2 then "Junior"
      when 2...6 then "Prime"
      when 6...10 then "Mature"
      when 10...14 then "Senior"
      else "Geriatric"
      end
    end

    def validate!
      @errors << "Cat age must be positive" unless @cat_age > 0
      max_age = @unit == "months" ? MAX_CAT_AGE * 12 : MAX_CAT_AGE
      @errors << "Cat age cannot exceed #{max_age} #{@unit}" if @cat_age > max_age
      @errors << "Unit must be years or months" unless %w[years months].include?(@unit)
    end
  end
end
