module Health
  class OvulationCalculator
    attr_reader :errors

    DEFAULT_CYCLE_LENGTH = 28
    LUTEAL_PHASE_DAYS = 14
    FERTILE_WINDOW_BEFORE_OVULATION = 5
    FERTILE_WINDOW_AFTER_OVULATION = 1

    def initialize(last_period_date:, cycle_length: DEFAULT_CYCLE_LENGTH)
      @last_period_date = parse_date(last_period_date)
      @cycle_length = cycle_length.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      ovulation_date = @last_period_date + (@cycle_length - LUTEAL_PHASE_DAYS)
      fertile_start = ovulation_date - FERTILE_WINDOW_BEFORE_OVULATION
      fertile_end = ovulation_date + FERTILE_WINDOW_AFTER_OVULATION
      next_period = @last_period_date + @cycle_length

      # Project the next 3 cycles
      cycles = (0..2).map do |i|
        cycle_start = @last_period_date + (@cycle_length * i)
        cycle_ovulation = cycle_start + (@cycle_length - LUTEAL_PHASE_DAYS)
        cycle_fertile_start = cycle_ovulation - FERTILE_WINDOW_BEFORE_OVULATION
        cycle_fertile_end = cycle_ovulation + FERTILE_WINDOW_AFTER_OVULATION
        cycle_next_period = cycle_start + @cycle_length
        {
          cycle_number: i + 1,
          period_start: cycle_start,
          ovulation_date: cycle_ovulation,
          fertile_start: cycle_fertile_start,
          fertile_end: cycle_fertile_end,
          next_period: cycle_next_period
        }
      end

      {
        valid: true,
        ovulation_date: ovulation_date,
        fertile_window_start: fertile_start,
        fertile_window_end: fertile_end,
        next_period: next_period,
        cycle_length: @cycle_length,
        last_period_date: @last_period_date,
        upcoming_cycles: cycles
      }
    end

    private

    def parse_date(value)
      return nil if value.nil? || value.to_s.strip.empty?
      Date.parse(value.to_s)
    rescue Date::Error
      nil
    end

    def validate!
      if @last_period_date.nil?
        @errors << "Last period date is required and must be a valid date"
        return
      end

      @errors << "Cycle length must be between 20 and 45 days" unless @cycle_length.between?(20, 45)
      @errors << "Last period date cannot be more than 1 year ago" if @last_period_date < Date.today - 365
    end
  end
end
