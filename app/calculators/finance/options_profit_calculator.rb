module Finance
  class OptionsProfitCalculator
    attr_reader :errors

    SHARES_PER_CONTRACT = 100

    def initialize(option_type:, strike_price:, premium:, underlying_price:, contracts:)
      @option_type = option_type.to_s.downcase
      @strike_price = strike_price.to_f
      @premium = premium.to_f
      @underlying_price = underlying_price.to_f
      @contracts = contracts.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_shares = @contracts * SHARES_PER_CONTRACT
      total_premium_paid = @premium * total_shares

      if @option_type == "call"
        intrinsic_value = [ @underlying_price - @strike_price, 0 ].max
        break_even = @strike_price + @premium
      else
        intrinsic_value = [ @strike_price - @underlying_price, 0 ].max
        break_even = @strike_price - @premium
      end

      profit_per_share = intrinsic_value - @premium
      total_profit = profit_per_share * total_shares
      roi = total_premium_paid > 0 ? (total_profit / total_premium_paid * 100.0) : 0.0
      max_loss = total_premium_paid

      if @option_type == "call"
        max_profit = Float::INFINITY
      else
        max_profit = ((@strike_price - @premium) * total_shares).round(2)
        max_profit = [ max_profit, 0 ].max
      end

      {
        valid: true,
        option_type: @option_type,
        intrinsic_value: intrinsic_value.round(2),
        profit_per_share: profit_per_share.round(2),
        total_profit: total_profit.round(2),
        total_premium_paid: total_premium_paid.round(2),
        break_even: break_even.round(2),
        roi: roi.round(2),
        max_loss: max_loss.round(2),
        max_profit: max_profit == Float::INFINITY ? "Unlimited" : max_profit,
        in_the_money: intrinsic_value > 0,
        total_shares: total_shares
      }
    end

    private

    def validate!
      @errors << "Option type must be 'call' or 'put'" unless %w[call put].include?(@option_type)
      @errors << "Strike price must be positive" unless @strike_price > 0
      @errors << "Premium must be positive" unless @premium > 0
      @errors << "Underlying price must be positive" unless @underlying_price > 0
      @errors << "Number of contracts must be positive" unless @contracts > 0
    end
  end
end
