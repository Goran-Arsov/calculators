# frozen_string_literal: true

module Everyday
  class PomodoroTimerCalculator
    attr_reader :errors

    WORK_MINUTES_RANGE = (1..120).freeze
    BREAK_MINUTES_RANGE = (1..60).freeze
    LONG_BREAK_MINUTES_RANGE = (1..120).freeze
    SESSIONS_RANGE = (1..10).freeze

    def initialize(work_minutes: 25, break_minutes: 5, long_break_minutes: 15, sessions_before_long_break: 4)
      @work_minutes = work_minutes.to_i
      @break_minutes = break_minutes.to_i
      @long_break_minutes = long_break_minutes.to_i
      @sessions_before_long_break = sessions_before_long_break.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_work = @work_minutes * @sessions_before_long_break
      total_short_breaks = @break_minutes * (@sessions_before_long_break - 1)
      total_cycle_minutes = total_work + total_short_breaks + @long_break_minutes

      {
        valid: true,
        work_minutes: @work_minutes,
        break_minutes: @break_minutes,
        long_break_minutes: @long_break_minutes,
        sessions_before_long_break: @sessions_before_long_break,
        total_cycle_minutes: total_cycle_minutes
      }
    end

    private

    def validate!
      unless WORK_MINUTES_RANGE.cover?(@work_minutes)
        @errors << "Work duration must be between #{WORK_MINUTES_RANGE.first} and #{WORK_MINUTES_RANGE.last} minutes"
      end

      unless BREAK_MINUTES_RANGE.cover?(@break_minutes)
        @errors << "Short break must be between #{BREAK_MINUTES_RANGE.first} and #{BREAK_MINUTES_RANGE.last} minutes"
      end

      unless LONG_BREAK_MINUTES_RANGE.cover?(@long_break_minutes)
        @errors << "Long break must be between #{LONG_BREAK_MINUTES_RANGE.first} and #{LONG_BREAK_MINUTES_RANGE.last} minutes"
      end

      unless SESSIONS_RANGE.cover?(@sessions_before_long_break)
        @errors << "Sessions before long break must be between #{SESSIONS_RANGE.first} and #{SESSIONS_RANGE.last}"
      end
    end
  end
end
