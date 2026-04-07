# frozen_string_literal: true

module Everyday
  class StopwatchCalculator
    attr_reader :errors

    def initialize(elapsed_ms:)
      @elapsed_ms = elapsed_ms.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_seconds = @elapsed_ms / 1000.0
      total_minutes = total_seconds / 60.0

      hours = @elapsed_ms / 3_600_000
      minutes = (@elapsed_ms % 3_600_000) / 60_000
      seconds = (@elapsed_ms % 60_000) / 1000
      milliseconds = @elapsed_ms % 1000

      formatted_time = format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)

      {
        valid: true,
        formatted_time: formatted_time,
        total_seconds: total_seconds.round(3),
        total_minutes: total_minutes.round(3),
        elapsed_ms: @elapsed_ms
      }
    end

    private

    def validate!
      if @elapsed_ms.negative?
        @errors << "Elapsed time cannot be negative"
      end
    end
  end
end
