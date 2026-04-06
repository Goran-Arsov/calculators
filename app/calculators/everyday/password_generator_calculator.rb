# frozen_string_literal: true

require "securerandom"

module Everyday
  class PasswordGeneratorCalculator
    attr_reader :errors

    LOWERCASE = ("a".."z").to_a.freeze
    UPPERCASE = ("A".."Z").to_a.freeze
    DIGITS = ("0".."9").to_a.freeze
    SYMBOLS = %w[! @ # $ % ^ & * ( ) - _ = + [ ] { } | ; : ' " , . < > ? / ~ `].freeze

    MIN_LENGTH = 8
    MAX_LENGTH = 64
    MIN_COUNT = 1
    MAX_COUNT = 10

    def initialize(length:, count: 1, include_lowercase: true, include_uppercase: true, include_digits: true, include_symbols: false)
      @length = length.to_i
      @count = count.to_i
      @include_lowercase = ActiveModel::Type::Boolean.new.cast(include_lowercase)
      @include_uppercase = ActiveModel::Type::Boolean.new.cast(include_uppercase)
      @include_digits = ActiveModel::Type::Boolean.new.cast(include_digits)
      @include_symbols = ActiveModel::Type::Boolean.new.cast(include_symbols)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      pool = build_pool
      passwords = @count.times.map { generate_password(pool) }

      pool_size = pool.size
      entropy_bits = (@length * Math.log2(pool_size)).round(1)

      {
        valid: true,
        passwords: passwords,
        length: @length,
        count: @count,
        pool_size: pool_size,
        entropy_bits: entropy_bits
      }
    end

    private

    def build_pool
      pool = []
      pool.concat(LOWERCASE) if @include_lowercase
      pool.concat(UPPERCASE) if @include_uppercase
      pool.concat(DIGITS)    if @include_digits
      pool.concat(SYMBOLS)   if @include_symbols
      pool
    end

    def generate_password(pool)
      required = []
      required << LOWERCASE.sample(random: SecureRandom) if @include_lowercase
      required << UPPERCASE.sample(random: SecureRandom) if @include_uppercase
      required << DIGITS.sample(random: SecureRandom)    if @include_digits
      required << SYMBOLS.sample(random: SecureRandom)   if @include_symbols

      remaining_length = @length - required.size
      remaining = Array.new(remaining_length) { pool.sample(random: SecureRandom) }

      (required + remaining).shuffle(random: SecureRandom).join
    end

    def validate!
      @errors << "At least one character type must be selected" if !@include_lowercase && !@include_uppercase && !@include_digits && !@include_symbols
      @errors << "Length must be between #{MIN_LENGTH} and #{MAX_LENGTH}" if @length < MIN_LENGTH || @length > MAX_LENGTH
      @errors << "Count must be between #{MIN_COUNT} and #{MAX_COUNT}" if @count < MIN_COUNT || @count > MAX_COUNT

      selected_types = [@include_lowercase, @include_uppercase, @include_digits, @include_symbols].count(true)
      @errors << "Length must be at least #{selected_types} to include one of each selected type" if @length < selected_types && @errors.empty?
    end
  end
end
