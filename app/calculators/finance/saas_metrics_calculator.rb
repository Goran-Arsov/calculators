module Finance
  class SaasMetricsCalculator
    attr_reader :errors

    def initialize(monthly_subscriptions:, churned_subscriptions:, total_customers:, new_customers:, cac:, avg_revenue_per_user: nil)
      @monthly_subscriptions = monthly_subscriptions.to_f
      @churned_subscriptions = churned_subscriptions.to_f
      @total_customers = total_customers.to_i
      @new_customers = new_customers.to_i
      @cac = cac.to_f
      @avg_revenue_per_user = avg_revenue_per_user&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      mrr = @monthly_subscriptions
      arr = mrr * 12

      churn_rate = @total_customers > 0 ? (@churned_subscriptions / @total_customers.to_f) * 100.0 : 0.0

      arpu = if @avg_revenue_per_user && @avg_revenue_per_user > 0
        @avg_revenue_per_user
      elsif @total_customers > 0
        mrr / @total_customers
      else
        0.0
      end

      # LTV = ARPU / monthly churn rate
      monthly_churn_decimal = churn_rate / 100.0
      ltv = monthly_churn_decimal > 0 ? arpu / monthly_churn_decimal : 0.0

      # LTV:CAC ratio
      ltv_cac_ratio = @cac > 0 ? ltv / @cac : 0.0

      # CAC payback months
      cac_payback_months = arpu > 0 ? (@cac / arpu).ceil : 0

      # Net revenue retention (simplified)
      expansion_mrr = 0 # Would need expansion data
      churned_mrr = @churned_subscriptions > 0 && @total_customers > 0 ? (mrr / @total_customers) * @churned_subscriptions : 0.0
      beginning_mrr = mrr + churned_mrr - (arpu * @new_customers)
      beginning_mrr = [beginning_mrr, 0.01].max
      nrr = ((mrr - churned_mrr + expansion_mrr) / beginning_mrr) * 100.0

      # SaaS Quick Ratio = (New MRR + Expansion MRR) / (Churned MRR + Contraction MRR)
      new_mrr = arpu * @new_customers
      quick_ratio = churned_mrr > 0 ? new_mrr / churned_mrr : 0.0

      {
        valid: true,
        mrr: mrr.round(2),
        arr: arr.round(2),
        churn_rate: churn_rate.round(2),
        arpu: arpu.round(2),
        ltv: ltv.round(2),
        cac: @cac.round(2),
        ltv_cac_ratio: ltv_cac_ratio.round(2),
        cac_payback_months: cac_payback_months,
        quick_ratio: quick_ratio.round(2),
        nrr: nrr.round(2),
        total_customers: @total_customers,
        new_customers: @new_customers,
        churned_customers: @churned_subscriptions.to_i
      }
    end

    private

    def validate!
      @errors << "Monthly subscriptions (MRR) must be positive" unless @monthly_subscriptions > 0
      @errors << "Churned subscriptions cannot be negative" if @churned_subscriptions < 0
      @errors << "Total customers must be positive" unless @total_customers > 0
      @errors << "New customers cannot be negative" if @new_customers < 0
      @errors << "Customer acquisition cost cannot be negative" if @cac < 0
      @errors << "Churned subscriptions cannot exceed total customers" if @churned_subscriptions > @total_customers
    end
  end
end
