module Automotive
  class TowingCapacityCalculator
    attr_reader :errors

    def initialize(gvwr:, curb_weight:, passengers_weight: 0, cargo_weight: 0, tongue_weight_pct: 10)
      @gvwr = gvwr.to_f
      @curb_weight = curb_weight.to_f
      @passengers_weight = passengers_weight.to_f
      @cargo_weight = cargo_weight.to_f
      @tongue_weight_pct = tongue_weight_pct.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Available payload = GVWR - curb weight
      max_payload = @gvwr - @curb_weight

      # Current payload usage
      current_payload = @passengers_weight + @cargo_weight

      # Remaining payload capacity
      remaining_payload = max_payload - current_payload

      # Maximum towing capacity: remaining payload accounts for tongue weight
      # Tongue weight (the downward force on hitch) is part of payload
      # If tongue weight is 10% of trailer weight, then:
      # tongue_weight = trailer_weight * tongue_weight_pct
      # remaining_payload >= tongue_weight
      # trailer_weight <= remaining_payload / tongue_weight_pct
      max_towing = @tongue_weight_pct > 0 ? remaining_payload / @tongue_weight_pct : 0
      max_towing = [max_towing, 0].max

      # Tongue weight for max towing
      max_tongue_weight = max_towing * @tongue_weight_pct

      # GCWR estimation (gross combined weight rating) ~= GVWR + max towing
      estimated_gcwr = @gvwr + max_towing

      # Safety margin (80% of max)
      safe_towing = max_towing * 0.80

      payload_utilization_pct = max_payload > 0 ? (current_payload / max_payload * 100.0) : 0.0

      {
        valid: true,
        gvwr: @gvwr.round(0),
        curb_weight: @curb_weight.round(0),
        max_payload: max_payload.round(0),
        current_payload: current_payload.round(0),
        remaining_payload: remaining_payload.round(0),
        payload_utilization_pct: payload_utilization_pct.round(1),
        max_towing_capacity: max_towing.round(0),
        safe_towing_capacity: safe_towing.round(0),
        max_tongue_weight: max_tongue_weight.round(0),
        tongue_weight_pct: (@tongue_weight_pct * 100).round(1),
        estimated_gcwr: estimated_gcwr.round(0)
      }
    end

    private

    def validate!
      @errors << "GVWR must be positive" unless @gvwr > 0
      @errors << "Curb weight must be positive" unless @curb_weight > 0
      @errors << "Curb weight cannot exceed GVWR" if @curb_weight >= @gvwr
      @errors << "Passengers weight cannot be negative" if @passengers_weight < 0
      @errors << "Cargo weight cannot be negative" if @cargo_weight < 0
      @errors << "Tongue weight percentage must be between 1 and 25" unless @tongue_weight_pct > 0 && @tongue_weight_pct <= 0.25
    end
  end
end
