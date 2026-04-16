# frozen_string_literal: true

module Health
  class PaceCalculator
    attr_reader :errors

    MODES = %w[pace time distance].freeze

    def initialize(mode:, distance_km: nil, time_minutes: nil, pace_min_per_km: nil)
      @mode = mode.to_s
      @distance_km = distance_km&.to_f
      @time_minutes = time_minutes&.to_f
      @pace_min_per_km = pace_min_per_km&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = calculate

      {
        valid: true,
        distance_km: result[:distance_km].round(2),
        time_minutes: result[:time_minutes].round(2),
        pace_min_per_km: result[:pace_min_per_km].round(2),
        pace_formatted: format_pace(result[:pace_min_per_km])
      }
    end

    private

    def calculate
      case @mode
      when "pace"
        pace = @time_minutes / @distance_km
        { distance_km: @distance_km, time_minutes: @time_minutes, pace_min_per_km: pace }
      when "time"
        time = @distance_km * @pace_min_per_km
        { distance_km: @distance_km, time_minutes: time, pace_min_per_km: @pace_min_per_km }
      when "distance"
        distance = @time_minutes / @pace_min_per_km
        { distance_km: distance, time_minutes: @time_minutes, pace_min_per_km: @pace_min_per_km }
      end
    end

    def format_pace(pace)
      minutes = pace.floor
      seconds = ((pace - minutes) * 60).round
      if seconds == 60
        minutes += 1
        seconds = 0
      end
      format("%d:%02d /km", minutes, seconds)
    end

    def validate!
      unless MODES.include?(@mode)
        @errors << "Mode must be pace, time, or distance"
        return
      end

      case @mode
      when "pace"
        @errors << "Distance must be positive" if @distance_km.nil? || @distance_km <= 0
        @errors << "Time must be positive" if @time_minutes.nil? || @time_minutes <= 0
      when "time"
        @errors << "Distance must be positive" if @distance_km.nil? || @distance_km <= 0
        @errors << "Pace must be positive" if @pace_min_per_km.nil? || @pace_min_per_km <= 0
      when "distance"
        @errors << "Time must be positive" if @time_minutes.nil? || @time_minutes <= 0
        @errors << "Pace must be positive" if @pace_min_per_km.nil? || @pace_min_per_km <= 0
      end
    end
  end
end
