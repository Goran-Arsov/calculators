# frozen_string_literal: true

module Health
  class DogAgeCalculator
    attr_reader :errors

    VALID_SIZES = %w[small medium large].freeze

    # Size-based aging adjustments (applied after year 2)
    SIZE_FACTORS = {
      "small" => 4,
      "medium" => 4.5,
      "large" => 5
    }.freeze

    def initialize(dog_age:, size: "medium")
      @dog_age = dog_age.to_f
      @size = size.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      human_age = calculate_human_age

      {
        valid: true,
        human_age_equivalent: human_age.round(1),
        dog_age: @dog_age,
        size: @size
      }
    end

    private

    def calculate_human_age
      return 0.0 if @dog_age <= 0

      # Logarithmic formula: human_age = 16 × ln(dog_age) + 31
      base_age = 16 * Math.log(@dog_age) + 31

      # Apply size adjustment: small dogs age slower, large dogs faster
      case @size
      when "small"
        base_age * 0.90
      when "large"
        base_age * 1.10
      else
        base_age
      end
    end

    def validate!
      @errors << "Dog age must be positive" unless @dog_age > 0
      @errors << "Dog age must be realistic (up to 30 years)" unless @dog_age <= 30
      @errors << "Size must be small, medium, or large" unless VALID_SIZES.include?(@size)
    end
  end
end
