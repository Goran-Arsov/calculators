# frozen_string_literal: true

module Everyday
  class SecureRandomCalculator
    attr_reader :errors

    LOWERCASE = ("a".."z").to_a.freeze
    UPPERCASE = ("A".."Z").to_a.freeze
    DIGITS = ("0".."9").to_a.freeze
    SPECIAL = %w[! @ # $ % ^ & * ( ) [ ] { } | ; . ].freeze

    MIN_LENGTH = 6
    MAX_LENGTH = 30

    def initialize(length:, include_lowercase: true, include_uppercase: true, include_digits: true, include_special: false)
      @length = length.to_i
      @include_lowercase = ActiveModel::Type::Boolean.new.cast(include_lowercase)
      @include_uppercase = ActiveModel::Type::Boolean.new.cast(include_uppercase)
      @include_digits = ActiveModel::Type::Boolean.new.cast(include_digits)
      @include_special = ActiveModel::Type::Boolean.new.cast(include_special)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      pool = build_pool
      generated = generate_string(pool)

      pool_size = pool.size
      entropy = @length * Math.log2(pool_size)

      {
        valid: true,
        generated: generated,
        length: @length,
        pool_size: pool_size,
        entropy_bits: entropy.round(1),
        has_lowercase: @include_lowercase,
        has_uppercase: @include_uppercase,
        has_digits: @include_digits,
        has_special: @include_special
      }
    end

    private

    def build_pool
      pool = []
      pool.concat(LOWERCASE) if @include_lowercase
      pool.concat(UPPERCASE) if @include_uppercase
      pool.concat(DIGITS)    if @include_digits
      pool.concat(SPECIAL)   if @include_special
      pool
    end

    def generate_string(pool)
      # Ensure at least one character from each selected set
      required = []
      required << LOWERCASE.sample(random: SecureRandom) if @include_lowercase
      required << UPPERCASE.sample(random: SecureRandom) if @include_uppercase
      required << DIGITS.sample(random: SecureRandom)    if @include_digits
      required << SPECIAL.sample(random: SecureRandom)   if @include_special

      remaining_length = @length - required.size
      remaining = Array.new(remaining_length) { pool.sample(random: SecureRandom) }

      (required + remaining).shuffle(random: SecureRandom).join
    end

    def validate!
      @errors << "At least one character type must be selected" if !@include_lowercase && !@include_uppercase && !@include_digits && !@include_special
      @errors << "Length must be between #{MIN_LENGTH} and #{MAX_LENGTH}" if @length < MIN_LENGTH || @length > MAX_LENGTH

      # Ensure length can fit at least one of each selected type
      selected_types = [ @include_lowercase, @include_uppercase, @include_digits, @include_special ].count(true)
      @errors << "Length must be at least #{selected_types} to include one of each selected type" if @length < selected_types && @errors.empty?
    end
  end
end
