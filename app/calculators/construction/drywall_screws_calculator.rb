# frozen_string_literal: true

module Construction
  class DrywallScrewsCalculator
    attr_reader :errors

    # USG / NGC recommended fastener spacing:
    #   Walls with screws:    16" OC stud, 16" OC edges, 24" OC field  → ~32 screws per 4×8 sheet
    #   Walls aggressive:     12" OC edges, 16" OC field               → ~40 per sheet
    #   Ceilings with screws: 12" OC edges, 12" OC field               → ~48 per 4×8 sheet
    #   Adhesive + screws:    screws at top/bottom only                → ~16 per sheet
    SHEET_AREA_SQFT = 32.0 # 4 × 8
    SCREWS_PER_SHEET = {
      "wall_standard" => 32,
      "wall_strict"   => 40,
      "ceiling"       => 48,
      "adhesive"      => 16
    }.freeze

    # Screws per pound for 1-1/4" coarse drywall screws (typical #6).
    SCREWS_PER_POUND = 280

    def initialize(area_sqft:, application: "wall_standard", waste_pct: 15.0)
      @area = area_sqft.to_f
      @application = application.to_s.downcase
      @waste_pct = waste_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      sheets = (@area / SHEET_AREA_SQFT).ceil
      screws_per_sheet = SCREWS_PER_SHEET[@application]
      total_screws = sheets * screws_per_sheet
      total_with_waste = (total_screws * (1 + @waste_pct / 100.0)).round(6).ceil
      pounds = (total_with_waste / SCREWS_PER_POUND.to_f).ceil

      {
        valid: true,
        area_sqft: @area.round(2),
        sheets: sheets,
        screws_per_sheet: screws_per_sheet,
        total_screws: total_screws,
        total_with_waste: total_with_waste,
        pounds_needed: pounds
      }
    end

    private

    def validate!
      @errors << "Area must be greater than zero" unless @area.positive?
      @errors << "Application must be wall_standard, wall_strict, ceiling, or adhesive" unless SCREWS_PER_SHEET.key?(@application)
      @errors << "Waste percent cannot be negative" if @waste_pct.negative?
    end
  end
end
