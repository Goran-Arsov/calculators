# frozen_string_literal: true

module Everyday
  class GpaCalculator
    attr_reader :errors

    GRADE_POINTS = {
      "A"  => 4.0,
      "A-" => 3.7,
      "B+" => 3.3,
      "B"  => 3.0,
      "B-" => 2.7,
      "C+" => 2.3,
      "C"  => 2.0,
      "C-" => 1.7,
      "D+" => 1.3,
      "D"  => 1.0,
      "F"  => 0.0
    }.freeze

    def initialize(grades:, credits:)
      @grades_str = grades.to_s
      @credits_str = credits.to_s
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      grades = @grades_str.split(",").map(&:strip).map(&:upcase)
      credits = @credits_str.split(",").map(&:strip).map(&:to_f)

      total_quality_points = 0.0
      total_credits = 0.0

      grades.each_with_index do |grade, i|
        credit = credits[i]
        total_quality_points += GRADE_POINTS[grade] * credit
        total_credits += credit
      end

      gpa = total_credits.positive? ? (total_quality_points / total_credits) : 0.0

      {
        gpa: gpa.round(2),
        total_credits: total_credits.round(1),
        total_quality_points: total_quality_points.round(2)
      }
    end

    private

    def validate!
      grades = @grades_str.split(",").map(&:strip).map(&:upcase)
      credits = @credits_str.split(",").map(&:strip)

      @errors << "Grades cannot be empty" if grades.empty?
      @errors << "Credits cannot be empty" if credits.empty?
      @errors << "Number of grades must match number of credits" if grades.size != credits.size

      invalid_grades = grades.reject { |g| GRADE_POINTS.key?(g) }
      @errors << "Invalid grades: #{invalid_grades.join(', ')}" if invalid_grades.any?

      invalid_credits = credits.select { |c| c.to_f <= 0 }
      @errors << "All credits must be greater than zero" if invalid_credits.any?
    end
  end
end
