module Health
  class OneRepMaxCalculator
    attr_reader :errors

    MIN_REPS = 1
    MAX_REPS = 30

    def initialize(weight:, reps:)
      @weight = weight.to_f
      @reps = reps.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      epley = calculate_epley
      brzycki = calculate_brzycki
      average = (epley + brzycki) / 2.0

      {
        valid: true,
        epley_1rm: epley.round(1),
        brzycki_1rm: brzycki.round(1),
        average_1rm: average.round(1)
      }
    end

    private

    def calculate_epley
      if @reps == 1
        @weight
      else
        @weight * (1 + @reps / 30.0)
      end
    end

    def calculate_brzycki
      if @reps == 1
        @weight
      else
        @weight * 36.0 / (37 - @reps)
      end
    end

    def validate!
      @errors << "Weight must be positive" unless @weight > 0
      @errors << "Reps must be between #{MIN_REPS} and #{MAX_REPS}" unless @reps.between?(MIN_REPS, MAX_REPS)
    end
  end
end
