# frozen_string_literal: true

module Physics
  class KineticEnergyCalculator
    attr_reader :errors

    def initialize(energy: nil, mass: nil, velocity: nil)
      @energy = energy&.to_f
      @mass = mass&.to_f
      @velocity = velocity&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @energy.nil?
        ke = 0.5 * @mass * @velocity**2
        { valid: true, energy: ke.round(4), mass: @mass.round(4), velocity: @velocity.round(4), solved_for: :energy }
      elsif @mass.nil?
        m = (2 * @energy) / @velocity**2
        { valid: true, energy: @energy.round(4), mass: m.round(4), velocity: @velocity.round(4), solved_for: :mass }
      else
        v = ::Math.sqrt(2 * @energy / @mass)
        { valid: true, energy: @energy.round(4), mass: @mass.round(4), velocity: v.round(4), solved_for: :velocity }
      end
    end

    private

    def validate!
      provided = { energy: @energy, mass: @mass, velocity: @velocity }.compact
      if provided.size < 2
        @errors << "Provide at least two values"
        return
      end

      @errors << "Energy must be non-negative" if @energy && @energy < 0
      @errors << "Mass must be positive" if @mass && @mass <= 0
      @errors << "Velocity cannot be zero when solving for mass" if @velocity && @velocity.zero? && @mass.nil?
    end
  end
end
