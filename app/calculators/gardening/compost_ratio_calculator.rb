# frozen_string_literal: true

module Gardening
  class CompostRatioCalculator
    attr_reader :errors

    # Typical carbon and nitrogen content (as percentage of dry weight) for brown and green
    # compost materials. Browns are carbon-rich (dry leaves, straw, cardboard); greens are
    # nitrogen-rich (grass clippings, kitchen scraps, coffee grounds). Ideal C:N ratio for
    # hot composting is 25:1 to 30:1.
    BROWN_CARBON_PCT = 50.0
    BROWN_NITROGEN_PCT = 0.5
    GREEN_CARBON_PCT = 45.0
    GREEN_NITROGEN_PCT = 2.5

    IDEAL_MIN = 25.0
    IDEAL_MAX = 30.0

    def initialize(browns_lb:, greens_lb:)
      @browns_lb = browns_lb.to_f
      @greens_lb = greens_lb.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_carbon = (@browns_lb * BROWN_CARBON_PCT / 100.0) + (@greens_lb * GREEN_CARBON_PCT / 100.0)
      total_nitrogen = (@browns_lb * BROWN_NITROGEN_PCT / 100.0) + (@greens_lb * GREEN_NITROGEN_PCT / 100.0)
      ratio = total_carbon / total_nitrogen

      {
        valid: true,
        carbon_lb: total_carbon.round(2),
        nitrogen_lb: total_nitrogen.round(2),
        ratio: ratio.round(1),
        status: status_for(ratio),
        ideal_range: "#{IDEAL_MIN.to_i}:1 to #{IDEAL_MAX.to_i}:1"
      }
    end

    private

    def status_for(ratio)
      if ratio < IDEAL_MIN
        "Too nitrogen-rich — add more browns"
      elsif ratio > IDEAL_MAX
        "Too carbon-rich — add more greens"
      else
        "Ideal for hot composting"
      end
    end

    def validate!
      @errors << "Browns weight must be zero or positive" if @browns_lb.negative?
      @errors << "Greens weight must be zero or positive" if @greens_lb.negative?
      unless @browns_lb.positive? || @greens_lb.positive?
        @errors << "Must provide at least one of browns or greens weight"
      end
      if @browns_lb.positive? && @greens_lb.zero?
        @errors << "Greens weight must be greater than zero to compute ratio"
      end
    end
  end
end
