# frozen_string_literal: true

module Health
  class ProteinPerMealCalculator
    attr_reader :errors

    # Research-based protein absorption ranges per meal
    MIN_PROTEIN_PER_MEAL = 20.0
    MAX_PROTEIN_PER_MEAL = 40.0

    def initialize(daily_protein_goal:, meals_per_day:)
      @daily_protein_goal = daily_protein_goal.to_f
      @meals_per_day = meals_per_day.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      protein_per_meal = @daily_protein_goal / @meals_per_day

      # Recommended range: at least MIN_PROTEIN_PER_MEAL, at most MAX_PROTEIN_PER_MEAL per meal
      recommended_min = [ protein_per_meal * 0.8, MIN_PROTEIN_PER_MEAL ].min
      recommended_max = [ protein_per_meal * 1.2, MAX_PROTEIN_PER_MEAL ].max

      # Classify distribution quality
      distribution = if protein_per_meal >= MIN_PROTEIN_PER_MEAL && protein_per_meal <= MAX_PROTEIN_PER_MEAL
                       "optimal"
      elsif protein_per_meal < MIN_PROTEIN_PER_MEAL
                       "low"
      else
                       "high"
      end

      {
        valid: true,
        protein_per_meal: protein_per_meal.round(1),
        daily_protein_goal: @daily_protein_goal.round(1),
        meals_per_day: @meals_per_day,
        recommended_min_per_meal: recommended_min.round(1),
        recommended_max_per_meal: recommended_max.round(1),
        distribution: distribution,
        protein_per_meal_oz: (protein_per_meal / 28.35).round(1)
      }
    end

    private

    def validate!
      @errors << "Daily protein goal must be positive" unless @daily_protein_goal > 0
      @errors << "Number of meals must be positive" unless @meals_per_day > 0
      @errors << "Number of meals must be at most 10" if @meals_per_day > 10
    end
  end
end
