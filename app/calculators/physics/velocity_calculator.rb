# frozen_string_literal: true

module Physics
  class VelocityCalculator
    attr_reader :errors

    def initialize(distance: nil, time: nil, velocity: nil)
      @distance = distance&.to_f
      @time = time&.to_f
      @velocity = velocity&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @velocity.nil?
        vel = @distance / @time
        { valid: true, velocity: vel.round(4), distance: @distance.round(4), time: @time.round(4), solved_for: :velocity }
      elsif @distance.nil?
        dist = @velocity * @time
        { valid: true, velocity: @velocity.round(4), distance: dist.round(4), time: @time.round(4), solved_for: :distance }
      else
        t = @distance / @velocity
        { valid: true, velocity: @velocity.round(4), distance: @distance.round(4), time: t.round(4), solved_for: :time }
      end
    end

    private

    def validate!
      provided = { distance: @distance, time: @time, velocity: @velocity }.compact
      if provided.size < 2
        @errors << "Provide at least two values"
        return
      end

      @errors << "Distance must be positive" if @distance && @distance <= 0
      @errors << "Time must be positive" if @time && @time <= 0
      @errors << "Velocity must be positive" if @velocity && @velocity <= 0
    end
  end
end
