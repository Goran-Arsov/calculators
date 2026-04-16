# frozen_string_literal: true

module Health
  class KetoCalculator
    include Health::Constants

    attr_reader :errors

    CALORIES_PER_GRAM_PROTEIN = 4
    CALORIES_PER_GRAM_CARBS = 4
    CALORIES_PER_GRAM_FAT = 9

    # Standard keto macro ratios
    KETO_FAT_PERCENT = 70
    KETO_PROTEIN_PERCENT = 25
    KETO_CARB_PERCENT = 5

    # Net carbs target for keto (strict keto: 20g, standard: 25g)
    MAX_NET_CARBS = 25

    GOALS = {
      "maintain" => 0,
      "lose" => -500,
      "gain" => 500
    }.freeze

    def initialize(weight:, height:, age:, gender:, activity_level:, goal: "maintain", unit_system: "metric")
      @weight = weight.to_f
      @height = height.to_f
      @age = age.to_i
      @gender = gender.to_s
      @activity_level = activity_level.to_s
      @goal = goal.to_s
      @unit_system = unit_system.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      weight_kg = @unit_system == "imperial" ? @weight * 0.453592 : @weight
      height_cm = @unit_system == "imperial" ? @height * 2.54 : @height

      bmr = calculate_bmr(weight_kg, height_cm)
      tdee = bmr * ACTIVITY_MULTIPLIERS[@activity_level]
      calorie_adjustment = GOALS[@goal]
      daily_calories = tdee + calorie_adjustment

      # Calculate keto macros
      fat_calories = daily_calories * KETO_FAT_PERCENT / 100.0
      protein_calories = daily_calories * KETO_PROTEIN_PERCENT / 100.0
      carb_calories = daily_calories * KETO_CARB_PERCENT / 100.0

      fat_grams = fat_calories / CALORIES_PER_GRAM_FAT
      protein_grams = protein_calories / CALORIES_PER_GRAM_PROTEIN
      carb_grams = carb_calories / CALORIES_PER_GRAM_CARBS

      # Cap net carbs at MAX_NET_CARBS, redistribute excess to fat
      if carb_grams > MAX_NET_CARBS
        excess_carb_calories = (carb_grams - MAX_NET_CARBS) * CALORIES_PER_GRAM_CARBS
        carb_grams = MAX_NET_CARBS.to_f
        carb_calories = carb_grams * CALORIES_PER_GRAM_CARBS
        fat_calories += excess_carb_calories
        fat_grams = fat_calories / CALORIES_PER_GRAM_FAT
      end

      {
        valid: true,
        bmr: bmr.round(0),
        tdee: tdee.round(0),
        daily_calories: daily_calories.round(0),
        fat_grams: fat_grams.round(0),
        protein_grams: protein_grams.round(0),
        carb_grams: carb_grams.round(0),
        fat_calories: fat_calories.round(0),
        protein_calories: protein_calories.round(0),
        carb_calories: carb_calories.round(0),
        fat_percent: calculate_actual_percent(fat_calories, daily_calories),
        protein_percent: calculate_actual_percent(protein_calories, daily_calories),
        carb_percent: calculate_actual_percent(carb_calories, daily_calories)
      }
    end

    private

    # Mifflin-St Jeor equation
    def calculate_bmr(weight_kg, height_cm)
      if @gender == "male"
        10 * weight_kg + 6.25 * height_cm - 5 * @age + 5
      else
        10 * weight_kg + 6.25 * height_cm - 5 * @age - 161
      end
    end

    def calculate_actual_percent(macro_calories, total_calories)
      return 0 if total_calories <= 0
      (macro_calories / total_calories * 100).round(0)
    end

    def validate!
      @errors << "Weight must be positive" unless @weight > 0
      @errors << "Height must be positive" unless @height > 0
      @errors << "Age must be positive" unless @age > 0
      @errors << "Age must be realistic (1-120)" unless @age.between?(1, 120)
      @errors << "Gender must be male or female" unless %w[male female].include?(@gender)
      @errors << "Invalid activity level" unless ACTIVITY_MULTIPLIERS.key?(@activity_level)
      @errors << "Invalid goal" unless GOALS.key?(@goal)
      @errors << "Invalid unit system" unless %w[metric imperial].include?(@unit_system)
    end
  end
end
