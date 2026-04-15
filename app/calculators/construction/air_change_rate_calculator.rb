# frozen_string_literal: true

module Construction
  class AirChangeRateCalculator
    attr_reader :errors

    # Air changes per hour (ACH) = CFM × 60 ÷ volume (cubic feet).
    # You can invert this to find the required CFM given a target ACH.
    # Both modes are supported via the `mode` argument.
    MODES = %w[find_ach find_cfm find_volume].freeze

    # Typical residential ACH targets (ASHRAE, industry standard).
    RECOMMENDED_ACH = {
      "bedroom"     => 3,
      "living_room" => 3,
      "bathroom"    => 6,
      "kitchen"     => 10,
      "office"      => 4,
      "classroom"   => 6,
      "gym"         => 8,
      "restaurant"  => 10,
      "laundry"     => 8
    }.freeze

    def initialize(mode:, cfm: 0.0, volume_cuft: 0.0, target_ach: 0.0)
      @mode = mode.to_s.downcase
      @cfm = cfm.to_f
      @volume = volume_cuft.to_f
      @target_ach = target_ach.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "find_ach"
        ach = @cfm * 60.0 / @volume
        {
          valid: true, mode: @mode,
          cfm: @cfm.round(1), volume_cuft: @volume.round(1),
          ach: ach.round(2)
        }
      when "find_cfm"
        cfm = @target_ach * @volume / 60.0
        {
          valid: true, mode: @mode,
          target_ach: @target_ach.round(2), volume_cuft: @volume.round(1),
          cfm: cfm.round(1)
        }
      when "find_volume"
        vol = @cfm * 60.0 / @target_ach
        {
          valid: true, mode: @mode,
          cfm: @cfm.round(1), target_ach: @target_ach.round(2),
          volume_cuft: vol.round(1)
        }
      end
    end

    private

    def validate!
      unless MODES.include?(@mode)
        @errors << "Mode must be find_ach, find_cfm, or find_volume"
        return
      end
      case @mode
      when "find_ach"
        @errors << "CFM must be greater than zero" unless @cfm.positive?
        @errors << "Volume must be greater than zero" unless @volume.positive?
      when "find_cfm"
        @errors << "Target ACH must be greater than zero" unless @target_ach.positive?
        @errors << "Volume must be greater than zero" unless @volume.positive?
      when "find_volume"
        @errors << "CFM must be greater than zero" unless @cfm.positive?
        @errors << "Target ACH must be greater than zero" unless @target_ach.positive?
      end
    end
  end
end
