# frozen_string_literal: true

module Construction
  class GutterCalculator
    attr_reader :errors

    # IRC appendix and gutter manufacturer tables:
    # 5-inch K-style: 1 downspout per 35 linear feet max
    # 6-inch K-style: 1 downspout per 50 linear feet max
    GUTTER_SIZES = {
      "5_inch" => { label: "5-inch K-style", downspout_spacing: 35.0 },
      "6_inch" => { label: "6-inch K-style", downspout_spacing: 50.0 },
      "7_inch" => { label: "7-inch K-style", downspout_spacing: 60.0 }
    }.freeze

    def initialize(eave_lengths_ft:, gutter_size: "5_inch", price_per_foot: nil,
                   downspout_length_ft: 10.0)
      @eave_lengths_ft = Array(eave_lengths_ft).map(&:to_f).reject(&:zero?)
      @gutter_size = gutter_size.to_s
      @price_per_foot = price_per_foot.to_f if price_per_foot && price_per_foot.to_s != ""
      @downspout_length_ft = downspout_length_ft.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      size = GUTTER_SIZES[@gutter_size]
      total_feet = @eave_lengths_ft.sum
      downspouts = @eave_lengths_ft.sum { |len| [ (len / size[:downspout_spacing]).ceil, 1 ].max }
      downspout_feet = downspouts * @downspout_length_ft
      total_cost = @price_per_foot ? (total_feet + downspout_feet) * @price_per_foot : nil

      {
        valid: true,
        gutter_size_label: size[:label],
        total_gutter_feet: total_feet.round(2),
        downspout_count: downspouts,
        downspout_feet: downspout_feet.round(2),
        total_material_feet: (total_feet + downspout_feet).round(2),
        total_cost: total_cost&.round(2)
      }
    end

    private

    def validate!
      @errors << "At least one eave length is required" if @eave_lengths_ft.empty?
      unless GUTTER_SIZES.key?(@gutter_size)
        @errors << "Gutter size must be one of: #{GUTTER_SIZES.keys.join(', ')}"
      end
      @errors << "Downspout length must be positive" unless @downspout_length_ft.positive?
      @errors << "All eave lengths must be positive" if @eave_lengths_ft.any?(&:negative?)
    end
  end
end
