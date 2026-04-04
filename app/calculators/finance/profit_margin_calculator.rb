module Finance
  class ProfitMarginCalculator
    attr_reader :errors

    def initialize(revenue:, cost:)
      @revenue = revenue.to_f
      @cost = cost.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      profit = @revenue - @cost
      margin = (profit / @revenue) * 100.0

      {
        valid: true,
        margin: margin.round(4),
        profit: profit.round(4),
        revenue: @revenue.round(4),
        cost: @cost.round(4)
      }
    end

    private

    def validate!
      @errors << "Revenue must be positive" unless @revenue > 0
      @errors << "Cost must be positive" unless @cost > 0
    end
  end
end
