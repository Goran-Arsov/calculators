# frozen_string_literal: true

module Health
  class TdeeCalculator
    include Health::Constants

    attr_reader :errors

    def initialize(weight_kg:, height_cm:, age:, gender:, activity_level:)
      @weight_kg = weight_kg.to_f
      @height_cm = height_cm.to_f
      @age = age.to_i
      @gender = gender.to_s
      @activity_level = activity_level.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      bmr = calculate_bmr
      activity_data = ACTIVITY_LEVELS[@activity_level]
      tdee = bmr * activity_data[:multiplier]

      {
        valid: true,
        bmr: bmr.round(0),
        tdee: tdee.round(0),
        activity_label: activity_data[:label]
      }
    end

    private

    def calculate_bmr
      # Mifflin-St Jeor equation
      if @gender == "male"
        10 * @weight_kg + 6.25 * @height_cm - 5 * @age + 5
      else
        10 * @weight_kg + 6.25 * @height_cm - 5 * @age - 161
      end
    end

    def validate!
      @errors << "Weight must be positive" unless @weight_kg > 0
      @errors << "Height must be positive" unless @height_cm > 0
      @errors << "Age must be positive" unless @age > 0
      @errors << "Age must be realistic (1-120)" unless @age.between?(1, 120)
      @errors << "Gender must be male or female" unless %w[male female].include?(@gender)
      @errors << "Invalid activity level" unless ACTIVITY_LEVELS.key?(@activity_level)
    end
  end
end
