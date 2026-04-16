# frozen_string_literal: true

module Health
  class Vo2MaxCalculator
    attr_reader :errors

    FITNESS_TABLE = {
      "male" => {
        13..19 => { poor: 0...35.0, below_average: 35.0...38.4, average: 38.4...45.2, above_average: 45.2...50.9, good: 50.9...55.9, excellent: 55.9...60.0, superior: 60.0..Float::INFINITY },
        20..29 => { poor: 0...33.0, below_average: 33.0...36.5, average: 36.5...42.4, above_average: 42.4...46.4, good: 46.4...52.4, excellent: 52.4...56.0, superior: 56.0..Float::INFINITY },
        30..39 => { poor: 0...31.5, below_average: 31.5...35.5, average: 35.5...40.9, above_average: 40.9...44.9, good: 44.9...49.4, excellent: 49.4...54.0, superior: 54.0..Float::INFINITY },
        40..49 => { poor: 0...30.2, below_average: 30.2...33.6, average: 33.6...38.9, above_average: 38.9...43.7, good: 43.7...48.0, excellent: 48.0...52.0, superior: 52.0..Float::INFINITY },
        50..59 => { poor: 0...26.1, below_average: 26.1...30.2, average: 30.2...35.7, above_average: 35.7...40.9, good: 40.9...45.3, excellent: 45.3...49.0, superior: 49.0..Float::INFINITY },
        60..150 => { poor: 0...20.5, below_average: 20.5...26.1, average: 26.1...32.2, above_average: 32.2...36.4, good: 36.4...44.2, excellent: 44.2...48.0, superior: 48.0..Float::INFINITY }
      },
      "female" => {
        13..19 => { poor: 0...25.0, below_average: 25.0...31.0, average: 31.0...35.0, above_average: 35.0...38.9, good: 38.9...41.9, excellent: 41.9...45.0, superior: 45.0..Float::INFINITY },
        20..29 => { poor: 0...23.6, below_average: 23.6...28.9, average: 28.9...32.9, above_average: 32.9...36.9, good: 36.9...41.0, excellent: 41.0...44.0, superior: 44.0..Float::INFINITY },
        30..39 => { poor: 0...22.8, below_average: 22.8...27.0, average: 27.0...31.4, above_average: 31.4...35.6, good: 35.6...40.0, excellent: 40.0...43.0, superior: 43.0..Float::INFINITY },
        40..49 => { poor: 0...21.0, below_average: 21.0...24.5, average: 24.5...28.9, above_average: 28.9...32.8, good: 32.8...36.9, excellent: 36.9...41.0, superior: 41.0..Float::INFINITY },
        50..59 => { poor: 0...20.2, below_average: 20.2...22.8, average: 22.8...26.9, above_average: 26.9...31.4, good: 31.4...35.7, excellent: 35.7...38.0, superior: 38.0..Float::INFINITY },
        60..150 => { poor: 0...17.5, below_average: 17.5...20.2, average: 20.2...24.4, above_average: 24.4...30.2, good: 30.2...31.4, excellent: 31.4...35.0, superior: 35.0..Float::INFINITY }
      }
    }.freeze

    PERCENTILE_MAP = {
      "poor" => 10,
      "below_average" => 25,
      "average" => 50,
      "above_average" => 65,
      "good" => 75,
      "excellent" => 90,
      "superior" => 97
    }.freeze

    def initialize(test_type:, distance_meters: nil, time_minutes: nil, age:, gender:)
      @test_type = test_type.to_s
      @distance_meters = distance_meters&.to_f
      @time_minutes = time_minutes&.to_f
      @age = age.to_i
      @gender = gender.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      vo2_max = calculate_vo2_max
      fitness_level = determine_fitness_level(vo2_max)
      percentile = PERCENTILE_MAP[fitness_level] || 50

      {
        valid: true,
        vo2_max: vo2_max.round(1),
        fitness_level: fitness_level,
        percentile_estimate: percentile
      }
    end

    private

    def calculate_vo2_max
      case @test_type
      when "cooper_12min"
        (@distance_meters - 504.9) / 44.73
      when "1_5_mile_run"
        483.0 / @time_minutes + 3.5
      end
    end

    def determine_fitness_level(vo2_max)
      gender_table = FITNESS_TABLE[@gender]
      return "average" unless gender_table

      age_ranges = gender_table.find { |range, _| range.include?(@age) }
      return "average" unless age_ranges

      levels = age_ranges[1]
      levels.each do |level, range|
        return level.to_s if range.include?(vo2_max)
      end

      "superior"
    end

    def validate!
      valid_test_types = %w[cooper_12min 1_5_mile_run]
      @errors << "Invalid test type" unless valid_test_types.include?(@test_type)
      @errors << "Gender must be male or female" unless %w[male female].include?(@gender)
      @errors << "Age must be between 13 and 150" unless @age >= 13 && @age <= 150

      if @test_type == "cooper_12min"
        @errors << "Distance must be positive" unless @distance_meters && @distance_meters > 0
        @errors << "Distance cannot exceed 10000 meters" if @distance_meters && @distance_meters > 10_000
      elsif @test_type == "1_5_mile_run"
        @errors << "Time must be positive" unless @time_minutes && @time_minutes > 0
        @errors << "Time cannot exceed 60 minutes" if @time_minutes && @time_minutes > 60
      end
    end
  end
end
