module Finance
  class CompoundInterestCalculator
    attr_reader :errors

    def initialize(principal:, annual_rate:, years:, compounds_per_year: 12)
      @principal = principal.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @years = years.to_i
      @compounds_per_year = compounds_per_year.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      n = @compounds_per_year
      future_value = @principal * (1 + @annual_rate / n)**(n * @years)
      total_interest = future_value - @principal

      {
        valid: true,
        future_value: future_value.round(2),
        total_interest: total_interest.round(2),
        principal: @principal.round(2)
      }
    end

    private

    def validate!
      @errors << "Principal must be positive" unless @principal > 0
      @errors << "Time period must be positive" unless @years > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
      @errors << "Compounding frequency must be positive" unless @compounds_per_year > 0
    end
  end
end
