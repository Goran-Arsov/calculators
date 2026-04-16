# frozen_string_literal: true

module Health
  class BmiCalculator
    attr_reader :errors

    def initialize(weight:, height:, unit_system: "metric")
      @weight = weight.to_f
      @height = height.to_f
      @unit_system = unit_system.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      bmi = calculate_bmi
      category = categorize(bmi)
      healthy_range = healthy_weight_range

      {
        valid: true,
        bmi: bmi.round(1),
        category: category,
        healthy_min: healthy_range[:min].round(1),
        healthy_max: healthy_range[:max].round(1)
      }
    end

    private

    def calculate_bmi
      if @unit_system == "imperial"
        # weight in lbs, height in inches
        (@weight / @height**2) * 703
      else
        # weight in kg, height in cm
        height_m = @height / 100.0
        @weight / height_m**2
      end
    end

    def categorize(bmi)
      case bmi
      when 0...18.5 then "Underweight"
      when 18.5...25 then "Normal weight"
      when 25...30 then "Overweight"
      else "Obese"
      end
    end

    def healthy_weight_range
      if @unit_system == "imperial"
        height_m = @height * 0.0254
      else
        height_m = @height / 100.0
      end
      {
        min: 18.5 * height_m**2 * (@unit_system == "imperial" ? 2.205 : 1),
        max: 24.9 * height_m**2 * (@unit_system == "imperial" ? 2.205 : 1)
      }
    end

    def validate!
      @errors << "Weight must be positive" unless @weight > 0
      @errors << "Height must be positive" unless @height > 0
      @errors << "Invalid unit system" unless %w[metric imperial].include?(@unit_system)

      if @unit_system == "imperial"
        @errors << "Weight cannot exceed 1500 lbs" if @weight > 1500
        @errors << "Height cannot exceed 120 inches" if @height > 120
      else
        @errors << "Weight cannot exceed 700 kg" if @weight > 700
        @errors << "Height cannot exceed 300 cm" if @height > 300
      end
    end
  end
end
