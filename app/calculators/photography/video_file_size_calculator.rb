# frozen_string_literal: true

module Photography
  class VideoFileSizeCalculator
    attr_reader :errors

    # Codec compression efficiency factors (relative to raw)
    CODEC_FACTORS = {
      "h264" => 1.0,
      "h265" => 0.65,
      "prores_422" => 3.5,
      "prores_4444" => 5.0,
      "raw" => 8.0,
      "av1" => 0.55,
      "vp9" => 0.75
    }.freeze

    # Common resolution presets (width x height)
    RESOLUTION_PRESETS = {
      "720p" => { width: 1280, height: 720 },
      "1080p" => { width: 1920, height: 1080 },
      "2k" => { width: 2048, height: 1080 },
      "1440p" => { width: 2560, height: 1440 },
      "4k" => { width: 3840, height: 2160 },
      "6k" => { width: 6144, height: 3456 },
      "8k" => { width: 7680, height: 4320 }
    }.freeze

    BYTES_PER_GB = 1_073_741_824.0
    BYTES_PER_MB = 1_048_576.0
    BITS_PER_BYTE = 8.0

    def initialize(bitrate_mbps:, duration_seconds:, codec: "h264",
                   frame_rate: 30, audio_bitrate_kbps: 320)
      @bitrate_mbps = bitrate_mbps.to_f         # video bitrate in Mbps
      @duration_seconds = duration_seconds.to_f
      @codec = codec.to_s
      @frame_rate = frame_rate.to_f
      @audio_bitrate_kbps = audio_bitrate_kbps.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      video_bits = @bitrate_mbps * 1_000_000.0 * @duration_seconds
      audio_bits = @audio_bitrate_kbps * 1_000.0 * @duration_seconds
      total_bits = video_bits + audio_bits
      total_bytes = total_bits / BITS_PER_BYTE

      size_mb = total_bytes / BYTES_PER_MB
      size_gb = total_bytes / BYTES_PER_GB

      duration_display = format_duration(@duration_seconds)

      {
        valid: true,
        file_size_mb: size_mb.round(1),
        file_size_gb: size_gb.round(2),
        video_size_mb: (video_bits / BITS_PER_BYTE / BYTES_PER_MB).round(1),
        audio_size_mb: (audio_bits / BITS_PER_BYTE / BYTES_PER_MB).round(1),
        duration_display: duration_display,
        total_frames: (@frame_rate * @duration_seconds).round(0).to_i,
        codec: @codec,
        codec_name: codec_display_name
      }
    end

    private

    def codec_display_name
      {
        "h264" => "H.264 (AVC)",
        "h265" => "H.265 (HEVC)",
        "prores_422" => "ProRes 422",
        "prores_4444" => "ProRes 4444",
        "raw" => "RAW / Uncompressed",
        "av1" => "AV1",
        "vp9" => "VP9"
      }.fetch(@codec, @codec)
    end

    def format_duration(seconds)
      hours = (seconds / 3600).to_i
      minutes = ((seconds % 3600) / 60).to_i
      secs = (seconds % 60).to_i

      if hours > 0
        format("%<h>dh %<m>02dm %<s>02ds", h: hours, m: minutes, s: secs)
      elsif minutes > 0
        format("%<m>dm %<s>02ds", m: minutes, s: secs)
      else
        "#{secs}s"
      end
    end

    def validate!
      @errors << "Bitrate must be positive" unless @bitrate_mbps > 0
      @errors << "Duration must be positive" unless @duration_seconds > 0
      @errors << "Frame rate must be positive" unless @frame_rate > 0
      @errors << "Audio bitrate must be non-negative" if @audio_bitrate_kbps < 0
      @errors << "Unknown codec: #{@codec}" unless CODEC_FACTORS.key?(@codec)
    end
  end
end
