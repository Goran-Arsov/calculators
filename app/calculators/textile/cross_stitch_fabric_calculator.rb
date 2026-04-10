# frozen_string_literal: true

module Textile
  class CrossStitchFabricCalculator
    FABRIC_COUNTS = [
      { count: 11, type: "Aida 11" },
      { count: 14, type: "Aida 14" },
      { count: 16, type: "Aida 16" },
      { count: 18, type: "Aida 18" },
      { count: 20, type: "Aida 20" },
      { count: 22, type: "Aida 22 / Hardanger" },
      { count: 25, type: "Lugana 25" },
      { count: 28, type: "Evenweave 28" },
      { count: 32, type: "Evenweave 32" },
      { count: 36, type: "Evenweave 36" },
      { count: 40, type: "Linen 40" }
    ].freeze

    attr_reader :errors

    def initialize(design_width_st:, design_height_st:, count:, margin_in: 3.0, stitches_over: 1)
      @design_width_st = design_width_st.to_i
      @design_height_st = design_height_st.to_i
      @count = count.to_i
      @margin_in = margin_in.to_f
      @stitches_over = stitches_over.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      effective_count = @count / @stitches_over.to_f

      design_width_in = @design_width_st / effective_count
      design_height_in = @design_height_st / effective_count

      fabric_width_in = design_width_in + (2 * @margin_in)
      fabric_height_in = design_height_in + (2 * @margin_in)

      design_width_cm = design_width_in * 2.54
      design_height_cm = design_height_in * 2.54
      fabric_width_cm = fabric_width_in * 2.54
      fabric_height_cm = fabric_height_in * 2.54

      total_stitches = @design_width_st * @design_height_st

      all_counts = FABRIC_COUNTS.map do |entry|
        eff = entry[:count] / @stitches_over.to_f
        dw = @design_width_st / eff
        dh = @design_height_st / eff
        {
          count: entry[:count],
          type: entry[:type],
          fabric_width_in: (dw + 2 * @margin_in).round(2),
          fabric_height_in: (dh + 2 * @margin_in).round(2)
        }
      end

      {
        valid: true,
        count: @count,
        stitches_over: @stitches_over,
        effective_count: effective_count.round(3),
        design_width_in: design_width_in.round(3),
        design_height_in: design_height_in.round(3),
        design_width_cm: design_width_cm.round(2),
        design_height_cm: design_height_cm.round(2),
        fabric_width_in: fabric_width_in.round(2),
        fabric_height_in: fabric_height_in.round(2),
        fabric_width_cm: fabric_width_cm.round(2),
        fabric_height_cm: fabric_height_cm.round(2),
        total_stitches: total_stitches,
        all_counts: all_counts
      }
    end

    private

    def validate!
      @errors << "Design width must be greater than zero" unless @design_width_st.positive?
      @errors << "Design height must be greater than zero" unless @design_height_st.positive?
      @errors << "Fabric count must be greater than zero" unless @count.positive?
      @errors << "Margin cannot be negative" if @margin_in.negative?
      @errors << "Stitches over must be greater than zero" unless @stitches_over.positive?
    end
  end
end
