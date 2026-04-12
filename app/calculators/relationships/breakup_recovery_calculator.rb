# frozen_string_literal: true

module Relationships
  class BreakupRecoveryCalculator
    attr_reader :errors

    INTENSITY_MULTIPLIER = {
      "casual" => 0.5,
      "serious" => 1.0,
      "engaged" => 1.4,
      "married" => 1.8
    }.freeze

    WHO_INITIATED_MULTIPLIER = {
      "you" => 0.7,
      "mutual" => 1.0,
      "them" => 1.3
    }.freeze

    def initialize(months_together:, intensity:, who_initiated:, first_love: false)
      @months_together = months_together.to_f
      @intensity = intensity.to_s
      @who_initiated = who_initiated.to_s
      @first_love = first_love
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Research from Ohio State suggests ~11 weeks for short relationships, with
      # longer/more serious relationships taking up to half the relationship length.
      base_weeks = [ 11, @months_together * 2 ].max
      recovery_weeks = base_weeks * INTENSITY_MULTIPLIER[@intensity] * WHO_INITIATED_MULTIPLIER[@who_initiated]
      recovery_weeks *= 1.2 if @first_love

      {
        valid: true,
        recovery_weeks: recovery_weeks.round(1),
        recovery_months: (recovery_weeks / 4.33).round(1),
        stages: [
          { name: "Denial & shock", weeks: (recovery_weeks * 0.1).round(1) },
          { name: "Pain & grief", weeks: (recovery_weeks * 0.3).round(1) },
          { name: "Anger & bargaining", weeks: (recovery_weeks * 0.2).round(1) },
          { name: "Acceptance", weeks: (recovery_weeks * 0.25).round(1) },
          { name: "Moving on", weeks: (recovery_weeks * 0.15).round(1) }
        ]
      }
    end

    private

    def validate!
      @errors << "Months together must be greater than zero" unless @months_together.positive?
      @errors << "Intensity is invalid" unless INTENSITY_MULTIPLIER.key?(@intensity)
      @errors << "Who initiated is invalid" unless WHO_INITIATED_MULTIPLIER.key?(@who_initiated)
    end
  end
end
