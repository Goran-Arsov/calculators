# frozen_string_literal: true

module Everyday
  class StudyTimeCalculator
    attr_reader :errors

    DIFFICULTY_MULTIPLIERS = {
      1 => 1.0,
      2 => 1.5,
      3 => 2.0,
      4 => 2.5,
      5 => 3.0
    }.freeze

    MAX_COURSES = 8

    def initialize(courses:)
      @courses = courses.is_a?(Array) ? courses : []
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      breakdown = @courses.map do |course|
        name = course[:name].to_s.strip
        credits = course[:credits].to_f
        difficulty = course[:difficulty].to_i

        multiplier = DIFFICULTY_MULTIPLIERS.fetch(difficulty, 2.0)
        in_class_hours = credits * 1.0
        study_hours = credits * multiplier
        total_hours = in_class_hours + study_hours

        {
          name: name.empty? ? "Unnamed Course" : name,
          credits: credits,
          difficulty: difficulty,
          in_class_hours: in_class_hours.round(1),
          study_hours: study_hours.round(1),
          total_hours: total_hours.round(1)
        }
      end

      weekly_total = breakdown.sum { |c| c[:total_hours] }
      daily_weekdays = weekly_total / 5.0
      daily_all_days = weekly_total / 7.0

      {
        valid: true,
        weekly_total_hours: weekly_total.round(1),
        per_course_breakdown: breakdown,
        daily_average_weekdays: daily_weekdays.round(1),
        daily_average_all_days: daily_all_days.round(1)
      }
    end

    private

    def validate!
      @errors << "At least one course is required" if @courses.empty?
      @errors << "Maximum of #{MAX_COURSES} courses allowed" if @courses.size > MAX_COURSES

      @courses.each_with_index do |course, i|
        credits = course[:credits].to_f
        difficulty = course[:difficulty].to_i

        @errors << "Course #{i + 1}: credits must be greater than zero" unless credits.positive?
        @errors << "Course #{i + 1}: difficulty must be between 1 and 5" unless difficulty.between?(1, 5)
      end
    end
  end
end
