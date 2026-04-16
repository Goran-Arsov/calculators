# frozen_string_literal: true

module Health
  class ConceptionCalculator
    attr_reader :errors

    GESTATION_DAYS = 280
    CONCEPTION_OFFSET_DAYS = 14
    FERTILE_WINDOW_START = 10  # days after LMP
    FERTILE_WINDOW_END = 17    # days after LMP
    AVERAGE_CYCLE_LENGTH = 28

    def initialize(due_date: nil, last_period_date: nil, cycle_length: AVERAGE_CYCLE_LENGTH)
      @due_date = parse_date(due_date)
      @last_period_date = parse_date(last_period_date)
      @cycle_length = cycle_length.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @due_date
        calculate_from_due_date
      else
        calculate_from_lmp
      end
    end

    private

    def parse_date(value)
      return nil if value.nil? || value.to_s.strip.empty?
      Date.parse(value.to_s)
    rescue Date::Error
      nil
    end

    def calculate_from_due_date
      # Work backwards from due date
      lmp = @due_date - GESTATION_DAYS
      ovulation_day = @cycle_length - 14 # luteal phase is ~14 days
      conception_date = lmp + ovulation_day
      fertile_start = conception_date - 5
      fertile_end = conception_date + 1

      {
        valid: true,
        method: "due_date",
        estimated_conception: conception_date,
        estimated_lmp: lmp,
        fertile_window_start: fertile_start,
        fertile_window_end: fertile_end,
        due_date: @due_date,
        conception_week: week_range(conception_date)
      }
    end

    def calculate_from_lmp
      ovulation_day = @cycle_length - 14
      conception_date = @last_period_date + ovulation_day
      fertile_start = conception_date - 5
      fertile_end = conception_date + 1
      due_date = @last_period_date + GESTATION_DAYS

      {
        valid: true,
        method: "lmp",
        estimated_conception: conception_date,
        estimated_lmp: @last_period_date,
        fertile_window_start: fertile_start,
        fertile_window_end: fertile_end,
        due_date: due_date,
        conception_week: week_range(conception_date)
      }
    end

    # Returns the range of the conception week (e.g., conception likely occurred
    # between date-2 and date+2 given natural variation)
    def week_range(conception_date)
      {
        earliest: conception_date - 2,
        most_likely: conception_date,
        latest: conception_date + 2
      }
    end

    def validate!
      if @due_date.nil? && @last_period_date.nil?
        @errors << "Either due date or last period date is required"
        return
      end

      if @due_date && @last_period_date
        @errors << "Provide either due date or last period date, not both"
        return
      end

      @errors << "Cycle length must be between 20 and 45 days" unless @cycle_length.between?(20, 45)

      if @due_date
        @errors << "Due date must be a valid date" if @due_date.nil?
      end

      if @last_period_date
        @errors << "Last period date must be a valid date" if @last_period_date.nil?
      end
    end
  end
end
