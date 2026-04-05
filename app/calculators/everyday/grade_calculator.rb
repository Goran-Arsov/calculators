# frozen_string_literal: true

module Everyday
  class GradeCalculator
    attr_reader :errors

    LETTER_GRADES = [
      { min: 97, letter: "A+" },
      { min: 93, letter: "A" },
      { min: 90, letter: "A-" },
      { min: 87, letter: "B+" },
      { min: 83, letter: "B" },
      { min: 80, letter: "B-" },
      { min: 77, letter: "C+" },
      { min: 73, letter: "C" },
      { min: 70, letter: "C-" },
      { min: 67, letter: "D+" },
      { min: 63, letter: "D" },
      { min: 60, letter: "D-" },
      { min: 0,  letter: "F" }
    ].freeze

    def initialize(scores:, weights:)
      @scores_str = scores.to_s
      @weights_str = weights.to_s
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      scores = @scores_str.split(",").map(&:strip).map(&:to_f)
      weights = @weights_str.split(",").map(&:strip).map(&:to_f)

      total_weight = weights.sum
      weighted_sum = scores.zip(weights).sum { |s, w| s * w }
      weighted_average = total_weight.positive? ? weighted_sum / total_weight : 0.0

      letter = letter_grade(weighted_average)

      {
        weighted_average: weighted_average.round(2),
        letter_grade: letter,
        total_weight: total_weight.round(2),
        assignments: scores.zip(weights).map { |s, w| { score: s, weight: w } }
      }
    end

    private

    def letter_grade(average)
      LETTER_GRADES.find { |g| average >= g[:min] }&.fetch(:letter, "F") || "F"
    end

    def validate!
      scores = @scores_str.split(",").map(&:strip)
      weights = @weights_str.split(",").map(&:strip)

      @errors << "Scores cannot be empty" if scores.empty? || scores == [ "" ]
      @errors << "Weights cannot be empty" if weights.empty? || weights == [ "" ]
      return if @errors.any?

      @errors << "Number of scores must match number of weights" if scores.size != weights.size

      negative_scores = scores.select { |s| s.to_f.negative? }
      @errors << "Scores cannot be negative" if negative_scores.any?

      non_positive_weights = weights.select { |w| w.to_f <= 0 }
      @errors << "All weights must be greater than zero" if non_positive_weights.any?
    end
  end
end
