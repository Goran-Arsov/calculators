# frozen_string_literal: true

module Relationships
  class ZodiacCompatibilityCalculator
    attr_reader :errors

    SIGNS = %w[aries taurus gemini cancer leo virgo libra scorpio sagittarius capricorn aquarius pisces].freeze

    ELEMENTS = {
      "aries" => :fire, "leo" => :fire, "sagittarius" => :fire,
      "taurus" => :earth, "virgo" => :earth, "capricorn" => :earth,
      "gemini" => :air, "libra" => :air, "aquarius" => :air,
      "cancer" => :water, "scorpio" => :water, "pisces" => :water
    }.freeze

    COMPATIBLE_ELEMENTS = { fire: :air, air: :fire, earth: :water, water: :earth }.freeze

    def initialize(sign1:, sign2:)
      @sign1 = sign1.to_s.downcase.strip
      @sign2 = sign2.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      el1 = ELEMENTS[@sign1]
      el2 = ELEMENTS[@sign2]

      base = base_score(el1, el2)
      same_sign_bonus = (@sign1 == @sign2) ? 5 : 0
      opposite_bonus = opposite_signs?(@sign1, @sign2) ? 10 : 0
      overall = [ base + same_sign_bonus + opposite_bonus, 99 ].min

      {
        valid: true,
        sign1: @sign1,
        sign2: @sign2,
        element1: el1,
        element2: el2,
        love: [ overall + 2, 99 ].min,
        friendship: [ base + 5, 99 ].min,
        communication: communication_score(el1, el2),
        overall: overall,
        label: label_for(overall)
      }
    end

    private

    def validate!
      @errors << "First sign is invalid" unless SIGNS.include?(@sign1)
      @errors << "Second sign is invalid" unless SIGNS.include?(@sign2)
    end

    def base_score(el1, el2)
      return 85 if el1 == el2
      return 90 if COMPATIBLE_ELEMENTS[el1] == el2
      55
    end

    def opposite_signs?(s1, s2)
      i1 = SIGNS.index(s1)
      i2 = SIGNS.index(s2)
      ((i1 - i2) % 12).abs == 6
    end

    def communication_score(el1, el2)
      return 92 if el1 == :air || el2 == :air
      return 78 if el1 == el2
      65
    end

    def label_for(overall)
      case overall
      when 85..100 then "Cosmic match"
      when 70..84 then "Strong compatibility"
      when 55..69 then "Workable pairing"
      else "Opposites attract"
      end
    end
  end
end
