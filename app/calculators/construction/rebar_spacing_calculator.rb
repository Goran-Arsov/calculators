# frozen_string_literal: true

module Construction
  class RebarSpacingCalculator
    attr_reader :errors

    BAR_SIZES = {
      "#3" => { diameter_in: 0.375, weight_per_ft: 0.376 },
      "#4" => { diameter_in: 0.500, weight_per_ft: 0.668 },
      "#5" => { diameter_in: 0.625, weight_per_ft: 1.043 },
      "#6" => { diameter_in: 0.750, weight_per_ft: 1.502 },
      "#7" => { diameter_in: 0.875, weight_per_ft: 2.044 },
      "#8" => { diameter_in: 1.000, weight_per_ft: 2.670 }
    }.freeze

    OVERLAP_LENGTH_IN = 24
    WASTE_FACTOR = 1.10

    def initialize(length_ft:, width_ft:, spacing_in: 12, bar_size: "#4")
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @spacing_in = spacing_in.to_f
      @bar_size = bar_size.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      bar_info = BAR_SIZES[@bar_size]

      # Bars running along the length (spaced across width)
      bars_along_length = ((@width_ft * 12) / @spacing_in).floor + 1
      # Bars running along the width (spaced across length)
      bars_along_width = ((@length_ft * 12) / @spacing_in).floor + 1

      total_bars = bars_along_length + bars_along_width

      # Linear feet of rebar
      linear_ft_length_bars = bars_along_length * @length_ft
      linear_ft_width_bars = bars_along_width * @width_ft
      total_linear_ft_raw = linear_ft_length_bars + linear_ft_width_bars
      total_linear_ft = (total_linear_ft_raw * WASTE_FACTOR).round(1)

      total_weight_lbs = (total_linear_ft * bar_info[:weight_per_ft]).round(1)

      # Standard rebar sticks are 20 ft
      sticks_20ft = (total_linear_ft / 20.0).ceil

      {
        valid: true,
        bars_along_length: bars_along_length,
        bars_along_width: bars_along_width,
        total_bars: total_bars,
        total_linear_ft: total_linear_ft,
        total_weight_lbs: total_weight_lbs,
        sticks_20ft: sticks_20ft,
        bar_diameter_in: bar_info[:diameter_in],
        bar_weight_per_ft: bar_info[:weight_per_ft]
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Spacing must be greater than zero" unless @spacing_in.positive?
      @errors << "Invalid bar size (use #3 through #8)" unless BAR_SIZES.key?(@bar_size)
    end
  end
end
