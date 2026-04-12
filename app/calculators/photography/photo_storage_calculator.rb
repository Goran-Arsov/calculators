# frozen_string_literal: true

module Photography
  class PhotoStorageCalculator
    attr_reader :errors

    # Average file sizes by format and megapixel count (MB per photo)
    # These are empirical averages; actual sizes vary by scene complexity
    JPEG_MB_PER_MP = 0.3    # ~0.3 MB per megapixel for high-quality JPEG
    RAW_MB_PER_MP = 1.2     # ~1.2 MB per megapixel for 14-bit RAW
    TIFF_MB_PER_MP = 3.0    # ~3.0 MB per megapixel for 16-bit TIFF
    HEIF_MB_PER_MP = 0.2    # ~0.2 MB per megapixel for HEIF/HEIC

    FORMAT_MULTIPLIERS = {
      "jpeg" => JPEG_MB_PER_MP,
      "raw" => RAW_MB_PER_MP,
      "tiff" => TIFF_MB_PER_MP,
      "heif" => HEIF_MB_PER_MP,
      "raw_jpeg" => nil # handled separately
    }.freeze

    GB_PER_MB = 1024.0
    TB_PER_GB = 1024.0

    def initialize(num_photos:, megapixels:, format: "jpeg")
      @num_photos = num_photos.to_i
      @megapixels = megapixels.to_f
      @format = format.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      per_photo_mb = file_size_per_photo
      total_mb = per_photo_mb * @num_photos
      total_gb = total_mb / GB_PER_MB
      total_tb = total_gb / TB_PER_GB

      # Card/drive capacity estimates
      cards_32gb = (total_gb / 32.0).ceil
      cards_64gb = (total_gb / 64.0).ceil
      cards_128gb = (total_gb / 128.0).ceil

      {
        valid: true,
        per_photo_mb: per_photo_mb.round(1),
        total_mb: total_mb.round(0).to_i,
        total_gb: total_gb.round(2),
        total_tb: total_tb.round(3),
        cards_32gb: cards_32gb,
        cards_64gb: cards_64gb,
        cards_128gb: cards_128gb,
        format_display: format_display_name,
        num_photos: @num_photos,
        megapixels: @megapixels.round(1)
      }
    end

    private

    def file_size_per_photo
      if @format == "raw_jpeg"
        # RAW + JPEG backup
        (@megapixels * RAW_MB_PER_MP) + (@megapixels * JPEG_MB_PER_MP)
      else
        @megapixels * FORMAT_MULTIPLIERS.fetch(@format, JPEG_MB_PER_MP)
      end
    end

    def format_display_name
      {
        "jpeg" => "JPEG",
        "raw" => "RAW",
        "tiff" => "TIFF",
        "heif" => "HEIF/HEIC",
        "raw_jpeg" => "RAW + JPEG"
      }.fetch(@format, @format.upcase)
    end

    def validate!
      @errors << "Number of photos must be positive" unless @num_photos > 0
      @errors << "Megapixels must be positive" unless @megapixels > 0
      @errors << "Megapixels cannot exceed 200" if @megapixels > 200
      @errors << "Unknown format: #{@format}" unless FORMAT_MULTIPLIERS.key?(@format)
    end
  end
end
