# frozen_string_literal: true

module Construction
  class PlywoodSheetsCalculator
    attr_reader :errors

    # Common plywood / OSB sheet sizes in sq ft (width_ft × length_ft).
    SHEET_SIZES = {
      "4x8"  => { width_ft: 4.0,  length_ft: 8.0,  label: "4 × 8 ft (standard)" },
      "4x10" => { width_ft: 4.0,  length_ft: 10.0, label: "4 × 10 ft (long)" },
      "5x10" => { width_ft: 5.0,  length_ft: 10.0, label: "5 × 10 ft (metric-style)" },
      "metric_standard" => { width_ft: 4.0,  length_ft: 8.0, label: "1.22 × 2.44 m (4 × 8 ft)" }
    }.freeze

    def initialize(length_ft:, width_ft:, sheet_type: "4x8", waste_pct: 10.0)
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @sheet_type = sheet_type.to_s
      @waste_pct = waste_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      sheet = SHEET_SIZES[@sheet_type]
      sheet_area_sqft = sheet[:width_ft] * sheet[:length_ft]
      total_area_sqft = @length_ft * @width_ft
      exact_sheets = total_area_sqft / sheet_area_sqft
      # Round before ceil to avoid float drift (e.g. 100 × 1.1 = 110.0000001).
      sheets_with_waste = (exact_sheets * (1 + @waste_pct / 100.0)).round(6).ceil
      full_sheets = exact_sheets.ceil

      {
        valid: true,
        sheet_label: sheet[:label],
        sheet_area_sqft: sheet_area_sqft.round(2),
        total_area_sqft: total_area_sqft.round(2),
        full_sheets: full_sheets,
        sheets_with_waste: sheets_with_waste
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Sheet type must be one of #{SHEET_SIZES.keys.join(', ')}" unless SHEET_SIZES.key?(@sheet_type)
      @errors << "Waste percent cannot be negative" if @waste_pct.negative?
    end
  end
end
