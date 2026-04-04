module Physics
  class OhmsLawCalculator
    attr_reader :errors

    def initialize(voltage: nil, current: nil, resistance: nil)
      @voltage = voltage&.to_f
      @current = current&.to_f
      @resistance = resistance&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @voltage.nil?
        v = @current * @resistance
        { valid: true, voltage: v.round(4), current: @current.round(4), resistance: @resistance.round(4), power: (v * @current).round(4), solved_for: :voltage }
      elsif @current.nil?
        i = @voltage / @resistance
        { valid: true, voltage: @voltage.round(4), current: i.round(4), resistance: @resistance.round(4), power: (@voltage * i).round(4), solved_for: :current }
      else
        r = @voltage / @current
        { valid: true, voltage: @voltage.round(4), current: @current.round(4), resistance: r.round(4), power: (@voltage * @current).round(4), solved_for: :resistance }
      end
    end

    private

    def validate!
      provided = { voltage: @voltage, current: @current, resistance: @resistance }.compact
      if provided.size < 2
        @errors << "Provide at least two values"
        return
      end

      @errors << "Resistance must be positive" if @resistance && @resistance <= 0
      @errors << "Current cannot be zero when solving for resistance" if @current && @current.zero? && @resistance.nil?
      @errors << "Resistance cannot be zero when solving for current" if @resistance && @resistance.zero? && @current.nil?
    end
  end
end
