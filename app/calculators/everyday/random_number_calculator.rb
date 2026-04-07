# frozen_string_literal: true

module Everyday
  class RandomNumberCalculator
    attr_reader :errors

    MAX_COUNT = 1000

    def initialize(min:, max:, count: 1, unique: false)
      @min = min.to_i
      @max = max.to_i
      @count = count.to_i
      @unique = ActiveModel::Type::Boolean.new.cast(unique)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      numbers = generate_numbers

      {
        valid: true,
        numbers: numbers,
        min: @min,
        max: @max,
        count: numbers.size,
        has_duplicates: numbers.size != numbers.uniq.size
      }
    end

    private

    def generate_numbers
      range = @min..@max

      if @unique
        pool_size = @max - @min + 1
        actual_count = [ @count, pool_size ].min
        range.to_a.sample(actual_count, random: SecureRandom)
      else
        Array.new(@count) { SecureRandom.random_number(range) }
      end
    end

    def validate!
      @errors << "Min must be less than or equal to Max" if @min > @max
      @errors << "Count must be between 1 and #{MAX_COUNT}" if @count < 1 || @count > MAX_COUNT

      if @unique && @errors.empty?
        pool_size = @max - @min + 1
        if pool_size < 1
          @errors << "Range must contain at least one number for unique mode"
        end
      end
    end
  end
end
