# frozen_string_literal: true

module Relationships
  class OnlineDatingRoiCalculator
    attr_reader :errors

    MINUTES_PER_MESSAGE = 3
    MINUTES_PER_SWIPE_SESSION = 15

    def initialize(messages_per_week:, response_rate_pct:, date_conversion_pct:, relationship_rate_pct:)
      @messages_per_week = messages_per_week.to_i
      @response_rate = response_rate_pct.to_f / 100.0
      @date_conversion = date_conversion_pct.to_f / 100.0
      @relationship_rate = relationship_rate_pct.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      responses_per_week = @messages_per_week * @response_rate
      dates_per_week = responses_per_week * @date_conversion
      weeks_to_relationship = @relationship_rate.positive? ? (1.0 / (dates_per_week * @relationship_rate)) : Float::INFINITY

      messages_needed = @messages_per_week * weeks_to_relationship
      total_date_time_hours = messages_needed * MINUTES_PER_MESSAGE / 60.0
      weeks_capped = [ weeks_to_relationship, 520 ].min

      {
        valid: true,
        responses_per_week: responses_per_week.round(1),
        dates_per_week: dates_per_week.round(2),
        weeks_to_relationship: weeks_capped.round(1),
        months_to_relationship: (weeks_capped / 4.33).round(1),
        messages_needed: messages_needed.round,
        time_invested_hours: total_date_time_hours.round(1)
      }
    end

    private

    def validate!
      @errors << "Messages per week must be at least 1" if @messages_per_week < 1
      @errors << "Response rate must be greater than zero" unless @response_rate.positive?
      @errors << "Date conversion rate must be greater than zero" unless @date_conversion.positive?
      @errors << "Relationship rate must be greater than zero" unless @relationship_rate.positive?
    end
  end
end
