# frozen_string_literal: true

module Everyday
  class WorkBreakCalculator
    attr_reader :errors

    def initialize(shift_hours:, break_threshold: 6, break_duration: 30, meal_threshold: 10, meal_duration: 30)
      @shift_hours = shift_hours.to_f
      @break_threshold = break_threshold.to_f
      @break_duration = break_duration.to_f
      @meal_threshold = meal_threshold.to_f
      @meal_duration = meal_duration.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      breaks = build_break_schedule
      total_break_minutes = breaks.sum { |b| b[:duration] }
      net_work_minutes = (@shift_hours * 60) - total_break_minutes
      net_work_hours = net_work_minutes / 60.0

      {
        valid: true,
        shift_hours: @shift_hours.round(1),
        shift_minutes: (@shift_hours * 60).round(0),
        total_breaks: breaks.size,
        total_break_minutes: total_break_minutes.round(0),
        net_work_minutes: [ net_work_minutes, 0 ].max.round(0),
        net_work_hours: [ net_work_hours, 0 ].max.round(2),
        break_schedule: breaks
      }
    end

    private

    def build_break_schedule
      breaks = []
      shift_minutes = @shift_hours * 60

      # Standard rest breaks: typically 15 minutes per 4 hours worked
      # These are paid breaks in most jurisdictions
      if shift_minutes >= 240 # 4 hours
        breaks << { type: "Rest break", duration: 15, after_hours: 2.0, paid: true }
      end

      # Main break (lunch/meal): configurable, e.g., 30 min after 6 hours
      if @shift_hours >= @break_threshold
        break_after = @break_threshold / 2.0
        breaks << { type: "Meal break", duration: @break_duration.to_i, after_hours: break_after.round(1), paid: false }
      end

      # Additional rest break for longer shifts (after 6 hours of work)
      if shift_minutes >= 480 # 8 hours
        breaks << { type: "Rest break", duration: 15, after_hours: 6.0, paid: true }
      end

      # Second meal break for extended shifts
      if @shift_hours >= @meal_threshold
        breaks << { type: "Meal break", duration: @meal_duration.to_i, after_hours: (@meal_threshold * 0.8).round(1), paid: false }
      end

      breaks.sort_by { |b| b[:after_hours] }
    end

    def validate!
      @errors << "Shift hours must be positive" unless @shift_hours.positive?
      @errors << "Shift hours cannot exceed 24" if @shift_hours > 24
      @errors << "Break threshold must be positive" unless @break_threshold.positive?
      @errors << "Break duration must be positive" unless @break_duration.positive?
      @errors << "Meal threshold must be positive" unless @meal_threshold.positive?
      @errors << "Meal duration must be positive" unless @meal_duration.positive?
    end
  end
end
