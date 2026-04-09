module Finance
  class LeaseVsBuyCalculator
    attr_reader :errors

    def initialize(vehicle_price:, down_payment_buy:, loan_rate_percent:, loan_term_months:,
                   lease_monthly_payment:, lease_term_months:, lease_down_payment:, estimated_resale_value:)
      @vehicle_price = vehicle_price.to_f
      @down_payment_buy = down_payment_buy.to_f
      @loan_rate_percent = loan_rate_percent.to_f
      @loan_term_months = loan_term_months.to_i
      @lease_monthly_payment = lease_monthly_payment.to_f
      @lease_term_months = lease_term_months.to_i
      @lease_down_payment = lease_down_payment.to_f
      @estimated_resale_value = estimated_resale_value.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Buy scenario: standard amortization
      loan_amount = @vehicle_price - @down_payment_buy
      monthly_rate = @loan_rate_percent / 100.0 / 12.0

      buy_monthly_payment = if monthly_rate.zero?
                              @loan_term_months > 0 ? loan_amount / @loan_term_months : 0.0
      else
                              loan_amount * (monthly_rate * (1 + monthly_rate)**@loan_term_months) /
                                ((1 + monthly_rate)**@loan_term_months - 1)
      end

      total_buy_cost = @down_payment_buy + (buy_monthly_payment * @loan_term_months)
      total_buy_net = total_buy_cost - @estimated_resale_value

      # Lease scenario
      total_lease_cost = @lease_down_payment + (@lease_monthly_payment * @lease_term_months)

      # Compare
      savings_amount = (total_lease_cost - total_buy_net).abs
      recommendation = total_buy_net <= total_lease_cost ? "buy" : "lease"

      {
        valid: true,
        vehicle_price: @vehicle_price.round(2),
        buy_monthly_payment: buy_monthly_payment.round(2),
        total_buy_cost: total_buy_cost.round(2),
        total_buy_net: total_buy_net.round(2),
        total_lease_cost: total_lease_cost.round(2),
        savings_amount: savings_amount.round(2),
        recommendation: recommendation
      }
    end

    private

    def validate!
      @errors << "Vehicle price must be positive" unless @vehicle_price > 0
      @errors << "Down payment cannot be negative" if @down_payment_buy < 0
      @errors << "Down payment cannot exceed vehicle price" if @down_payment_buy > @vehicle_price && @vehicle_price > 0
      @errors << "Loan rate cannot be negative" if @loan_rate_percent < 0
      @errors << "Loan term must be positive" unless @loan_term_months > 0
      @errors << "Lease monthly payment cannot be negative" if @lease_monthly_payment < 0
      @errors << "Lease term must be positive" unless @lease_term_months > 0
      @errors << "Lease down payment cannot be negative" if @lease_down_payment < 0
      @errors << "Estimated resale value cannot be negative" if @estimated_resale_value < 0
    end
  end
end
