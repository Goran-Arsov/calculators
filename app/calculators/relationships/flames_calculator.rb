# frozen_string_literal: true

module Relationships
  class FlamesCalculator
    attr_reader :errors

    OUTCOMES = %w[Friends Love Affection Marriage Enemies Siblings].freeze

    def initialize(name1:, name2:)
      @name1 = name1.to_s.strip
      @name2 = name2.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      chars1 = letters(@name1)
      chars2 = letters(@name2)

      # Remove common letters once-for-one
      chars1.each do |c|
        if (i = chars2.index(c))
          chars2.delete_at(i)
          chars1[chars1.index(c)] = nil
        end
      end
      remaining = chars1.compact.length + chars2.length
      remaining = 1 if remaining.zero?

      # Count through FLAMES removing letters until one remains
      flames = OUTCOMES.dup
      index = 0
      while flames.length > 1
        index = (index + remaining - 1) % flames.length
        flames.delete_at(index)
      end

      {
        valid: true,
        name1: @name1,
        name2: @name2,
        remaining_letters: remaining,
        outcome: flames.first,
        outcome_description: describe(flames.first)
      }
    end

    private

    def validate!
      @errors << "First name is required" if @name1.empty?
      @errors << "Second name is required" if @name2.empty?
      @errors << "Names must contain letters" if letters(@name1).empty? || letters(@name2).empty?
    end

    def letters(str)
      str.downcase.gsub(/[^a-z]/, "").chars
    end

    def describe(outcome)
      {
        "Friends" => "You make great friends who lift each other up",
        "Love" => "You are meant to fall in love",
        "Affection" => "You share deep affection and warmth",
        "Marriage" => "You could end up married",
        "Enemies" => "You clash — opposites who push each other's buttons",
        "Siblings" => "You act like brother and sister"
      }[outcome]
    end
  end
end
