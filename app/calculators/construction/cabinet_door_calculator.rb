# frozen_string_literal: true

module Construction
  class CabinetDoorCalculator
    attr_reader :errors

    def initialize(door_width:, door_height:, stile_width: 2.5, rail_width: 2.5,
                   tongue_depth: 0.375, panel_clearance: 0.0625)
      @door_width = door_width.to_f
      @door_height = door_height.to_f
      @stile_width = stile_width.to_f
      @rail_width = rail_width.to_f
      @tongue_depth = tongue_depth.to_f
      @panel_clearance = panel_clearance.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Stiles are the two full-length vertical pieces.
      stile_length = @door_height

      # Rails span between the stiles, plus the tongues on each end seat into
      # the stile grooves.
      rail_length = @door_width - (2 * @stile_width) + (2 * @tongue_depth)

      # The floating panel sits in the grooves with clearance on each side for
      # seasonal wood movement.
      panel_width  = @door_width  - (2 * @stile_width) + (2 * @tongue_depth) - (2 * @panel_clearance)
      panel_height = @door_height - (2 * @rail_width)  + (2 * @tongue_depth) - (2 * @panel_clearance)

      # Rough board-foot approximation assuming 3/4" stock for the frame and
      # 1/2" stock for the panel.
      stiles_bf = 2 * (0.75 * @stile_width * (stile_length / 12.0)) / 12.0
      rails_bf  = 2 * (0.75 * @rail_width  * (rail_length  / 12.0)) / 12.0
      panel_bf  = (0.5 * panel_width * (panel_height / 12.0)) / 12.0
      total_bf  = stiles_bf + rails_bf + panel_bf

      {
        valid: true,
        stile_length: stile_length.round(4),
        stile_width: @stile_width.round(4),
        stile_count: 2,
        rail_length: rail_length.round(4),
        rail_width: @rail_width.round(4),
        rail_count: 2,
        panel_width: panel_width.round(4),
        panel_height: panel_height.round(4),
        total_bf: total_bf.round(3)
      }
    end

    private

    def validate!
      @errors << "Door width must be greater than zero"  unless @door_width.positive?
      @errors << "Door height must be greater than zero" unless @door_height.positive?
      @errors << "Stile width must be greater than zero" unless @stile_width.positive?
      @errors << "Rail width must be greater than zero"  unless @rail_width.positive?
      @errors << "Tongue depth cannot be negative"       if @tongue_depth.negative?
      @errors << "Panel clearance cannot be negative"    if @panel_clearance.negative?

      return if @errors.any?

      if @stile_width * 2 >= @door_width
        @errors << "Stiles are wider than the door — increase door width or reduce stile width"
      end
      if @rail_width * 2 >= @door_height
        @errors << "Rails are taller than the door — increase door height or reduce rail width"
      end
    end
  end
end
