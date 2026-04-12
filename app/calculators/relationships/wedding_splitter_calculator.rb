# frozen_string_literal: true

module Relationships
  class WeddingSplitterCalculator
    attr_reader :errors

    TRADITIONAL = {
      brides_family: 0.55,
      grooms_family: 0.15,
      couple: 0.30
    }.freeze

    MODERN = {
      brides_family: 0.25,
      grooms_family: 0.25,
      couple: 0.50
    }.freeze

    EVEN = {
      brides_family: 1.0 / 3,
      grooms_family: 1.0 / 3,
      couple: 1.0 / 3
    }.freeze

    MODES = {
      "traditional" => TRADITIONAL,
      "modern" => MODERN,
      "even" => EVEN
    }.freeze

    def initialize(total_cost:, mode: "modern")
      @total_cost = total_cost.to_f
      @mode = mode.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      split = MODES[@mode]
      breakdown = split.transform_values { |pct| (@total_cost * pct).round(2) }

      {
        valid: true,
        total_cost: @total_cost,
        mode: @mode,
        brides_family: breakdown[:brides_family],
        grooms_family: breakdown[:grooms_family],
        couple: breakdown[:couple]
      }
    end

    private

    def validate!
      @errors << "Total cost must be greater than zero" unless @total_cost.positive?
      @errors << "Split mode is invalid" unless MODES.key?(@mode)
    end
  end
end
