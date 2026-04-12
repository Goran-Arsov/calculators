# frozen_string_literal: true

module Construction
  class SolarPanelLayoutCalculator
    attr_reader :errors

    PANEL_WIDTH_M = 1.0
    PANEL_HEIGHT_M = 1.7
    PANEL_WATTAGE = 400
    EFFICIENCY_FACTOR = 0.80
    DAYS_PER_YEAR = 365

    def initialize(roof_length_m:, roof_width_m:, peak_sun_hours: 5.0, panel_orientation: "portrait")
      @roof_length_m = roof_length_m.to_f
      @roof_width_m = roof_width_m.to_f
      @peak_sun_hours = peak_sun_hours.to_f
      @panel_orientation = panel_orientation.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @panel_orientation == "landscape"
        panel_w = PANEL_HEIGHT_M
        panel_h = PANEL_WIDTH_M
      else
        panel_w = PANEL_WIDTH_M
        panel_h = PANEL_HEIGHT_M
      end

      panels_along_length = (@roof_length_m / panel_w).floor
      panels_along_width = (@roof_width_m / panel_h).floor
      total_panels = panels_along_length * panels_along_width

      capacity_kw = (total_panels * PANEL_WATTAGE / 1000.0).round(2)
      annual_kwh = (capacity_kw * @peak_sun_hours * DAYS_PER_YEAR * EFFICIENCY_FACTOR).round(0)

      panel_area_m2 = (total_panels * PANEL_WIDTH_M * PANEL_HEIGHT_M).round(2)
      roof_area_m2 = (@roof_length_m * @roof_width_m).round(2)
      coverage_pct = roof_area_m2.positive? ? ((panel_area_m2 / roof_area_m2) * 100).round(1) : 0.0

      {
        valid: true,
        panels_along_length: panels_along_length,
        panels_along_width: panels_along_width,
        total_panels: total_panels,
        capacity_kw: capacity_kw,
        annual_kwh: annual_kwh,
        panel_area_m2: panel_area_m2,
        roof_area_m2: roof_area_m2,
        coverage_pct: coverage_pct
      }
    end

    private

    def validate!
      @errors << "Roof length must be greater than zero" unless @roof_length_m.positive?
      @errors << "Roof width must be greater than zero" unless @roof_width_m.positive?
      @errors << "Peak sun hours must be greater than zero" unless @peak_sun_hours.positive?
      @errors << "Panel orientation must be portrait or landscape" unless %w[portrait landscape].include?(@panel_orientation)
    end
  end
end
