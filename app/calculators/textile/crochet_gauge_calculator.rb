# frozen_string_literal: true

module Textile
  class CrochetGaugeCalculator
    attr_reader :errors

    CM_PER_INCH = 2.54

    def initialize(stitches_per_4in:, rows_per_4in:, target_width_in:, target_length_in:, starting_chain_extra: 1)
      @stitches_per_4in = stitches_per_4in.to_f
      @rows_per_4in = rows_per_4in.to_f
      @target_width_in = target_width_in.to_f
      @target_length_in = target_length_in.to_f
      @starting_chain_extra = starting_chain_extra.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      stitches_per_inch = @stitches_per_4in / 4.0
      rows_per_inch = @rows_per_4in / 4.0

      stitches_per_10cm = stitches_per_inch * (10.0 / CM_PER_INCH)
      rows_per_10cm = rows_per_inch * (10.0 / CM_PER_INCH)

      base_stitches = (stitches_per_inch * @target_width_in).round
      starting_chain = base_stitches + @starting_chain_extra
      total_rows = (rows_per_inch * @target_length_in).round

      {
        valid: true,
        stitches_per_inch: stitches_per_inch.round(3),
        rows_per_inch: rows_per_inch.round(3),
        stitches_per_10cm: stitches_per_10cm.round(2),
        rows_per_10cm: rows_per_10cm.round(2),
        base_stitches: base_stitches,
        starting_chain: starting_chain,
        total_rows: total_rows
      }
    end

    private

    def validate!
      @errors << "Stitches per 4 inches must be greater than zero" unless @stitches_per_4in.positive?
      @errors << "Rows per 4 inches must be greater than zero" unless @rows_per_4in.positive?
      @errors << "Target width must be greater than zero" unless @target_width_in.positive?
      @errors << "Target length must be greater than zero" unless @target_length_in.positive?
      @errors << "Starting chain extra cannot be negative" if @starting_chain_extra.negative?
    end
  end
end
