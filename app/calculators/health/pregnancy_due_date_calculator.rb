module Health
  class PregnancyDueDateCalculator
    attr_reader :errors

    GESTATION_DAYS = 280
    CONCEPTION_OFFSET_DAYS = 14
    TRIMESTER_WEEKS = [ 13, 27, 40 ].freeze
    MAX_OVERDUE_DAYS = 14

    def initialize(last_period_date:)
      @last_period_date = parse_date(last_period_date)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      due_date = @last_period_date + GESTATION_DAYS
      conception_date = @last_period_date + CONCEPTION_OFFSET_DAYS
      weeks_pregnant = calculate_weeks_pregnant
      raw_days_remaining = (due_date - Date.today).to_i
      overdue = raw_days_remaining < 0

      {
        valid: true,
        due_date: due_date,
        conception_date: conception_date,
        trimester_dates: trimester_dates,
        weeks_pregnant: weeks_pregnant,
        days_remaining: overdue ? 0 : raw_days_remaining,
        overdue: overdue,
        days_overdue: overdue ? raw_days_remaining.abs : 0
      }
    end

    private

    def parse_date(value)
      return nil if value.nil? || value.to_s.strip.empty?
      Date.parse(value.to_s)
    rescue Date::Error
      nil
    end

    def calculate_weeks_pregnant
      days = (Date.today - @last_period_date).to_i
      return 0 if days < 0

      days / 7
    end

    def trimester_dates
      {
        first_trimester_start: @last_period_date,
        first_trimester_end: @last_period_date + (TRIMESTER_WEEKS[0] * 7),
        second_trimester_start: @last_period_date + (TRIMESTER_WEEKS[0] * 7) + 1,
        second_trimester_end: @last_period_date + (TRIMESTER_WEEKS[1] * 7),
        third_trimester_start: @last_period_date + (TRIMESTER_WEEKS[1] * 7) + 1,
        third_trimester_end: @last_period_date + (TRIMESTER_WEEKS[2] * 7)
      }
    end

    def validate!
      if @last_period_date.nil?
        @errors << "Last period date is required and must be a valid date"
        return
      end

      @errors << "Last period date cannot be in the future" if @last_period_date > Date.today
      @errors << "Last period date seems too far in the past" if @last_period_date < Date.today - GESTATION_DAYS - MAX_OVERDUE_DAYS
    end
  end
end
