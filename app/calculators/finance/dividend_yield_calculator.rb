module Finance
  class DividendYieldCalculator
    attr_reader :errors

    def initialize(share_price: nil, annual_dividend: nil, yield_pct: nil)
      @share_price = share_price&.to_f
      @annual_dividend = annual_dividend&.to_f
      @yield_pct = yield_pct&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @share_price && @annual_dividend
        yield_pct = (@annual_dividend / @share_price) * 100.0
        {
          valid: true,
          share_price: @share_price.round(4),
          annual_dividend: @annual_dividend.round(4),
          yield_pct: yield_pct.round(4),
          solved_for: :yield_pct
        }
      elsif @annual_dividend && @yield_pct
        share_price = (@annual_dividend / @yield_pct) * 100.0
        {
          valid: true,
          share_price: share_price.round(4),
          annual_dividend: @annual_dividend.round(4),
          yield_pct: @yield_pct.round(4),
          solved_for: :share_price
        }
      else
        annual_dividend = @share_price * (@yield_pct / 100.0)
        {
          valid: true,
          share_price: @share_price.round(4),
          annual_dividend: annual_dividend.round(4),
          yield_pct: @yield_pct.round(4),
          solved_for: :annual_dividend
        }
      end
    end

    private

    def validate!
      provided = { share_price: @share_price, annual_dividend: @annual_dividend, yield_pct: @yield_pct }.compact
      @errors << "Exactly 2 of share_price, annual_dividend, and yield_pct must be provided" unless provided.size == 2

      @errors << "Share price must be positive" if @share_price && @share_price <= 0
      @errors << "Annual dividend must be positive" if @annual_dividend && @annual_dividend <= 0
      @errors << "Yield percentage must be positive" if @yield_pct && @yield_pct <= 0
    end
  end
end
