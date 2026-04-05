module Finance
  class RevenuePerEmployeeCalculator
    attr_reader :errors

    def initialize(annual_revenue:, employees:, net_income: nil)
      @annual_revenue = annual_revenue.to_f
      @employees = employees.to_i
      @net_income = net_income.nil? || net_income.to_s.strip.empty? ? nil : net_income.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      revenue_per_employee = @annual_revenue / @employees
      revenue_per_employee_monthly = revenue_per_employee / 12.0
      revenue_per_employee_quarterly = revenue_per_employee / 4.0

      result = {
        valid: true,
        revenue_per_employee: revenue_per_employee.round(4),
        revenue_per_employee_monthly: revenue_per_employee_monthly.round(4),
        revenue_per_employee_quarterly: revenue_per_employee_quarterly.round(4),
        annual_revenue: @annual_revenue.round(2),
        employees: @employees
      }

      if @net_income
        profit_per_employee = @net_income / @employees
        result[:net_income] = @net_income.round(2)
        result[:profit_per_employee] = profit_per_employee.round(4)
      end

      result
    end

    private

    def validate!
      @errors << "Annual revenue must be positive" unless @annual_revenue > 0
      @errors << "Number of employees must be positive" unless @employees > 0
    end
  end
end
