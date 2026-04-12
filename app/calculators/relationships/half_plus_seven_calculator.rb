# frozen_string_literal: true

module Relationships
  class HalfPlusSevenCalculator
    attr_reader :errors

    def initialize(age:)
      @age = age.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      min_age = (@age / 2.0) + 7
      max_age = (@age - 7) * 2
      range_size = max_age - min_age

      {
        valid: true,
        age: @age,
        min_age: min_age.floor,
        max_age: max_age.floor,
        range_size: range_size.floor
      }
    end

    private

    def validate!
      @errors << "Age must be at least 14" if @age < 14
    end
  end
end
