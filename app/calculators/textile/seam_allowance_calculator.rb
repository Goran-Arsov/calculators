# frozen_string_literal: true

module Textile
  class SeamAllowanceCalculator
    attr_reader :errors

    COMMON_SA_TABLE = {
      "1/4\"" => 0.635,
      "3/8\"" => 0.9525,
      "1/2\"" => 1.27,
      "5/8\"" => 1.5875,
      "1 cm" => 0.3937,
      "1.5 cm" => 0.5906
    }.freeze

    VALID_UNITS = %w[in cm].freeze
    VALID_SEAMS_PER_EDGE = [0, 1, 2].freeze

    def initialize(finished_size:, seam_allowance:, unit: "in", seams_per_edge: 2)
      @finished_size = finished_size.to_f
      @seam_allowance = seam_allowance.to_f
      @unit = unit.to_s
      @seams_per_edge = seams_per_edge.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_sa = @seam_allowance * @seams_per_edge
      cut_size = @finished_size + total_sa

      if @unit == "in"
        cut_size_in = cut_size
        cut_size_cm = cut_size * 2.54
        sa_in = @seam_allowance
        sa_cm = @seam_allowance * 2.54
      else
        cut_size_cm = cut_size
        cut_size_in = cut_size / 2.54
        sa_cm = @seam_allowance
        sa_in = @seam_allowance / 2.54
      end

      {
        valid: true,
        unit: @unit,
        finished_size: @finished_size,
        seam_allowance: @seam_allowance,
        seams_per_edge: @seams_per_edge,
        total_sa: total_sa.round(4),
        cut_size: cut_size.round(4),
        cut_size_in: cut_size_in.round(4),
        cut_size_cm: cut_size_cm.round(4),
        sa_in: sa_in.round(4),
        sa_cm: sa_cm.round(4),
        common_sa_table: COMMON_SA_TABLE
      }
    end

    private

    def validate!
      @errors << "Finished size must be greater than zero" unless @finished_size.positive?
      @errors << "Seam allowance cannot be negative" if @seam_allowance.negative?
      @errors << "Unit must be \"in\" or \"cm\"" unless VALID_UNITS.include?(@unit)
      @errors << "Seams per edge must be 0, 1, or 2" unless VALID_SEAMS_PER_EDGE.include?(@seams_per_edge)
    end
  end
end
