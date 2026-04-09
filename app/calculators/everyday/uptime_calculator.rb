# frozen_string_literal: true

module Everyday
  class UptimeCalculator
    attr_reader :errors

    SLA_LEVELS = [
      { label: "99%",     pct: 99.0 },
      { label: "99.9%",   pct: 99.9 },
      { label: "99.95%",  pct: 99.95 },
      { label: "99.99%",  pct: 99.99 },
      { label: "99.999%", pct: 99.999 }
    ].freeze

    HOURS_PER_MONTH = 720     # 30 days
    HOURS_PER_YEAR = 8760     # 365 days

    def initialize(total_period_hours: 720, downtime_minutes:)
      @total_period_hours = total_period_hours.to_f
      @downtime_minutes = downtime_minutes.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_minutes = @total_period_hours * 60.0
      uptime_minutes = total_minutes - @downtime_minutes
      uptime_percent = (uptime_minutes / total_minutes) * 100.0

      nines = classify_nines(uptime_percent)

      sla_reference = SLA_LEVELS.map do |level|
        downtime_fraction = (100.0 - level[:pct]) / 100.0
        monthly_downtime_min = HOURS_PER_MONTH * 60.0 * downtime_fraction
        yearly_downtime_min = HOURS_PER_YEAR * 60.0 * downtime_fraction

        {
          label: level[:label],
          downtime_per_month: format_duration(monthly_downtime_min),
          downtime_per_month_minutes: monthly_downtime_min.round(4),
          downtime_per_year: format_duration(yearly_downtime_min),
          downtime_per_year_minutes: yearly_downtime_min.round(4)
        }
      end

      {
        valid: true,
        uptime_percent: uptime_percent.round(6),
        downtime_minutes: @downtime_minutes,
        total_period_hours: @total_period_hours,
        uptime_minutes: uptime_minutes.round(2),
        nines_classification: nines,
        sla_reference: sla_reference
      }
    end

    private

    def validate!
      @errors << "Total period hours must be greater than zero" unless @total_period_hours.positive?
      @errors << "Downtime minutes cannot be negative" if @downtime_minutes.negative?
      if @total_period_hours.positive? && @downtime_minutes > @total_period_hours * 60
        @errors << "Downtime cannot exceed total period (#{(@total_period_hours * 60).round(0)} minutes)"
      end
    end

    def classify_nines(pct)
      if pct >= 99.999
        "Five 9s (99.999%)"
      elsif pct >= 99.99
        "Four 9s (99.99%)"
      elsif pct >= 99.9
        "Three 9s (99.9%)"
      elsif pct >= 99.0
        "Two 9s (99%)"
      else
        "Less than two 9s"
      end
    end

    def format_duration(minutes)
      if minutes < 1
        "#{(minutes * 60).round(1)}s"
      elsif minutes < 60
        "#{minutes.round(2)} min"
      elsif minutes < 1440
        hours = (minutes / 60.0).round(2)
        "#{hours} hours"
      else
        days = (minutes / 1440.0).round(2)
        "#{days} days"
      end
    end
  end
end
