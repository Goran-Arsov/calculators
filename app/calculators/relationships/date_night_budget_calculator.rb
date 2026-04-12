# frozen_string_literal: true

module Relationships
  class DateNightBudgetCalculator
    attr_reader :errors

    def initialize(dinner:, activity:, transport:, extras:, dates_per_month: 4)
      @dinner = dinner.to_f
      @activity = activity.to_f
      @transport = transport.to_f
      @extras = extras.to_f
      @dates_per_month = dates_per_month.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      per_date = @dinner + @activity + @transport + @extras
      monthly = per_date * @dates_per_month
      annual = monthly * 12

      {
        valid: true,
        per_date: per_date.round(2),
        monthly: monthly.round(2),
        annual: annual.round(2),
        dates_per_month: @dates_per_month,
        breakdown: {
          dinner: @dinner.round(2),
          activity: @activity.round(2),
          transport: @transport.round(2),
          extras: @extras.round(2)
        }
      }
    end

    private

    def validate!
      @errors << "All costs must be zero or positive" if [ @dinner, @activity, @transport, @extras ].any?(&:negative?)
      @errors << "Dates per month must be at least 1" if @dates_per_month < 1
    end
  end
end
