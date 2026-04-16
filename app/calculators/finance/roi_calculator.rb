# frozen_string_literal: true

module Finance
  class RoiCalculator
    attr_reader :errors

    def initialize(gain: nil, cost: nil, roi: nil)
      @gain = gain&.to_f
      @cost = cost&.to_f
      @roi = roi&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @gain && @cost
        roi = ((@gain - @cost) / @cost) * 100.0
        {
          valid: true,
          roi: roi.round(4),
          gain: @gain.round(4),
          cost: @cost.round(4),
          solved_for: :roi
        }
      elsif @roi && @cost
        gain = @cost * (@roi / 100.0) + @cost
        {
          valid: true,
          roi: @roi.round(4),
          gain: gain.round(4),
          cost: @cost.round(4),
          solved_for: :gain
        }
      else
        gain_value = @gain
        cost = gain_value / (1 + @roi / 100.0)
        {
          valid: true,
          roi: @roi.round(4),
          gain: gain_value.round(4),
          cost: cost.round(4),
          solved_for: :cost
        }
      end
    end

    private

    def validate!
      provided = { gain: @gain, cost: @cost, roi: @roi }.compact
      @errors << "Exactly 2 of gain, cost, and roi must be provided" unless provided.size == 2

      @errors << "Cost must not be zero" if @cost && @cost.zero?
      @errors << "ROI must not be -100% (cost would be undefined)" if @roi && @roi == -100.0
    end
  end
end
