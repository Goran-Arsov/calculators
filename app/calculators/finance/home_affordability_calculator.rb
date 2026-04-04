module Finance
  class HomeAffordabilityCalculator
    attr_reader :errors

    FRONT_END_DTI_LIMIT = 0.28
    BACK_END_DTI_LIMIT = 0.36

    def initialize(annual_income:, monthly_debts:, down_payment:, interest_rate:, loan_term:, property_tax_rate:, annual_insurance:)
      @annual_income = annual_income.to_f
      @monthly_debts = monthly_debts.to_f
      @down_payment = down_payment.to_f
      @interest_rate = interest_rate.to_f / 100.0
      @loan_term = loan_term.to_i
      @property_tax_rate = property_tax_rate.to_f / 100.0
      @annual_insurance = annual_insurance.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      gross_monthly_income = @annual_income / 12.0

      # Front-end DTI: max 28% of gross monthly income for housing
      max_housing_payment = gross_monthly_income * FRONT_END_DTI_LIMIT

      # Back-end DTI: max 36% of gross monthly income for all debts
      max_total_debt_payment = gross_monthly_income * BACK_END_DTI_LIMIT
      max_housing_from_backend = max_total_debt_payment - @monthly_debts

      # Available monthly payment for housing is the lesser constraint
      available_for_housing = [max_housing_payment, max_housing_from_backend].min
      available_for_housing = 0.0 if available_for_housing < 0

      # Deduct estimated monthly property tax and insurance
      # Property tax is estimated on the home price, so we need to solve iteratively
      # Simplified: estimate tax/insurance based on a first-pass home price
      monthly_insurance = @annual_insurance / 12.0

      # Available for P&I and property tax
      # monthly_tax = home_price * property_tax_rate / 12
      # available_for_housing = P&I + monthly_tax + monthly_insurance
      # available_for_PI = available_for_housing - monthly_insurance - home_price * property_tax_rate / 12
      # max_loan = PV(available_for_PI, rate, term)
      # home_price = max_loan + down_payment
      # We need to solve: available_for_housing - monthly_insurance - (max_loan + down_payment) * tax_rate/12 = PI
      # And max_loan = PI * PV_factor
      # So: available_for_housing - monthly_insurance - (PI * PV_factor + down_payment) * tax_rate/12 = PI
      # PI + PI * PV_factor * tax_rate/12 = available_for_housing - monthly_insurance - down_payment * tax_rate/12
      # PI * (1 + PV_factor * tax_rate/12) = available_for_housing - monthly_insurance - down_payment * tax_rate/12
      # PI = (available_for_housing - monthly_insurance - down_payment * tax_rate/12) / (1 + PV_factor * tax_rate/12)

      monthly_rate = @interest_rate / 12.0
      num_payments = @loan_term * 12

      if monthly_rate.zero?
        pv_factor = num_payments.to_f
      else
        pv_factor = (1.0 - (1.0 + monthly_rate)**(-num_payments)) / monthly_rate
      end

      monthly_tax_rate = @property_tax_rate / 12.0
      numerator = available_for_housing - monthly_insurance - @down_payment * monthly_tax_rate
      denominator = 1.0 + pv_factor * monthly_tax_rate

      if denominator <= 0 || numerator <= 0
        available_for_pi = 0.0
      else
        available_for_pi = numerator / denominator
      end

      max_loan = available_for_pi * pv_factor
      max_loan = 0.0 if max_loan < 0

      max_home_price = max_loan + @down_payment

      # Calculate monthly payment breakdown
      monthly_tax = max_home_price * monthly_tax_rate
      monthly_pi = available_for_pi
      total_monthly_payment = monthly_pi + monthly_tax + monthly_insurance

      # Calculate actual DTI ratios
      front_end_dti = gross_monthly_income > 0 ? (total_monthly_payment / gross_monthly_income * 100).round(1) : 0.0
      back_end_dti = gross_monthly_income > 0 ? ((total_monthly_payment + @monthly_debts) / gross_monthly_income * 100).round(1) : 0.0

      {
        valid: true,
        max_home_price: max_home_price.round(2),
        max_loan_amount: max_loan.round(2),
        monthly_pi: monthly_pi.round(2),
        monthly_tax: monthly_tax.round(2),
        monthly_insurance: monthly_insurance.round(2),
        total_monthly_payment: total_monthly_payment.round(2),
        front_end_dti: front_end_dti,
        back_end_dti: back_end_dti,
        down_payment: @down_payment.round(2)
      }
    end

    private

    def validate!
      @errors << "Annual income must be positive" unless @annual_income > 0
      @errors << "Monthly debts cannot be negative" if @monthly_debts < 0
      @errors << "Down payment cannot be negative" if @down_payment < 0
      @errors << "Interest rate cannot be negative" if @interest_rate < 0
      @errors << "Loan term must be positive" unless @loan_term > 0
      @errors << "Property tax rate cannot be negative" if @property_tax_rate < 0
      @errors << "Annual insurance cannot be negative" if @annual_insurance < 0
    end
  end
end
