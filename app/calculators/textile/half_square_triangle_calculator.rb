# frozen_string_literal: true

module Textile
  class HalfSquareTriangleCalculator
    attr_reader :errors

    METHODS = %w[2_at_a_time 4_at_a_time 8_at_a_time].freeze

    METHOD_DESCRIPTIONS = {
      "2_at_a_time" => "Two at a time — cut squares and sew on both sides of the diagonal",
      "4_at_a_time" => "Four at a time — sew around all four sides, cut both diagonals",
      "8_at_a_time" => "Eight at a time — mark a grid, sew, and cut into eight HSTs"
    }.freeze

    HSTS_PER_PAIR = {
      "2_at_a_time" => 2,
      "4_at_a_time" => 4,
      "8_at_a_time" => 8
    }.freeze

    def initialize(finished_size_in:, method: "2_at_a_time")
      @finished_size_in = finished_size_in.to_f
      @method = method.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      all_methods = {
        "2_at_a_time" => cut_size_for("2_at_a_time"),
        "4_at_a_time" => cut_size_for("4_at_a_time"),
        "8_at_a_time" => cut_size_for("8_at_a_time")
      }

      cut = all_methods[@method]

      {
        valid: true,
        finished_size_in: @finished_size_in,
        method: @method,
        method_description: METHOD_DESCRIPTIONS[@method],
        cut_size_in: cut.round(4),
        cut_size_fraction: to_eighth_fraction(cut),
        num_hsts_per_pair: HSTS_PER_PAIR[@method],
        all_methods: {
          "2_at_a_time" => {
            cut_size_in: all_methods["2_at_a_time"].round(4),
            cut_size_fraction: to_eighth_fraction(all_methods["2_at_a_time"]),
            num_hsts_per_pair: 2
          },
          "4_at_a_time" => {
            cut_size_in: all_methods["4_at_a_time"].round(4),
            cut_size_fraction: to_eighth_fraction(all_methods["4_at_a_time"]),
            num_hsts_per_pair: 4
          },
          "8_at_a_time" => {
            cut_size_in: all_methods["8_at_a_time"].round(4),
            cut_size_fraction: to_eighth_fraction(all_methods["8_at_a_time"]),
            num_hsts_per_pair: 8
          }
        }
      }
    end

    private

    def cut_size_for(method)
      case method
      when "2_at_a_time"
        @finished_size_in + (7.0 / 8.0)
      when "4_at_a_time"
        (@finished_size_in * Math.sqrt(2)) + 1.25
      when "8_at_a_time"
        (@finished_size_in * 2) + 1.75
      end
    end

    # Convert a decimal inch value to a mixed fraction rounded to the nearest 1/8.
    # Examples: 3.875 → "3 7/8\"", 5.0 → "5\"", 4.125 → "4 1/8\""
    def to_eighth_fraction(value)
      rounded = (value * 8).round / 8.0
      whole = rounded.to_i
      fractional = rounded - whole

      # Handle rounding that pushes fractional to 1.0
      if fractional >= 1.0
        whole += 1
        fractional = 0.0
      end

      eighths = (fractional * 8).round

      fraction_map = {
        0 => nil,
        1 => "1/8",
        2 => "1/4",
        3 => "3/8",
        4 => "1/2",
        5 => "5/8",
        6 => "3/4",
        7 => "7/8"
      }

      frac_str = fraction_map[eighths]

      if frac_str.nil?
        "#{whole}\""
      elsif whole.zero?
        "#{frac_str}\""
      else
        "#{whole} #{frac_str}\""
      end
    end

    def validate!
      @errors << "Finished size must be greater than zero" unless @finished_size_in.positive?
      @errors << "Method must be 2_at_a_time, 4_at_a_time, or 8_at_a_time" unless METHODS.include?(@method)
    end
  end
end
