module Finance
  class BreakEvenCalculator
    attr_reader :errors

    def initialize(fixed_costs:, price_per_unit:, variable_cost_per_unit:)
      @fixed_costs = fixed_costs.to_f
      @price_per_unit = price_per_unit.to_f
      @variable_cost_per_unit = variable_cost_per_unit.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      contribution_margin = @price_per_unit - @variable_cost_per_unit
      break_even_units = @fixed_costs / contribution_margin
      break_even_revenue = break_even_units * @price_per_unit

      {
        valid: true,
        break_even_units: break_even_units.round(4),
        break_even_revenue: break_even_revenue.round(4),
        contribution_margin: contribution_margin.round(4),
        fixed_costs: @fixed_costs.round(4),
        price_per_unit: @price_per_unit.round(4),
        variable_cost_per_unit: @variable_cost_per_unit.round(4)
      }
    end

    private

    def validate!
      @errors << "Fixed costs must be positive" unless @fixed_costs > 0
      @errors << "Price per unit must be positive" unless @price_per_unit > 0
      @errors << "Variable cost per unit cannot be negative" if @variable_cost_per_unit < 0
      @errors << "Price per unit must be greater than variable cost per unit" unless @price_per_unit > @variable_cost_per_unit
    end
  end
end
