# frozen_string_literal: true

module Everyday
  class ApiResponseTimeCalculator
    attr_reader :errors

    def initialize(response_times_csv:)
      @response_times_csv = response_times_csv.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      values = parse_values
      return { valid: false, errors: @errors } if @errors.any?

      sorted = values.sort
      count = sorted.length
      mean = sorted.sum / count.to_f
      median = percentile(sorted, 50)
      std_dev = Math.sqrt(sorted.map { |v| (v - mean)**2 }.sum / count.to_f)

      {
        valid: true,
        count: count,
        mean: mean.round(2),
        median: median.round(2),
        min: sorted.first.round(2),
        max: sorted.last.round(2),
        std_dev: std_dev.round(2),
        p50: median.round(2),
        p90: percentile(sorted, 90).round(2),
        p95: percentile(sorted, 95).round(2),
        p99: percentile(sorted, 99).round(2)
      }
    end

    private

    def validate!
      @errors << "Response times cannot be empty" if @response_times_csv.empty?
    end

    def parse_values
      parts = @response_times_csv.split(",").map(&:strip).reject(&:empty?)

      if parts.empty?
        @errors << "No valid numbers found in input"
        return []
      end

      values = []
      parts.each do |part|
        unless part.match?(/\A-?\d+(\.\d+)?\z/)
          @errors << "Invalid number: '#{part}'"
          return []
        end
        val = part.to_f
        if val < 0
          @errors << "Response times cannot be negative: #{val}"
          return []
        end
        values << val
      end

      values
    end

    # Nearest-rank method for percentile calculation
    def percentile(sorted, pct)
      return sorted.first if sorted.length == 1

      rank = (pct / 100.0 * sorted.length).ceil
      rank = [ rank, 1 ].max
      rank = [ rank, sorted.length ].min
      sorted[rank - 1]
    end
  end
end
