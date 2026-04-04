module Health
  class WaterIntakeCalculator
    attr_reader :errors

    BASE_MULTIPLIER = 0.033
    EXERCISE_ADDITION_LITERS = 0.5
    EXERCISE_INTERVAL_MINUTES = 30
    GLASS_SIZE_LITERS = 0.25

    def initialize(weight_kg:, exercise_minutes: 0)
      @weight_kg = weight_kg.to_f
      @exercise_minutes = exercise_minutes.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      base_liters = @weight_kg * BASE_MULTIPLIER
      exercise_addition = (@exercise_minutes / EXERCISE_INTERVAL_MINUTES) * EXERCISE_ADDITION_LITERS
      total_liters = base_liters + exercise_addition

      {
        valid: true,
        liters: total_liters.round(2),
        glasses: (total_liters / GLASS_SIZE_LITERS).round(0),
        ml: (total_liters * 1000).round(0)
      }
    end

    private

    def validate!
      @errors << "Weight must be positive" unless @weight_kg > 0
      @errors << "Exercise minutes cannot be negative" if @exercise_minutes < 0
    end
  end
end
