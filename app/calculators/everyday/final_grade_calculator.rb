# frozen_string_literal: true

module Everyday
  class FinalGradeCalculator
    attr_reader :errors

    LETTER_GRADES = [
      { min: 90, letter: "A" },
      { min: 80, letter: "B" },
      { min: 70, letter: "C" },
      { min: 60, letter: "D" },
      { min: 0,  letter: "F" }
    ].freeze

    def initialize(current_grade_percent:, final_exam_weight_percent:, desired_grade_percent:)
      @current_grade = current_grade_percent.to_f
      @final_weight = final_exam_weight_percent.to_f
      @desired_grade = desired_grade_percent.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      weight_fraction = @final_weight / 100.0
      required_final = (@desired_grade - @current_grade * (1 - weight_fraction)) / weight_fraction
      achievable = required_final <= 100 && required_final >= 0

      {
        valid: true,
        required_final_grade: required_final.round(2),
        is_achievable: achievable,
        letter_grade_needed: letter_grade(required_final),
        current_letter_grade: letter_grade(@current_grade)
      }
    end

    private

    def letter_grade(score)
      LETTER_GRADES.find { |g| score >= g[:min] }&.fetch(:letter, "F") || "F"
    end

    def validate!
      @errors << "Current grade must be between 0 and 100" unless @current_grade.between?(0, 100)
      @errors << "Final exam weight must be between 1 and 100" unless @final_weight.between?(1, 100)
      @errors << "Desired grade must be between 0 and 100" unless @desired_grade.between?(0, 100)
    end
  end
end
