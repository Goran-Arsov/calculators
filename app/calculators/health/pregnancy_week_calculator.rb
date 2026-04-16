# frozen_string_literal: true

module Health
  class PregnancyWeekCalculator
    attr_reader :errors

    GESTATION_DAYS = 280
    FIRST_TRIMESTER_END = 13
    SECOND_TRIMESTER_END = 27
    THIRD_TRIMESTER_END = 40

    def initialize(due_date: nil, lmp_date: nil)
      @due_date = parse_date(due_date)
      @lmp_date = parse_date(lmp_date)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      lmp = resolve_lmp
      today = Date.today
      due = lmp + GESTATION_DAYS
      total_days = (today - lmp).to_i
      weeks = total_days / 7
      days = total_days % 7
      days_remaining = (due - today).to_i
      percentage_complete = [ (total_days.to_f / GESTATION_DAYS * 100).round(1), 100.0 ].min

      {
        valid: true,
        current_week: weeks,
        current_day: days,
        trimester: determine_trimester(weeks),
        due_date: due,
        lmp_date: lmp,
        days_remaining: [ days_remaining, 0 ].max,
        percentage_complete: percentage_complete
      }
    end

    private

    def parse_date(value)
      return nil if value.nil? || value.to_s.strip.empty?
      Date.parse(value.to_s)
    rescue Date::Error
      nil
    end

    def resolve_lmp
      if @lmp_date
        @lmp_date
      else
        @due_date - GESTATION_DAYS
      end
    end

    def determine_trimester(weeks)
      if weeks < 1
        "Pre-pregnancy"
      elsif weeks <= FIRST_TRIMESTER_END
        "First"
      elsif weeks <= SECOND_TRIMESTER_END
        "Second"
      elsif weeks <= THIRD_TRIMESTER_END
        "Third"
      else
        "Past due date"
      end
    end

    def validate!
      if @due_date.nil? && @lmp_date.nil?
        @errors << "Either a due date or last menstrual period date is required"
        return
      end

      if @lmp_date
        @errors << "LMP date cannot be in the future" if @lmp_date > Date.today
        @errors << "LMP date seems too far in the past" if @lmp_date < Date.today - GESTATION_DAYS - 14
      end

      if @due_date && @lmp_date.nil?
        derived_lmp = @due_date - GESTATION_DAYS
        @errors << "Due date seems too far in the past" if derived_lmp < Date.today - GESTATION_DAYS - 14
        @errors << "Due date seems too far in the future" if @due_date > Date.today + GESTATION_DAYS + 14
      end
    end
  end
end
