# frozen_string_literal: true

module Everyday
  class PasswordStrengthCalculator
    attr_reader :errors

    GUESSES_PER_SECOND = 1_000_000_000  # 1 billion (modern GPU cluster)

    def initialize(password:)
      @password = password.to_s
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      pool = character_pool_size
      length = @password.length
      entropy = length * Math.log2(pool)
      combinations = pool**length

      seconds_to_crack = combinations.to_f / GUESSES_PER_SECOND
      crack_time = humanize_seconds(seconds_to_crack)

      score = calculate_score(entropy, length)
      strength_label = strength_from_score(score)

      {
        length: length,
        entropy_bits: entropy.round(1),
        pool_size: pool,
        score: score,
        strength: strength_label,
        crack_time: crack_time,
        has_lowercase: @password.match?(/[a-z]/),
        has_uppercase: @password.match?(/[A-Z]/),
        has_digits: @password.match?(/\d/),
        has_symbols: @password.match?(/[^a-zA-Z0-9]/)
      }
    end

    private

    def character_pool_size
      pool = 0
      pool += 26 if @password.match?(/[a-z]/)
      pool += 26 if @password.match?(/[A-Z]/)
      pool += 10 if @password.match?(/\d/)
      pool += 33 if @password.match?(/[^a-zA-Z0-9]/)
      pool = 26 if pool.zero?  # fallback
      pool
    end

    def calculate_score(entropy, length)
      score = 0
      score += 1 if length >= 8
      score += 1 if length >= 12
      score += 1 if @password.match?(/[a-z]/) && @password.match?(/[A-Z]/)
      score += 1 if @password.match?(/\d/)
      score += 1 if @password.match?(/[^a-zA-Z0-9]/)
      score += 1 if entropy >= 60
      score += 1 if entropy >= 80
      score = [ score, 7 ].min
      score
    end

    def strength_from_score(score)
      case score
      when 0..1 then "Very Weak"
      when 2..3 then "Weak"
      when 4    then "Fair"
      when 5    then "Strong"
      when 6..7 then "Very Strong"
      end
    end

    def humanize_seconds(seconds)
      return "Instant" if seconds < 1

      units = [
        [ 60,                 "second" ],
        [ 60,                 "minute" ],
        [ 24,                 "hour" ],
        [ 365.25,             "day" ],
        [ 1000,               "year" ],
        [ 1000,               "thousand years" ],
        [ 1000,               "million years" ],
        [ 1000,               "billion years" ],
        [ Float::INFINITY,    "trillion+ years" ]
      ]

      remaining = seconds
      units.each_with_index do |(divisor, label), i|
        if remaining < divisor || i == units.size - 1
          count = remaining.round(0).to_i
          count = 1 if count < 1
          plural = count == 1 ? "" : "s"
          return "#{count} #{label}#{plural}" unless label.include?("years")
          return "#{count} #{label}"
        end
        remaining /= divisor
      end
    end

    def validate!
      @errors << "Password cannot be empty" if @password.empty?
    end
  end
end
