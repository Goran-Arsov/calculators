module Health
  class MacroCalculator
    attr_reader :errors

    CALORIES_PER_GRAM_PROTEIN = 4
    CALORIES_PER_GRAM_CARBS = 4
    CALORIES_PER_GRAM_FAT = 9

    # Ratios: [protein%, carbs%, fat%]
    GOAL_RATIOS = {
      "maintain" => { protein: 30, carbs: 40, fat: 30 },
      "cut" => { protein: 40, carbs: 30, fat: 30 },
      "bulk" => { protein: 25, carbs: 50, fat: 25 }
    }.freeze

    def initialize(calories:, goal:)
      @calories = calories.to_f
      @goal = goal.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      ratios = GOAL_RATIOS[@goal]

      protein_cal = (@calories * ratios[:protein] / 100.0).round(0)
      carbs_cal = (@calories * ratios[:carbs] / 100.0).round(0)
      fat_cal = (@calories * ratios[:fat] / 100.0).round(0)

      protein_g = (protein_cal / CALORIES_PER_GRAM_PROTEIN.to_f).round(0)
      carbs_g = (carbs_cal / CALORIES_PER_GRAM_CARBS.to_f).round(0)
      fat_g = (fat_cal / CALORIES_PER_GRAM_FAT.to_f).round(0)

      {
        valid: true,
        protein_g: protein_g,
        carbs_g: carbs_g,
        fat_g: fat_g,
        protein_cal: protein_cal,
        carbs_cal: carbs_cal,
        fat_cal: fat_cal
      }
    end

    private

    def validate!
      @errors << "Calories must be positive" unless @calories > 0
      @errors << "Goal must be maintain, cut, or bulk" unless GOAL_RATIOS.key?(@goal)
    end
  end
end
