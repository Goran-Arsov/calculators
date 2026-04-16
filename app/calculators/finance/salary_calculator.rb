# frozen_string_literal: true

module Finance
  class SalaryCalculator
    attr_reader :errors

    def initialize(amount:, type:, hours_per_week: 40)
      @amount = amount.to_f
      @type = type.to_s
      @hours_per_week = hours_per_week.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      hourly = calculate_hourly

      {
        valid: true,
        hourly: hourly.round(2),
        daily: (hourly * @hours_per_week / 5.0).round(2),
        weekly: (hourly * @hours_per_week).round(2),
        biweekly: (hourly * @hours_per_week * 2).round(2),
        monthly: (hourly * @hours_per_week * 52 / 12.0).round(2),
        annual: (hourly * @hours_per_week * 52).round(2)
      }
    end

    private

    def calculate_hourly
      case @type
      when "hourly"   then @amount
      when "daily"    then @amount / (@hours_per_week / 5.0)
      when "weekly"   then @amount / @hours_per_week
      when "biweekly" then @amount / (@hours_per_week * 2)
      when "monthly"  then @amount * 12 / (52 * @hours_per_week)
      when "annual"   then @amount / (52 * @hours_per_week)
      else @amount / (52 * @hours_per_week) # default to annual
      end
    end

    def validate!
      @errors << "Amount must be positive" unless @amount > 0
      @errors << "Hours per week must be positive" unless @hours_per_week > 0
      @errors << "Invalid salary type" unless %w[hourly daily weekly biweekly monthly annual].include?(@type)
    end
  end
end
