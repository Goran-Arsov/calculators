# frozen_string_literal: true

module Construction
  class WindowUValueCalculator
    attr_reader :errors

    # U-values for glass types (W/m2K) - center of glass
    GLASS_TYPES = {
      "single" => { u_value: 5.7, label: "Single Pane" },
      "double" => { u_value: 2.8, label: "Double Pane (air)" },
      "double_argon" => { u_value: 2.0, label: "Double Pane (argon)" },
      "double_low_e" => { u_value: 1.6, label: "Double Pane Low-E (air)" },
      "double_low_e_argon" => { u_value: 1.1, label: "Double Pane Low-E (argon)" },
      "triple" => { u_value: 1.0, label: "Triple Pane (air)" },
      "triple_argon" => { u_value: 0.7, label: "Triple Pane (argon)" },
      "triple_low_e_argon" => { u_value: 0.5, label: "Triple Pane Low-E (argon)" }
    }.freeze

    # Frame conductance adjustment (U-value added)
    FRAME_TYPES = {
      "aluminum" => { u_adjustment: 1.2, label: "Aluminum (no break)" },
      "aluminum_break" => { u_adjustment: 0.6, label: "Aluminum (thermal break)" },
      "vinyl" => { u_adjustment: 0.3, label: "Vinyl / PVC" },
      "wood" => { u_adjustment: 0.2, label: "Wood" },
      "fiberglass" => { u_adjustment: 0.25, label: "Fiberglass" }
    }.freeze

    FRAME_PERCENTAGE_DEFAULT = 0.20  # Frame is ~20% of total window area

    def initialize(glass_type:, frame_type: "vinyl", frame_percentage: 20)
      @glass_type = glass_type.to_s.downcase
      @frame_type = frame_type.to_s.downcase
      @frame_percentage = frame_percentage.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      glass = GLASS_TYPES[@glass_type]
      frame = FRAME_TYPES[@frame_type]

      glass_u = glass[:u_value]
      frame_u = frame[:u_adjustment] + glass_u * 0.5  # Simplified frame edge effect

      # Area-weighted whole window U-value
      glass_fraction = 1.0 - @frame_percentage
      whole_window_u = (glass_u * glass_fraction) + (frame_u * @frame_percentage)
      whole_window_u = whole_window_u.round(2)

      # R-value = 1/U (m2K/W)
      r_value_metric = whole_window_u.positive? ? (1.0 / whole_window_u).round(2) : 0.0

      # Convert to imperial R-value (ft2*F*h/BTU) = metric R * 5.678
      r_value_imperial = (r_value_metric * 5.678).round(2)

      # SHGC estimate based on glass type
      shgc = estimate_shgc

      # Energy Star qualification (U <= 0.30 BTU/h*ft2*F for most US zones)
      u_imperial = (whole_window_u / 5.678).round(3)
      energy_star_qualified = u_imperial <= 0.30

      {
        valid: true,
        glass_type_label: glass[:label],
        frame_type_label: frame[:label],
        glass_center_u: glass_u,
        whole_window_u: whole_window_u,
        r_value_metric: r_value_metric,
        r_value_imperial: r_value_imperial,
        u_imperial: u_imperial,
        shgc: shgc,
        energy_star_qualified: energy_star_qualified
      }
    end

    private

    def validate!
      @errors << "Invalid glass type" unless GLASS_TYPES.key?(@glass_type)
      @errors << "Invalid frame type" unless FRAME_TYPES.key?(@frame_type)
      @errors << "Frame percentage must be between 1 and 50" unless @frame_percentage.between?(0.01, 0.50)
    end

    def estimate_shgc
      case @glass_type
      when "single" then 0.86
      when "double" then 0.76
      when "double_argon" then 0.73
      when "double_low_e", "double_low_e_argon" then 0.40
      when "triple" then 0.68
      when "triple_argon" then 0.65
      when "triple_low_e_argon" then 0.27
      else 0.50
      end
    end
  end
end
