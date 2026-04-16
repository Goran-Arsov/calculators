# frozen_string_literal: true

module Health
  class CalorieCalculator
    include Health::Constants

    attr_reader :errors

    def initialize(age:, sex:, weight:, height:, activity_level:, unit_system: "metric")
      @age = age.to_i
      @sex = sex.to_s
      @weight = weight.to_f
      @height = height.to_f
      @activity_level = activity_level.to_s
      @unit_system = unit_system.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      bmr = calculate_bmr
      multiplier = ACTIVITY_MULTIPLIERS[@activity_level]
      tdee = bmr * multiplier

      {
        valid: true,
        bmr: bmr.round(0),
        tdee: tdee.round(0),
        mild_loss: (tdee - 250).round(0),
        weight_loss: (tdee - 500).round(0),
        mild_gain: (tdee + 250).round(0),
        weight_gain: (tdee + 500).round(0)
      }
    end

    private

    def calculate_bmr
      weight_kg = @unit_system == "imperial" ? @weight * 0.453592 : @weight
      height_cm = @unit_system == "imperial" ? @height * 2.54 : @height

      # Mifflin-St Jeor equation
      if @sex == "male"
        10 * weight_kg + 6.25 * height_cm - 5 * @age + 5
      else
        10 * weight_kg + 6.25 * height_cm - 5 * @age - 161
      end
    end

    def validate!
      @errors << "Age must be positive" unless @age > 0
      @errors << "Age cannot exceed 150" if @age > 150
      @errors << "Sex must be male or female" unless %w[male female].include?(@sex)
      @errors << "Weight must be positive" unless @weight > 0
      @errors << "Height must be positive" unless @height > 0
      @errors << "Invalid activity level" unless ACTIVITY_MULTIPLIERS.key?(@activity_level)
      @errors << "Invalid unit system" unless %w[metric imperial].include?(@unit_system)
    end
  end
end
