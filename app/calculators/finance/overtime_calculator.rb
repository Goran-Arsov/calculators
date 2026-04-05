# frozen_string_literal: true

module Finance
  class OvertimeCalculator
    attr_reader :errors

    def initialize(hourly_rate:, regular_hours:, overtime_hours:, ot_multiplier: 1.5)
      @hourly_rate = hourly_rate.to_f
      @regular_hours = regular_hours.to_f
      @overtime_hours = overtime_hours.to_f
      @ot_multiplier = ot_multiplier.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      regular_pay = @hourly_rate * @regular_hours
      overtime_rate = @hourly_rate * @ot_multiplier
      overtime_pay = overtime_rate * @overtime_hours
      total_pay = regular_pay + overtime_pay
      total_hours = @regular_hours + @overtime_hours
      effective_hourly_rate = total_hours.positive? ? total_pay / total_hours : 0.0

      {
        valid: true,
        hourly_rate: @hourly_rate.round(2),
        regular_hours: @regular_hours.round(1),
        overtime_hours: @overtime_hours.round(1),
        total_hours: total_hours.round(1),
        ot_multiplier: @ot_multiplier,
        overtime_rate: overtime_rate.round(2),
        regular_pay: regular_pay.round(2),
        overtime_pay: overtime_pay.round(2),
        total_pay: total_pay.round(2),
        effective_hourly_rate: effective_hourly_rate.round(2)
      }
    end

    private

    def validate!
      @errors << "Hourly rate must be positive" unless @hourly_rate.positive?
      @errors << "Regular hours must be zero or positive" if @regular_hours.negative?
      @errors << "Overtime hours must be zero or positive" if @overtime_hours.negative?
      @errors << "OT multiplier must be at least 1.0" unless @ot_multiplier >= 1.0
    end
  end
end
