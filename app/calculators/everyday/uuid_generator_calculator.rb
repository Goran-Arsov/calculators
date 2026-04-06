# frozen_string_literal: true

require "securerandom"

module Everyday
  class UuidGeneratorCalculator
    attr_reader :errors

    MIN_COUNT = 1
    MAX_COUNT = 10

    def initialize(count: 1, uppercase: false)
      @count = count.to_i
      @uppercase = ActiveModel::Type::Boolean.new.cast(uppercase)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      uuids = Array.new(@count) { generate_uuid }

      {
        valid: true,
        uuids: uuids,
        count: @count,
        uppercase: @uppercase,
        version: 4
      }
    end

    private

    def generate_uuid
      uuid = SecureRandom.uuid
      @uppercase ? uuid.upcase : uuid
    end

    def validate!
      @errors << "Count must be between #{MIN_COUNT} and #{MAX_COUNT}" if @count < MIN_COUNT || @count > MAX_COUNT
    end
  end
end
