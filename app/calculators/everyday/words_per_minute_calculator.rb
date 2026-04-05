# frozen_string_literal: true

module Everyday
  class WordsPerMinuteCalculator
    attr_reader :errors

    COMMON_LENGTHS = {
      "email" => 200,
      "blog_post" => 1500,
      "report" => 3000,
      "novel_page" => 250,
      "essay" => 2000,
      "thesis" => 20_000
    }.freeze

    AVG_READING_WPM = 238
    AVG_TYPING_WPM = 40

    def initialize(word_count:, time_minutes: 0, time_seconds: 0)
      @word_count = word_count.to_f
      @time_minutes = time_minutes.to_f
      @time_seconds = time_seconds.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      total_minutes = @time_minutes + (@time_seconds / 60.0)
      wpm = @word_count / total_minutes

      estimates = COMMON_LENGTHS.transform_values do |length|
        {
          read_minutes: (length.to_f / AVG_READING_WPM).round(1),
          type_minutes: (length.to_f / wpm).round(1)
        }
      end

      {
        wpm: wpm.round(1),
        total_minutes: total_minutes.round(2),
        word_count: @word_count.round(0),
        characters_per_minute: (wpm * 5).round(0),
        estimates: estimates
      }
    end

    private

    def validate!
      total = @time_minutes + (@time_seconds / 60.0)
      @errors << "Word count must be greater than zero" unless @word_count.positive?
      @errors << "Total time must be greater than zero" unless total.positive?
    end
  end
end
