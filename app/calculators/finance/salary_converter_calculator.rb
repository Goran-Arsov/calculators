# frozen_string_literal: true

module Finance
  class SalaryConverterCalculator
    attr_reader :errors

    VALID_PERIODS = %w[hourly daily weekly biweekly monthly annual].freeze

    def initialize(amount:, period:, hours_per_week: 40, weeks_per_year: 52)
      @amount = amount.to_f
      @period = period.to_s.downcase
      @hours_per_week = hours_per_week.to_f
      @weeks_per_year = weeks_per_year.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      hourly = calculate_hourly
      days_per_week = 5.0

      {
        valid: true,
        hourly: hourly.round(2),
        daily: (hourly * @hours_per_week / days_per_week).round(2),
        weekly: (hourly * @hours_per_week).round(2),
        biweekly: (hourly * @hours_per_week * 2).round(2),
        monthly: (hourly * @hours_per_week * @weeks_per_year / 12.0).round(2),
        annual: (hourly * @hours_per_week * @weeks_per_year).round(2)
      }
    end

    private

    def calculate_hourly
      case @period
      when "hourly"   then @amount
      when "daily"    then @amount / (@hours_per_week / 5.0)
      when "weekly"   then @amount / @hours_per_week
      when "biweekly" then @amount / (@hours_per_week * 2)
      when "monthly"  then @amount * 12 / (@weeks_per_year * @hours_per_week)
      when "annual"   then @amount / (@weeks_per_year * @hours_per_week)
      end
    end

    def validate!
      @errors << "Amount must be positive" unless @amount.positive?
      @errors << "Invalid period" unless VALID_PERIODS.include?(@period)
      @errors << "Hours per week must be positive" unless @hours_per_week.positive?
      @errors << "Weeks per year must be positive" unless @weeks_per_year.positive?
    end
  end
end
