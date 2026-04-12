# frozen_string_literal: true

module Relationships
  class LoveCompatibilityCalculator
    attr_reader :errors

    LETTER_VALUES = ("a".."z").each_with_index.to_h { |l, i| [ l, i + 1 ] }.freeze

    def initialize(name1:, name2:)
      @name1 = name1.to_s.strip
      @name2 = name2.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      sum1 = letter_sum(@name1)
      sum2 = letter_sum(@name2)
      total = sum1 + sum2
      percent = score_from_sum(total)

      {
        valid: true,
        name1: @name1,
        name2: @name2,
        sum1: sum1,
        sum2: sum2,
        combined_sum: total,
        percentage: percent,
        label: label_for(percent)
      }
    end

    private

    def validate!
      @errors << "First name is required" if @name1.empty?
      @errors << "Second name is required" if @name2.empty?
      @errors << "Names must contain letters" if letters_only(@name1).empty? || letters_only(@name2).empty?
    end

    def letters_only(str)
      str.downcase.gsub(/[^a-z]/, "")
    end

    def letter_sum(str)
      letters_only(str).chars.sum { |c| LETTER_VALUES[c] || 0 }
    end

    def score_from_sum(total)
      # Normalize to 40-99% range — never 0% (unkind) or 100% (suspicious)
      40 + (total * 13) % 60
    end

    def label_for(percent)
      case percent
      when 90..100 then "Soulmates"
      when 75..89 then "Excellent match"
      when 60..74 then "Good match"
      when 50..59 then "Could work"
      else "Needs effort"
      end
    end
  end
end
