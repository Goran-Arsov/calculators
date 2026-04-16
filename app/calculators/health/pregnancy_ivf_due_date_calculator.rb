# frozen_string_literal: true

module Health
  class PregnancyIvfDueDateCalculator
    attr_reader :errors

    GESTATION_DAYS = 280
    TRIMESTER_WEEKS = [ 13, 27, 40 ].freeze

    # Days to subtract from transfer date to get equivalent LMP
    # For 3-day embryo: LMP = transfer date - 17 days (14 days ovulation + 3 days embryo age)
    # For 5-day embryo: LMP = transfer date - 19 days (14 days ovulation + 5 days embryo age)
    EMBRYO_AGE_OFFSETS = {
      "day_3" => 17,
      "day_5" => 19
    }.freeze

    def initialize(transfer_date:, embryo_type: "day_5")
      @transfer_date = parse_date(transfer_date)
      @embryo_type = embryo_type.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      offset = EMBRYO_AGE_OFFSETS[@embryo_type]
      equivalent_lmp = @transfer_date - offset
      due_date = equivalent_lmp + GESTATION_DAYS

      conception_date = equivalent_lmp + 14
      days_pregnant = (Date.today - equivalent_lmp).to_i
      weeks_pregnant = days_pregnant >= 0 ? days_pregnant / 7 : 0
      days_extra = days_pregnant >= 0 ? days_pregnant % 7 : 0
      raw_days_remaining = (due_date - Date.today).to_i
      overdue = raw_days_remaining < 0

      {
        valid: true,
        transfer_date: @transfer_date,
        embryo_type: @embryo_type,
        embryo_type_label: @embryo_type == "day_3" ? "Day 3 (Cleavage Stage)" : "Day 5 (Blastocyst)",
        equivalent_lmp: equivalent_lmp,
        due_date: due_date,
        conception_date: conception_date,
        weeks_pregnant: weeks_pregnant,
        days_extra: days_extra,
        gestational_age_display: "#{weeks_pregnant} weeks, #{days_extra} days",
        days_remaining: overdue ? 0 : raw_days_remaining,
        overdue: overdue,
        days_overdue: overdue ? raw_days_remaining.abs : 0,
        trimester: current_trimester(weeks_pregnant),
        trimester_dates: trimester_dates(equivalent_lmp),
        milestones: build_milestones(equivalent_lmp)
      }
    end

    private

    def parse_date(value)
      return nil if value.nil? || value.to_s.strip.empty?
      Date.parse(value.to_s)
    rescue Date::Error
      nil
    end

    def current_trimester(weeks)
      if weeks < TRIMESTER_WEEKS[0]
        1
      elsif weeks < TRIMESTER_WEEKS[1]
        2
      else
        3
      end
    end

    def trimester_dates(lmp)
      {
        first_trimester_start: lmp,
        first_trimester_end: lmp + (TRIMESTER_WEEKS[0] * 7),
        second_trimester_start: lmp + (TRIMESTER_WEEKS[0] * 7) + 1,
        second_trimester_end: lmp + (TRIMESTER_WEEKS[1] * 7),
        third_trimester_start: lmp + (TRIMESTER_WEEKS[1] * 7) + 1,
        third_trimester_end: lmp + (TRIMESTER_WEEKS[2] * 7)
      }
    end

    def build_milestones(lmp)
      [
        { week: 6, name: "Heartbeat detectable", date: lmp + (6 * 7) },
        { week: 8, name: "First prenatal visit", date: lmp + (8 * 7) },
        { week: 12, name: "End of first trimester", date: lmp + (12 * 7) },
        { week: 13, name: "NT scan window opens", date: lmp + (13 * 7) },
        { week: 20, name: "Anatomy scan", date: lmp + (20 * 7) },
        { week: 24, name: "Viability milestone", date: lmp + (24 * 7) },
        { week: 27, name: "Start of third trimester", date: lmp + (27 * 7) },
        { week: 28, name: "Glucose screening test", date: lmp + (28 * 7) },
        { week: 36, name: "GBS screening", date: lmp + (36 * 7) },
        { week: 37, name: "Full term begins", date: lmp + (37 * 7) },
        { week: 40, name: "Due date", date: lmp + (40 * 7) }
      ]
    end

    def validate!
      if @transfer_date.nil?
        @errors << "Transfer date is required and must be a valid date"
        return
      end

      unless EMBRYO_AGE_OFFSETS.key?(@embryo_type)
        @errors << "Embryo type must be day_3 or day_5"
        return
      end

      @errors << "Transfer date cannot be more than 10 months in the future" if @transfer_date > Date.today + 300
      @errors << "Transfer date seems too far in the past" if @transfer_date < Date.today - GESTATION_DAYS - 30
    end
  end
end
