module Health
  class BiologicalAgeCalculator
    attr_reader :errors

    def initialize(chronological_age:, exercise_hours_per_week:, sleep_hours_per_night:,
                   diet_quality:, stress_level:, is_smoker:, bmi:)
      @chronological_age = chronological_age.to_i
      @exercise_hours = exercise_hours_per_week.to_f
      @sleep_hours = sleep_hours_per_night.to_f
      @diet_quality = diet_quality.to_i
      @stress_level = stress_level.to_i
      @is_smoker = ActiveModel::Type::Boolean.new.cast(is_smoker)
      @bmi = bmi.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      breakdown = factor_breakdown
      total_adjustment = breakdown.values.sum
      bio_age = @chronological_age + total_adjustment

      {
        valid: true,
        biological_age: bio_age,
        age_difference: total_adjustment,
        factor_breakdown: breakdown,
        top_recommendations: generate_recommendations(breakdown)
      }
    end

    private

    def factor_breakdown
      {
        exercise: exercise_adjustment,
        sleep: sleep_adjustment,
        diet: diet_adjustment,
        stress: stress_adjustment,
        smoking: smoking_adjustment,
        bmi: bmi_adjustment
      }
    end

    def exercise_adjustment
      if @exercise_hours > 5
        -3
      elsif @exercise_hours >= 3
        -2
      elsif @exercise_hours >= 1
        -1
      else
        1
      end
    end

    def sleep_adjustment
      if @sleep_hours >= 7 && @sleep_hours <= 9
        -1
      elsif @sleep_hours >= 6 && @sleep_hours < 7
        0
      else
        2
      end
    end

    def diet_adjustment
      case @diet_quality
      when 5 then -3
      when 4 then -1
      when 3 then 0
      when 2 then 1
      else 3
      end
    end

    def stress_adjustment
      case @stress_level
      when 1 then -2
      when 2 then -1
      when 3 then 0
      when 4 then 2
      else 4
      end
    end

    def smoking_adjustment
      @is_smoker ? 5 : 0
    end

    def bmi_adjustment
      case @bmi
      when 18.5...25 then -1
      when 25...30 then 1
      when 30..Float::INFINITY then 3
      else 1 # underweight (<18.5)
      end
    end

    def generate_recommendations(breakdown)
      recommendations = []

      if breakdown[:smoking] > 0
        recommendations << "Quitting smoking could reduce your biological age by up to 5 years."
      end
      if breakdown[:stress] > 0
        recommendations << "Reducing stress through meditation, exercise, or therapy could lower your biological age."
      end
      if breakdown[:exercise] >= 0
        recommendations << "Increasing physical activity to at least 3-5 hours per week can significantly improve your biological age."
      end
      if breakdown[:diet] > 0
        recommendations << "Improving your diet quality with more whole foods, fruits, and vegetables can reduce biological aging."
      end
      if breakdown[:sleep] > 0
        recommendations << "Aim for 7-9 hours of quality sleep per night to support cellular repair and longevity."
      end
      if breakdown[:bmi] > 0
        recommendations << "Working toward a BMI in the 18.5-24.9 range can improve your overall health markers."
      end

      recommendations.first(3)
    end

    def validate!
      @errors << "Age must be between 1 and 120" unless @chronological_age >= 1 && @chronological_age <= 120
      @errors << "Exercise hours must be zero or positive" unless @exercise_hours >= 0
      @errors << "Sleep hours must be between 0 and 24" unless @sleep_hours >= 0 && @sleep_hours <= 24
      @errors << "Diet quality must be between 1 and 5" unless @diet_quality >= 1 && @diet_quality <= 5
      @errors << "Stress level must be between 1 and 5" unless @stress_level >= 1 && @stress_level <= 5
      @errors << "BMI must be positive" unless @bmi > 0
      @errors << "BMI cannot exceed 100" if @bmi > 100
    end
  end
end
