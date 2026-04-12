# frozen_string_literal: true

require "open3"
require "securerandom"
require "fileutils"

# Converts an uploaded image to JPG q95, max 2000px on the longest edge,
# and stores it on local disk under storage/photos/.
#
# Returns a saved Photo record on success, or nil if conversion failed.
class PhotoUploader
  MAX_DIMENSION = 2000
  JPG_QUALITY = 95

  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
  end

  def call
    return nil if @uploaded_file.blank?

    filename = "#{Time.current.strftime('%Y%m%d-%H%M%S')}-#{SecureRandom.hex(6)}.jpg"
    output_path = Photo.storage_dir.join(filename)

    cmd = [
      "convert",
      @uploaded_file.tempfile.path,
      "-auto-orient",
      "-strip",
      "-resize", "#{MAX_DIMENSION}x#{MAX_DIMENSION}>",
      "-quality", JPG_QUALITY.to_s,
      output_path.to_s
    ]

    _stdout, stderr, status = Open3.capture3(*cmd)
    unless status.success? && File.exist?(output_path)
      Rails.logger.error("[PhotoUploader] convert failed: #{stderr}")
      File.delete(output_path) if File.exist?(output_path)
      return nil
    end

    width, height = read_dimensions(output_path)

    Photo.create!(
      filename: filename,
      original_filename: @uploaded_file.original_filename,
      byte_size: File.size(output_path),
      width: width,
      height: height,
      jpg_quality: JPG_QUALITY,
      max_dimension: MAX_DIMENSION
    )
  rescue StandardError => e
    Rails.logger.error("[PhotoUploader] error: #{e.class}: #{e.message}")
    File.delete(output_path) if defined?(output_path) && output_path && File.exist?(output_path)
    nil
  end

  private

  def read_dimensions(path)
    stdout, _stderr, status = Open3.capture3("identify", "-format", "%w %h", path.to_s)
    return [ nil, nil ] unless status.success?

    stdout.strip.split.map(&:to_i)
  end
end
