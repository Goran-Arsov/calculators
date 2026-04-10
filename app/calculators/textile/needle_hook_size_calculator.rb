# frozen_string_literal: true

module Textile
  class NeedleHookSizeCalculator
    attr_reader :errors

    KNITTING_NEEDLES = [
      { metric_mm: 2.0,  us: "0",    uk: "14" },
      { metric_mm: 2.25, us: "1",    uk: "13" },
      { metric_mm: 2.75, us: "2",    uk: "12" },
      { metric_mm: 3.0,  us: "—",    uk: "11" },
      { metric_mm: 3.25, us: "3",    uk: "10" },
      { metric_mm: 3.5,  us: "4",    uk: "—" },
      { metric_mm: 3.75, us: "5",    uk: "9" },
      { metric_mm: 4.0,  us: "6",    uk: "8" },
      { metric_mm: 4.5,  us: "7",    uk: "7" },
      { metric_mm: 5.0,  us: "8",    uk: "6" },
      { metric_mm: 5.5,  us: "9",    uk: "5" },
      { metric_mm: 6.0,  us: "10",   uk: "4" },
      { metric_mm: 6.5,  us: "10.5", uk: "3" },
      { metric_mm: 7.0,  us: "—",    uk: "2" },
      { metric_mm: 7.5,  us: "—",    uk: "1" },
      { metric_mm: 8.0,  us: "11",   uk: "0" },
      { metric_mm: 9.0,  us: "13",   uk: "00" },
      { metric_mm: 10.0, us: "15",   uk: "000" },
      { metric_mm: 12.0, us: "17",   uk: "—" },
      { metric_mm: 15.0, us: "19",   uk: "—" },
      { metric_mm: 20.0, us: "36",   uk: "—" }
    ].freeze

    CROCHET_HOOKS = [
      { metric_mm: 2.25, us: "B-1" },
      { metric_mm: 2.75, us: "C-2" },
      { metric_mm: 3.25, us: "D-3" },
      { metric_mm: 3.5,  us: "E-4" },
      { metric_mm: 3.75, us: "F-5" },
      { metric_mm: 4.0,  us: "G-6" },
      { metric_mm: 4.5,  us: "7" },
      { metric_mm: 5.0,  us: "H-8" },
      { metric_mm: 5.5,  us: "I-9" },
      { metric_mm: 6.0,  us: "J-10" },
      { metric_mm: 6.5,  us: "K-10.5" },
      { metric_mm: 8.0,  us: "L-11" },
      { metric_mm: 9.0,  us: "M/N-13" },
      { metric_mm: 10.0, us: "N/P-15" },
      { metric_mm: 11.5, us: "P-16" },
      { metric_mm: 15.0, us: "P/Q" },
      { metric_mm: 16.0, us: "Q" },
      { metric_mm: 19.0, us: "S" }
    ].freeze

    VALID_TYPES = %w[knitting crochet].freeze

    def initialize(type:, metric_mm:)
      @type = type.to_s
      @metric_mm = metric_mm.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      table = @type == "knitting" ? KNITTING_NEEDLES : CROCHET_HOOKS
      row = closest_row(table, @metric_mm)

      exact_match = (row[:metric_mm] - @metric_mm).abs <= 0.01

      {
        valid: true,
        type: @type,
        metric_mm: row[:metric_mm],
        us: row[:us],
        uk: row[:uk] || "—",
        exact_match: exact_match
      }
    end

    private

    def closest_row(table, target)
      table.min_by { |r| (r[:metric_mm] - target).abs }
    end

    def validate!
      @errors << "Type must be knitting or crochet" unless VALID_TYPES.include?(@type)
      @errors << "Metric size must be greater than zero" unless @metric_mm.positive?
      @errors << "Metric size must be 30 mm or less" if @metric_mm > 30
    end
  end
end
