# frozen_string_literal: true

module Everyday
  class ApiRateLimitCalculator
    attr_reader :errors

    SECONDS_PER_MINUTE = 60
    SECONDS_PER_HOUR = 3_600
    SECONDS_PER_DAY = 86_400

    def initialize(rate_limit:, window_seconds:, current_usage: 0, burst_limit: nil)
      @rate_limit = rate_limit.to_i
      @window_seconds = window_seconds.to_i
      @current_usage = current_usage.to_i
      @burst_limit = burst_limit.present? ? burst_limit.to_i : nil
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      requests_per_second = @rate_limit.to_f / @window_seconds
      requests_per_minute = requests_per_second * SECONDS_PER_MINUTE
      requests_per_hour = requests_per_second * SECONDS_PER_HOUR
      requests_per_day = requests_per_second * SECONDS_PER_DAY

      remaining = [ @rate_limit - @current_usage, 0 ].max
      usage_percent = (@current_usage.to_f / @rate_limit * 100).round(1)
      time_per_request_ms = (@window_seconds.to_f / @rate_limit * 1000).round(2)

      time_until_reset = if @current_usage >= @rate_limit
                           @window_seconds
      else
                           0
      end

      safe_requests_per_second = (requests_per_second * 0.8).round(4)

      result = {
        valid: true,
        rate_limit: @rate_limit,
        window_seconds: @window_seconds,
        requests_per_second: requests_per_second.round(4),
        requests_per_minute: requests_per_minute.round(2),
        requests_per_hour: requests_per_hour.round(2),
        requests_per_day: requests_per_day.round(0),
        remaining: remaining,
        usage_percent: usage_percent,
        time_per_request_ms: time_per_request_ms,
        time_until_reset: time_until_reset,
        safe_requests_per_second: safe_requests_per_second,
        current_usage: @current_usage
      }

      if @burst_limit
        result[:burst_limit] = @burst_limit
        result[:burst_ratio] = (@burst_limit.to_f / @rate_limit).round(2)
      end

      result
    end

    private

    def validate!
      @errors << "Rate limit must be greater than zero" unless @rate_limit.positive?
      @errors << "Window must be greater than zero" unless @window_seconds.positive?
      @errors << "Current usage cannot be negative" if @current_usage.negative?
      @errors << "Burst limit must be greater than zero" if @burst_limit && !@burst_limit.positive?
    end
  end
end
