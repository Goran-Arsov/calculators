module Finance
  class EmergencyFundCalculator
    attr_reader :errors

    RISK_MONTHS = {
      "stable"    => 3,
      "moderate"  => 6,
      "high_risk" => 9
    }.freeze

    VALID_RISK_LEVELS = RISK_MONTHS.keys.freeze

    def initialize(monthly_expenses:, risk_level: "moderate", current_savings: 0, monthly_contribution: 0)
      @monthly_expenses = monthly_expenses.to_f
      @risk_level = risk_level.to_s.downcase.strip
      @current_savings = current_savings.to_f
      @monthly_contribution = monthly_contribution.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      months_recommended = RISK_MONTHS[@risk_level]
      target_fund = @monthly_expenses * months_recommended
      savings_gap = [ target_fund - @current_savings, 0 ].max
      percent_funded = target_fund > 0 ? (@current_savings / target_fund * 100) : 0.0
      percent_funded = [ percent_funded, 100.0 ].min if @current_savings >= target_fund

      months_to_goal = if savings_gap <= 0
                         0.0
      elsif @monthly_contribution > 0
                         (savings_gap / @monthly_contribution).ceil.to_f
      else
                         Float::INFINITY
      end

      {
        valid: true,
        monthly_expenses: @monthly_expenses.round(2),
        risk_level: @risk_level,
        months_recommended: months_recommended,
        target_fund: target_fund.round(2),
        current_savings: @current_savings.round(2),
        savings_gap: savings_gap.round(2),
        months_to_goal: months_to_goal == Float::INFINITY ? nil : months_to_goal.round(0).to_i,
        percent_funded: percent_funded.round(1)
      }
    end

    private

    def validate!
      @errors << "Monthly expenses must be positive" unless @monthly_expenses > 0
      @errors << "Invalid risk level" unless VALID_RISK_LEVELS.include?(@risk_level)
      @errors << "Current savings cannot be negative" if @current_savings < 0
      @errors << "Monthly contribution cannot be negative" if @monthly_contribution < 0
    end
  end
end
