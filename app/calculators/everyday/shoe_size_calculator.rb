# frozen_string_literal: true

module Everyday
  class ShoeSizeCalculator
    attr_reader :errors

    SYSTEMS = %w[US UK EU CM].freeze

    # Conversion tables for men's sizes (most universal reference)
    # Each entry: [US, UK, EU, CM]
    SIZE_TABLE = [
      [ 3.5,  3.0,  35.5, 21.6 ],
      [ 4.0,  3.5,  36.0, 22.0 ],
      [ 4.5,  4.0,  36.5, 22.4 ],
      [ 5.0,  4.5,  37.0, 22.8 ],
      [ 5.5,  5.0,  37.5, 23.2 ],
      [ 6.0,  5.5,  38.0, 23.5 ],
      [ 6.5,  6.0,  38.5, 23.8 ],
      [ 7.0,  6.5,  39.0, 24.1 ],
      [ 7.5,  7.0,  40.0, 24.5 ],
      [ 8.0,  7.5,  40.5, 24.8 ],
      [ 8.5,  8.0,  41.0, 25.1 ],
      [ 9.0,  8.5,  42.0, 25.4 ],
      [ 9.5,  9.0,  42.5, 25.7 ],
      [ 10.0, 9.5,  43.0, 26.0 ],
      [ 10.5, 10.0, 43.5, 26.7 ],
      [ 11.0, 10.5, 44.0, 27.0 ],
      [ 11.5, 11.0, 44.5, 27.3 ],
      [ 12.0, 11.5, 45.0, 27.6 ],
      [ 12.5, 12.0, 45.5, 27.9 ],
      [ 13.0, 12.5, 46.0, 28.3 ],
      [ 14.0, 13.5, 47.0, 29.0 ],
      [ 15.0, 14.5, 48.5, 29.7 ]
    ].freeze

    SYSTEM_INDEX = { "US" => 0, "UK" => 1, "EU" => 2, "CM" => 3 }.freeze

    def initialize(size:, system:)
      @size = size.to_f
      @system = system.to_s.upcase.strip
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      idx = SYSTEM_INDEX[@system]
      row = find_closest_row(idx)

      {
        us: row[0],
        uk: row[1],
        eu: row[2],
        cm: row[3],
        source_system: @system,
        source_size: @size
      }
    end

    private

    def find_closest_row(system_idx)
      SIZE_TABLE.min_by { |row| (row[system_idx] - @size).abs }
    end

    def validate!
      @errors << "Size must be greater than zero" unless @size.positive?
      @errors << "Unknown sizing system: #{@system}. Valid: #{SYSTEMS.join(', ')}" unless SYSTEMS.include?(@system)
    end
  end
end
