# frozen_string_literal: true

module Construction
  class BeamLoadSpanCalculator
    attr_reader :errors

    # Allowable bending stress (Fb) in PSI for common beam materials
    MATERIALS = {
      "southern_pine" => { fb_psi: 1500, label: "Southern Pine (No. 2)" },
      "douglas_fir" => { fb_psi: 1350, label: "Douglas Fir-Larch (No. 2)" },
      "spruce" => { fb_psi: 1150, label: "Spruce-Pine-Fir (No. 2)" },
      "lvl" => { fb_psi: 2600, label: "LVL (Laminated Veneer Lumber)" },
      "steel_a36" => { fb_psi: 21_600, label: "Steel A36" }
    }.freeze

    # Common lumber section moduli (in^3)
    LUMBER_SECTIONS = {
      "2x6"  => { width: 1.5, depth: 5.5, section_modulus: 7.56 },
      "2x8"  => { width: 1.5, depth: 7.25, section_modulus: 13.14 },
      "2x10" => { width: 1.5, depth: 9.25, section_modulus: 21.39 },
      "2x12" => { width: 1.5, depth: 11.25, section_modulus: 31.64 },
      "4x6"  => { width: 3.5, depth: 5.5, section_modulus: 17.65 },
      "4x8"  => { width: 3.5, depth: 7.25, section_modulus: 30.66 },
      "4x10" => { width: 3.5, depth: 9.25, section_modulus: 49.91 },
      "4x12" => { width: 3.5, depth: 11.25, section_modulus: 73.83 },
      "6x6"  => { width: 5.5, depth: 5.5, section_modulus: 27.73 },
      "6x8"  => { width: 5.5, depth: 7.5, section_modulus: 51.56 },
      "6x10" => { width: 5.5, depth: 9.5, section_modulus: 82.73 },
      "6x12" => { width: 5.5, depth: 11.5, section_modulus: 121.23 }
    }.freeze

    def initialize(span_ft:, load_plf:, material: "douglas_fir")
      @span_ft = span_ft.to_f
      @load_plf = load_plf.to_f  # pounds per linear foot (total: dead + live)
      @material = material.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      mat = MATERIALS[@material]
      fb = mat[:fb_psi]
      span_in = @span_ft * 12.0

      # Simple beam, uniformly distributed load
      # Max moment M = wL^2 / 8 (w in lb/in, L in inches)
      w_per_in = @load_plf / 12.0
      max_moment_lb_in = (w_per_in * span_in**2) / 8.0

      # Required section modulus S = M / Fb
      required_section_modulus = (max_moment_lb_in / fb).round(2)

      # Find minimum lumber size that works
      recommended_size = nil
      LUMBER_SECTIONS.each do |size, props|
        if props[:section_modulus] >= required_section_modulus
          recommended_size = size
          break
        end
      end

      max_moment_ft_lbs = (max_moment_lb_in / 12.0).round(0)

      {
        valid: true,
        span_ft: @span_ft,
        load_plf: @load_plf,
        material_label: mat[:label],
        allowable_stress_psi: fb,
        max_moment_ft_lbs: max_moment_ft_lbs,
        required_section_modulus: required_section_modulus,
        recommended_size: recommended_size,
        recommended_section_modulus: recommended_size ? LUMBER_SECTIONS[recommended_size][:section_modulus] : nil
      }
    end

    private

    def validate!
      @errors << "Span must be greater than zero" unless @span_ft.positive?
      @errors << "Load must be greater than zero" unless @load_plf.positive?
      @errors << "Invalid material type" unless MATERIALS.key?(@material)
    end
  end
end
