module Finance
  class AutoLoanCalculator
    attr_reader :errors

    def initialize(vehicle_price:, down_payment:, trade_in_value:, sales_tax_rate:, annual_rate:, term_months:)
      @vehicle_price = vehicle_price.to_f
      @down_payment = down_payment.to_f
      @trade_in_value = trade_in_value.to_f
      @sales_tax_rate = sales_tax_rate.to_f / 100.0
      @annual_rate = annual_rate.to_f / 100.0
      @term_months = term_months.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      taxable_amount = @vehicle_price - @trade_in_value
      sales_tax = [ taxable_amount * @sales_tax_rate, 0 ].max
      loan_amount = @vehicle_price + sales_tax - @down_payment - @trade_in_value

      monthly_rate = @annual_rate / 12.0

      if monthly_rate.zero?
        monthly_payment = loan_amount / @term_months
      else
        monthly_payment = loan_amount * (monthly_rate * (1 + monthly_rate)**@term_months) /
                          ((1 + monthly_rate)**@term_months - 1)
      end

      total_paid = monthly_payment * @term_months
      total_interest = total_paid - loan_amount
      total_cost = total_paid + @down_payment + @trade_in_value

      {
        valid: true,
        vehicle_price: @vehicle_price.round(2),
        down_payment: @down_payment.round(2),
        trade_in_value: @trade_in_value.round(2),
        sales_tax: sales_tax.round(2),
        loan_amount: loan_amount.round(2),
        monthly_payment: monthly_payment.round(2),
        total_interest: total_interest.round(2),
        total_paid: total_paid.round(2),
        total_cost: total_cost.round(2),
        term_months: @term_months
      }
    end

    private

    def validate!
      @errors << "Vehicle price must be positive" unless @vehicle_price > 0
      @errors << "Down payment cannot be negative" if @down_payment < 0
      @errors << "Trade-in value cannot be negative" if @trade_in_value < 0
      @errors << "Sales tax rate cannot be negative" if @sales_tax_rate < 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
      @errors << "Loan term must be positive" unless @term_months > 0
      if @down_payment + @trade_in_value > @vehicle_price
        @errors << "Down payment and trade-in cannot exceed vehicle price"
      end
    end
  end
end
