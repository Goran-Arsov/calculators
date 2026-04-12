module Finance
  class StartupRunwayCalculator
    attr_reader :errors

    def initialize(cash_balance:, monthly_burn:, monthly_revenue: 0, revenue_growth_rate: 0)
      @cash_balance = cash_balance.to_f
      @monthly_burn = monthly_burn.to_f
      @monthly_revenue = monthly_revenue.to_f
      @revenue_growth_rate = revenue_growth_rate.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      net_burn = @monthly_burn - @monthly_revenue
      gross_runway_months = net_burn > 0 ? (@cash_balance / net_burn).floor : nil

      # Calculate runway with revenue growth
      if @revenue_growth_rate > 0 && @monthly_revenue > 0
        adjusted_runway = calculate_runway_with_growth
      else
        adjusted_runway = gross_runway_months
      end

      # Daily burn rate
      daily_burn = net_burn / 30.0

      # Date when cash runs out
      runway_months = adjusted_runway || gross_runway_months

      # Zero cash date
      zero_cash_date = if runway_months && runway_months > 0
        Date.today >> runway_months
      end

      # Monthly projection (up to 24 months or until cash runs out)
      projection = build_projection(runway_months)

      {
        valid: true,
        cash_balance: @cash_balance.round(2),
        monthly_burn: @monthly_burn.round(2),
        monthly_revenue: @monthly_revenue.round(2),
        net_burn: net_burn.round(2),
        daily_burn: daily_burn.round(2),
        gross_runway_months: gross_runway_months,
        adjusted_runway_months: adjusted_runway,
        zero_cash_date: zero_cash_date&.to_s,
        is_profitable: net_burn <= 0,
        projection: projection
      }
    end

    private

    def validate!
      @errors << "Cash balance must be positive" unless @cash_balance > 0
      @errors << "Monthly burn rate must be positive" unless @monthly_burn > 0
      @errors << "Monthly revenue cannot be negative" if @monthly_revenue < 0
      @errors << "Revenue growth rate cannot be negative" if @revenue_growth_rate < 0
    end

    def calculate_runway_with_growth
      cash = @cash_balance
      revenue = @monthly_revenue
      month = 0
      max_months = 120 # 10-year cap

      while cash > 0 && month < max_months
        month += 1
        revenue *= (1 + @revenue_growth_rate)
        net = @monthly_burn - revenue
        cash -= net

        return nil if net <= 0 && month > 1 # Revenue exceeds burn - infinite runway
      end

      month
    end

    def build_projection(runway_months)
      months_to_show = [ runway_months || 24, 24 ].min
      months_to_show = [ months_to_show, 1 ].max

      cash = @cash_balance
      revenue = @monthly_revenue
      projection = []

      months_to_show.times do |i|
        revenue *= (1 + @revenue_growth_rate) if i > 0
        net = @monthly_burn - revenue
        cash -= net

        projection << {
          month: i + 1,
          revenue: revenue.round(2),
          burn: @monthly_burn.round(2),
          net_burn: net.round(2),
          cash_remaining: cash.round(2)
        }

        break if cash <= 0
      end

      projection
    end
  end
end
