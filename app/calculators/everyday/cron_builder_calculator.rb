# frozen_string_literal: true

module Everyday
  class CronBuilderCalculator
    attr_reader :errors

    FIELD_RANGES = {
      minute: 0..59,
      hour: 0..23,
      day_of_month: 1..31,
      month: 1..12,
      day_of_week: 0..6
    }.freeze

    def initialize(minute: "*", hour: "*", day_of_month: "*", month: "*", day_of_week: "*")
      @minute = minute.to_s.strip
      @hour = hour.to_s.strip
      @day_of_month = day_of_month.to_s.strip
      @month = month.to_s.strip
      @day_of_week = day_of_week.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      expression = "#{@minute} #{@hour} #{@day_of_month} #{@month} #{@day_of_week}"

      {
        valid: true,
        expression: expression,
        description: describe(expression),
        fields: {
          minute: @minute,
          hour: @hour,
          day_of_month: @day_of_month,
          month: @month,
          day_of_week: @day_of_week
        }
      }
    end

    private

    def validate!
      validate_field(:minute, @minute)
      validate_field(:hour, @hour)
      validate_field(:day_of_month, @day_of_month)
      validate_field(:month, @month)
      validate_field(:day_of_week, @day_of_week)
    end

    def validate_field(name, value)
      return if value == "*"
      return if value.match?(%r{\A\*/\d+\z}) # */N
      return if value.match?(/\A[\d,\-\/]+\z/) && valid_values?(name, value)

      @errors << "Invalid #{name.to_s.tr('_', ' ')} value: #{value}"
    end

    def valid_values?(name, value)
      range = FIELD_RANGES[name]
      parts = value.split(",")

      parts.all? do |part|
        if part.include?("/")
          range_part, _step = part.split("/")
          range_part == "*" || check_range(range_part, range)
        elsif part.include?("-")
          check_range(part, range)
        else
          num = part.to_i
          range.include?(num)
        end
      end
    end

    def check_range(part, range)
      if part.include?("-")
        low, high = part.split("-").map(&:to_i)
        range.include?(low) && range.include?(high) && low <= high
      else
        range.include?(part.to_i)
      end
    end

    def describe(expression)
      parts = expression.split(" ")
      min, hour, dom, mon, dow = parts

      pieces = []

      # Minute
      if min == "*"
        pieces << "Every minute"
      elsif min.start_with?("*/")
        pieces << "Every #{min.sub('*/', '')} minutes"
      else
        pieces << "At minute #{min}"
      end

      # Hour
      if hour == "*"
        pieces << "of every hour"
      elsif hour.start_with?("*/")
        pieces << "every #{hour.sub('*/', '')} hours"
      else
        pieces << "past hour #{hour}"
      end

      # Day of month
      if dom != "*"
        if dom.start_with?("*/")
          pieces << "every #{dom.sub('*/', '')} days"
        else
          pieces << "on day #{dom}"
        end
      end

      # Month
      if mon != "*"
        month_names = %w[_ January February March April May June July August September October November December]
        if mon.start_with?("*/")
          pieces << "every #{mon.sub('*/', '')} months"
        else
          names = mon.split(",").map { |m| month_names[m.to_i] || m }.join(", ")
          pieces << "in #{names}"
        end
      end

      # Day of week
      if dow != "*"
        day_names = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
        if dow.start_with?("*/")
          pieces << "every #{dow.sub('*/', '')} days of week"
        else
          names = dow.split(",").map { |d| day_names[d.to_i] || d }.join(", ")
          pieces << "on #{names}"
        end
      end

      pieces.join(" ")
    end
  end
end
