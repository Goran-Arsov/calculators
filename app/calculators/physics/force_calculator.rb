module Physics
  class ForceCalculator
    attr_reader :errors

    def initialize(force: nil, mass: nil, acceleration: nil)
      @force = force&.to_f
      @mass = mass&.to_f
      @acceleration = acceleration&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @force.nil?
        f = @mass * @acceleration
        { valid: true, force: f.round(4), mass: @mass.round(4), acceleration: @acceleration.round(4), solved_for: :force }
      elsif @mass.nil?
        m = @force / @acceleration
        { valid: true, force: @force.round(4), mass: m.round(4), acceleration: @acceleration.round(4), solved_for: :mass }
      else
        a = @force / @mass
        { valid: true, force: @force.round(4), mass: @mass.round(4), acceleration: a.round(4), solved_for: :acceleration }
      end
    end

    private

    def validate!
      provided = { force: @force, mass: @mass, acceleration: @acceleration }.compact
      if provided.size < 2
        @errors << "Provide at least two values"
        return
      end

      @errors << "Mass must be positive" if @mass && @mass <= 0
      if @acceleration && @acceleration.zero? && @mass.nil?
        @errors << "Acceleration cannot be zero when solving for mass"
      end
      if @mass && @mass.zero? && @acceleration.nil?
        @errors << "Mass cannot be zero when solving for acceleration"
      end
    end
  end
end
