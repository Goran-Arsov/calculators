module Automotive
  class OilChangeIntervalCalculator
    attr_reader :errors

    def initialize(oil_type:, current_mileage:, last_change_mileage:, last_change_date:,
                   daily_miles: 30, driving_conditions: "normal")
      @oil_type = oil_type.to_s
      @current_mileage = current_mileage.to_f
      @last_change_mileage = last_change_mileage.to_f
      @last_change_date = parse_date(last_change_date)
      @daily_miles = daily_miles.to_f
      @driving_conditions = driving_conditions.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      base_interval_miles = oil_type_interval_miles
      base_interval_months = oil_type_interval_months

      # Apply driving conditions multiplier
      condition_factor = case @driving_conditions
      when "severe" then 0.5
      when "moderate" then 0.75
      else 1.0 # normal
      end

      recommended_interval_miles = (base_interval_miles * condition_factor).round(0)
      recommended_interval_months = (base_interval_months * condition_factor).round(0)

      miles_since_change = @current_mileage - @last_change_mileage
      miles_remaining = [ recommended_interval_miles - miles_since_change, 0 ].max

      days_since_change = @last_change_date ? (Date.today - @last_change_date).to_i : 0
      months_since_change = days_since_change / 30.0

      # Estimate next change date based on daily driving
      days_until_next = @daily_miles > 0 ? (miles_remaining / @daily_miles).ceil : 0
      next_change_date_by_miles = Date.today + days_until_next

      # Also check time-based interval
      next_change_date_by_time = @last_change_date ? (@last_change_date >> recommended_interval_months.to_i) : nil
      next_change_mileage = @last_change_mileage + recommended_interval_miles

      # Take the earlier of miles-based or time-based
      if next_change_date_by_time && next_change_date_by_time < next_change_date_by_miles
        next_change_date = next_change_date_by_time
        trigger = "time"
      else
        next_change_date = next_change_date_by_miles
        trigger = "mileage"
      end

      overdue = miles_since_change > recommended_interval_miles ||
                (next_change_date_by_time && Date.today > next_change_date_by_time)

      oil_life_remaining_pct = recommended_interval_miles > 0 ?
        ([ (1.0 - miles_since_change.to_f / recommended_interval_miles) * 100.0, 0 ].max) : 0.0

      {
        valid: true,
        oil_type: @oil_type,
        driving_conditions: @driving_conditions,
        recommended_interval_miles: recommended_interval_miles.to_i,
        recommended_interval_months: recommended_interval_months.to_i,
        miles_since_last_change: miles_since_change.round(0),
        miles_remaining: miles_remaining.round(0),
        oil_life_remaining_pct: oil_life_remaining_pct.round(1),
        next_change_mileage: next_change_mileage.round(0),
        next_change_date: next_change_date.to_s,
        trigger: trigger,
        overdue: overdue
      }
    end

    private

    def oil_type_interval_miles
      case @oil_type
      when "conventional" then 3_000
      when "synthetic_blend" then 5_000
      when "full_synthetic" then 7_500
      when "high_mileage" then 5_000
      else 5_000
      end
    end

    def oil_type_interval_months
      case @oil_type
      when "conventional" then 3
      when "synthetic_blend" then 6
      when "full_synthetic" then 12
      when "high_mileage" then 6
      else 6
      end
    end

    def parse_date(value)
      return value if value.is_a?(Date)
      return nil if value.nil? || value.to_s.strip.empty?
      Date.parse(value.to_s)
    rescue ArgumentError
      nil
    end

    def validate!
      @errors << "Current mileage must be positive" unless @current_mileage > 0
      @errors << "Last change mileage cannot be negative" if @last_change_mileage < 0
      @errors << "Current mileage must be greater than last change mileage" if @current_mileage < @last_change_mileage
      @errors << "Daily miles must be positive" unless @daily_miles > 0
      unless %w[conventional synthetic_blend full_synthetic high_mileage].include?(@oil_type)
        @errors << "Oil type must be conventional, synthetic_blend, full_synthetic, or high_mileage"
      end
      unless %w[normal moderate severe].include?(@driving_conditions)
        @errors << "Driving conditions must be normal, moderate, or severe"
      end
      @errors << "Last change date is required" if @last_change_date.nil?
    end
  end
end
