module Finance
  class CurrencyConverterCalculator
    attr_reader :errors

    RATES_LAST_UPDATED = "2026-04-05"

    # Static exchange rates vs USD (how many units of foreign currency per 1 USD)
    RATES = {
      "USD" => 1.0,
      "EUR" => 0.92,
      "GBP" => 0.79,
      "JPY" => 149.5,
      "CAD" => 1.36,
      "AUD" => 1.53,
      "CHF" => 0.88,
      "CNY" => 7.24,
      "INR" => 83.1,
      "MXN" => 17.15,
      "BRL" => 4.97,
      "KRW" => 1330.0,
      "SEK" => 10.42,
      "NOK" => 10.55,
      "NZD" => 1.64,
      "SGD" => 1.34,
      "HKD" => 7.82,
      "TRY" => 32.4,
      "ZAR" => 18.6,
      "AED" => 3.67
    }.freeze

    SUPPORTED_CURRENCIES = RATES.keys.freeze

    def initialize(amount:, from_currency:, to_currency:)
      @amount = amount.to_f
      @from_currency = from_currency.to_s.upcase.strip
      @to_currency = to_currency.to_s.upcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      from_rate = RATES[@from_currency]
      to_rate = RATES[@to_currency]

      # Convert from source to USD, then from USD to target
      amount_in_usd = @amount / from_rate
      converted_amount = amount_in_usd * to_rate

      # Exchange rate: 1 unit of from_currency = ? units of to_currency
      exchange_rate = to_rate / from_rate
      inverse_rate = from_rate / to_rate

      {
        valid: true,
        amount: @amount,
        from_currency: @from_currency,
        to_currency: @to_currency,
        converted_amount: converted_amount.round(4),
        exchange_rate: exchange_rate.round(6),
        inverse_rate: inverse_rate.round(6),
        rates_last_updated: RATES_LAST_UPDATED
      }
    end

    private

    def validate!
      @errors << "Amount must be positive" unless @amount > 0
      @errors << "Unsupported source currency: #{@from_currency}" unless RATES.key?(@from_currency)
      @errors << "Unsupported target currency: #{@to_currency}" unless RATES.key?(@to_currency)
    end
  end
end
