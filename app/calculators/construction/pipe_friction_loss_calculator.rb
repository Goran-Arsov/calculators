# frozen_string_literal: true

module Construction
  class PipeFrictionLossCalculator
    attr_reader :errors

    # Hazen-Williams C-factor roughness coefficients for common pipe materials.
    # Higher = smoother = less friction loss.
    C_FACTOR = {
      "pvc"      => 150,
      "copper"   => 140,
      "pex"      => 150,
      "steel"    => 120,
      "galvanized" => 100,
      "cast_iron" => 100
    }.freeze

    # Head loss (ft of water) per foot of pipe using Hazen-Williams imperial form:
    #   hf = 4.52 × Q^1.852 / (C^1.852 × d^4.87) × L
    # where Q is gpm, d is inside diameter in inches, L is length in ft.
    # Coefficient 4.52 is the standard imperial constant.
    PSI_PER_FT_WATER = 0.4331

    def initialize(flow_gpm:, diameter_in:, length_ft:, material: "pvc")
      @flow_gpm = flow_gpm.to_f
      @diameter_in = diameter_in.to_f
      @length_ft = length_ft.to_f
      @material = material.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      c = C_FACTOR[@material]
      # Head loss per foot
      hf_per_ft = 4.52 * (@flow_gpm**1.852) / ((c**1.852) * (@diameter_in**4.87))
      head_loss_ft = hf_per_ft * @length_ft
      pressure_loss_psi = head_loss_ft * PSI_PER_FT_WATER
      pressure_loss_per_100ft = pressure_loss_psi / @length_ft * 100.0

      # Velocity (ft/s) = 0.4085 × gpm / d²  where d in inches
      velocity_fps = 0.4085 * @flow_gpm / (@diameter_in**2)
      velocity_ok = velocity_fps <= 8.0 # plumbing best practice

      {
        valid: true,
        c_factor: c,
        head_loss_ft: head_loss_ft.round(3),
        pressure_loss_psi: pressure_loss_psi.round(2),
        pressure_loss_per_100ft_psi: pressure_loss_per_100ft.round(2),
        velocity_fps: velocity_fps.round(2),
        velocity_ok: velocity_ok
      }
    end

    private

    def validate!
      @errors << "Flow must be greater than zero" unless @flow_gpm.positive?
      @errors << "Diameter must be greater than zero" unless @diameter_in.positive?
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Material must be one of #{C_FACTOR.keys.join(', ')}" unless C_FACTOR.key?(@material)
    end
  end
end
