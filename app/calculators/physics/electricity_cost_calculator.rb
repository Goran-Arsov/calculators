module Physics
  class ElectricityCostCalculator
    attr_reader :errors

    def initialize(power: nil, hours: nil, rate: nil, cost: nil)
      @power = power&.to_f
      @hours = hours&.to_f
      @rate = rate&.to_f
      @cost = cost&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @cost.nil?
        kwh = @power * @hours
        cost = kwh * @rate
        { valid: true, cost: cost.round(4), power: @power, hours: @hours, rate: @rate, kwh: kwh.round(4), solved_for: :cost }
      elsif @power.nil?
        power = @cost / (@hours * @rate)
        kwh = power * @hours
        { valid: true, cost: @cost, power: power.round(4), hours: @hours, rate: @rate, kwh: kwh.round(4), solved_for: :power }
      elsif @hours.nil?
        hours = @cost / (@power * @rate)
        kwh = @power * hours
        { valid: true, cost: @cost, power: @power, hours: hours.round(4), rate: @rate, kwh: kwh.round(4), solved_for: :hours }
      else
        rate = @cost / (@power * @hours)
        kwh = @power * @hours
        { valid: true, cost: @cost, power: @power, hours: @hours, rate: rate.round(6), kwh: kwh.round(4), solved_for: :rate }
      end
    end

    private

    def validate!
      provided = { power: @power, hours: @hours, rate: @rate, cost: @cost }.compact
      if provided.size < 3
        @errors << "Provide at least three values"
        return
      end

      @errors << "Power must be positive" if @power && @power <= 0
      @errors << "Hours must be positive" if @hours && @hours <= 0
      @errors << "Rate must be positive" if @rate && @rate <= 0
      @errors << "Cost must be non-negative" if @cost && @cost < 0
    end
  end
end
