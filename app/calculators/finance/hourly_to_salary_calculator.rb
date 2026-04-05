# frozen_string_literal: true

module Finance
  class HourlyToSalaryCalculator
    attr_reader :errors

    def initialize(amount:, direction: "hourly_to_salary", hours_per_week: 40, weeks_per_year: 52)
      @amount = amount.to_f
      @direction = direction.to_s.downcase
      @hours_per_week = hours_per_week.to_f
      @weeks_per_year = weeks_per_year.to_f
      @errors = []
    end

    VALID_DIRECTIONS = %w[hourly_to_salary salary_to_hourly].freeze

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @direction == "hourly_to_salary"
        hourly = @amount
        annual = hourly * @hours_per_week * @weeks_per_year
      else
        annual = @amount
        hourly = annual / (@hours_per_week * @weeks_per_year)
      end

      monthly = annual / 12.0
      biweekly = hourly * @hours_per_week * 2
      weekly = hourly * @hours_per_week
      daily = hourly * (@hours_per_week / 5.0)

      {
        valid: true,
        direction: @direction,
        hourly: hourly.round(2),
        daily: daily.round(2),
        weekly: weekly.round(2),
        biweekly: biweekly.round(2),
        monthly: monthly.round(2),
        annual: annual.round(2),
        hours_per_week: @hours_per_week,
        weeks_per_year: @weeks_per_year
      }
    end

    private

    def validate!
      @errors << "Amount must be positive" unless @amount.positive?
      @errors << "Invalid direction" unless VALID_DIRECTIONS.include?(@direction)
      @errors << "Hours per week must be positive" unless @hours_per_week.positive?
      @errors << "Weeks per year must be positive" unless @weeks_per_year.positive?
    end
  end
end
