# frozen_string_literal: true

module Gardening
  class GrassSeedCalculator
    attr_reader :errors

    # Seed rates expressed as pounds per 1,000 sqft for new lawns.
    # Overseeding uses roughly half the new-lawn rate.
    SEED_RATES_NEW = {
      "kentucky_bluegrass" => 2.0,
      "tall_fescue" => 8.0,
      "fine_fescue" => 4.0,
      "perennial_ryegrass" => 8.0,
      "bermudagrass" => 1.5,
      "zoysia" => 2.0,
      "centipede" => 0.5,
      "bahiagrass" => 7.0
    }.freeze

    PURPOSES = %w[new overseed].freeze

    def initialize(area_sqft:, seed_type:, purpose: "new")
      @area_sqft = area_sqft.to_f
      @seed_type = seed_type.to_s
      @purpose = purpose.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      base_rate = SEED_RATES_NEW[@seed_type]
      rate = @purpose == "overseed" ? base_rate / 2.0 : base_rate
      pounds = (@area_sqft / 1000.0) * rate
      kilos = pounds * 0.453592

      {
        valid: true,
        rate_per_1000: rate.round(2),
        pounds: pounds.round(2),
        kilos: kilos.round(2),
        ounces: (pounds * 16).round(1)
      }
    end

    private

    def validate!
      @errors << "Area must be greater than zero" unless @area_sqft.positive?
      unless SEED_RATES_NEW.key?(@seed_type)
        @errors << "Seed type must be one of: #{SEED_RATES_NEW.keys.join(', ')}"
      end
      unless PURPOSES.include?(@purpose)
        @errors << "Purpose must be one of: #{PURPOSES.join(', ')}"
      end
    end
  end
end
