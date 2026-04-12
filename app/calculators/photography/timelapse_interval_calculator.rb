# frozen_string_literal: true

module Photography
  class TimelapseIntervalCalculator
    attr_reader :errors

    DEFAULT_PLAYBACK_FPS = 24
    MIN_INTERVAL_SECONDS = 0.5
    MAX_EVENT_DURATION_HOURS = 168 # 1 week

    def initialize(event_duration_minutes:, final_video_seconds:, playback_fps: DEFAULT_PLAYBACK_FPS)
      @event_duration_minutes = event_duration_minutes.to_f
      @final_video_seconds = final_video_seconds.to_f
      @playback_fps = playback_fps.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_frames = (@final_video_seconds * @playback_fps).round(0).to_i
      event_duration_seconds = @event_duration_minutes * 60.0
      interval_seconds = event_duration_seconds / total_frames.to_f

      # Storage estimates (approximate MB per frame for common formats)
      storage_jpeg_mb = total_frames * 8.0   # ~8 MB per JPEG from DSLR
      storage_raw_mb = total_frames * 25.0   # ~25 MB per RAW

      {
        valid: true,
        interval_seconds: interval_seconds.round(1),
        total_frames: total_frames,
        final_video_seconds: @final_video_seconds.round(1),
        final_video_display: format_duration(@final_video_seconds),
        event_duration_display: format_duration(@event_duration_minutes * 60),
        playback_fps: @playback_fps.round(0).to_i,
        speed_factor: (event_duration_seconds / @final_video_seconds).round(1),
        estimated_storage_jpeg_gb: (storage_jpeg_mb / 1024.0).round(1),
        estimated_storage_raw_gb: (storage_raw_mb / 1024.0).round(1)
      }
    end

    private

    def format_duration(total_seconds)
      hours = (total_seconds / 3600).to_i
      minutes = ((total_seconds % 3600) / 60).to_i
      seconds = (total_seconds % 60).to_i

      if hours > 0
        format("%<h>dh %<m>02dm %<s>02ds", h: hours, m: minutes, s: seconds)
      elsif minutes > 0
        format("%<m>dm %<s>02ds", m: minutes, s: seconds)
      else
        "#{seconds}s"
      end
    end

    def validate!
      @errors << "Event duration must be positive" unless @event_duration_minutes > 0
      @errors << "Final video length must be positive" unless @final_video_seconds > 0
      @errors << "Playback FPS must be positive" unless @playback_fps > 0
      @errors << "Event duration cannot exceed #{MAX_EVENT_DURATION_HOURS} hours" if @event_duration_minutes > MAX_EVENT_DURATION_HOURS * 60
      @errors << "Playback FPS must be at most 120" if @playback_fps > 120
    end
  end
end
