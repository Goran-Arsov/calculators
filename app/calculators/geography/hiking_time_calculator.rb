# frozen_string_literal: true

module Geography
  class HikingTimeCalculator
    attr_reader :errors

    NAISMITH_KM_PER_HOUR = 5.0
    NAISMITH_ASCENT_METERS_PER_HOUR = 600.0
    LANGMUIR_DESCENT_ADJUST_PER_300M = 10.0 / 60.0 # hours

    FITNESS_MULTIPLIERS = {
      "fast" => 0.80,
      "normal" => 1.00,
      "moderate" => 1.25,
      "slow" => 1.50
    }.freeze

    def initialize(distance_km:, ascent_m: 0, descent_m: 0, fitness: "normal")
      @distance_km = distance_km.to_f
      @ascent_m = ascent_m.to_f
      @descent_m = descent_m.to_f
      @fitness = fitness.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      base_hours = @distance_km / NAISMITH_KM_PER_HOUR
      ascent_hours = @ascent_m / NAISMITH_ASCENT_METERS_PER_HOUR
      descent_hours = descent_adjustment
      subtotal = base_hours + ascent_hours + descent_hours
      total = subtotal * FITNESS_MULTIPLIERS[@fitness]

      {
        valid: true,
        total_hours: total.round(3),
        total_minutes: (total * 60).round(0),
        formatted_time: format_hm(total),
        base_hours: base_hours.round(3),
        ascent_hours: ascent_hours.round(3),
        descent_hours: descent_hours.round(3),
        fitness_multiplier: FITNESS_MULTIPLIERS[@fitness]
      }
    end

    private

    def descent_adjustment
      return 0.0 unless @descent_m.positive?
      # Langmuir-style simplification: add 10 min per 300m of descent for steep sections.
      (@descent_m / 300.0) * LANGMUIR_DESCENT_ADJUST_PER_300M
    end

    def format_hm(hours)
      h = hours.floor
      m = ((hours - h) * 60).round
      if m == 60
        h += 1
        m = 0
      end
      "#{h}h #{m}m"
    end

    def validate!
      @errors << "Distance must be greater than zero" unless @distance_km.positive?
      @errors << "Ascent cannot be negative" if @ascent_m.negative?
      @errors << "Descent cannot be negative" if @descent_m.negative?
      unless FITNESS_MULTIPLIERS.key?(@fitness)
        @errors << "Fitness must be one of: fast, normal, moderate, slow"
      end
    end
  end
end
