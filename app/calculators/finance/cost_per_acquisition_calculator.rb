module Finance
  class CostPerAcquisitionCalculator
    attr_reader :errors

    def initialize(total_cost:, customers:, customer_ltv: nil)
      @total_cost = total_cost.to_f
      @customers = customers.to_i
      @customer_ltv = customer_ltv.nil? || customer_ltv.to_s.strip.empty? ? nil : customer_ltv.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      cpa = @total_cost / @customers

      result = {
        valid: true,
        cost_per_acquisition: cpa.round(4),
        total_cost: @total_cost.round(2),
        customers: @customers
      }

      if @customer_ltv && @customer_ltv > 0
        ltv_cpa_ratio = @customer_ltv / cpa
        roi = ((@customer_ltv - cpa) / cpa) * 100.0
        result[:customer_ltv] = @customer_ltv.round(2)
        result[:ltv_cpa_ratio] = ltv_cpa_ratio.round(4)
        result[:roi] = roi.round(4)
      end

      result
    end

    private

    def validate!
      @errors << "Total cost must be positive" unless @total_cost > 0
      @errors << "Customers must be positive" unless @customers > 0
      @errors << "Customer LTV must be positive" if @customer_ltv && @customer_ltv <= 0
    end
  end
end
