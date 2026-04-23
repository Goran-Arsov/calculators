# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    PHOTOGRAPHY = {
      "depth-of-field-calculator" => %w[exposure-triangle-calculator print-size-dpi-calculator aspect-ratio-crop-calculator],
      "exposure-triangle-calculator" => %w[depth-of-field-calculator golden-hour-calculator lens-optics-calculator],
      "print-size-dpi-calculator" => %w[aspect-ratio-crop-calculator aspect-ratio-calculator depth-of-field-calculator],
      "video-file-size-calculator" => %w[photo-storage-calculator aspect-ratio-crop-calculator bandwidth-calculator],
      "aspect-ratio-crop-calculator" => %w[aspect-ratio-calculator print-size-dpi-calculator depth-of-field-calculator],
      "golden-hour-calculator" => %w[timelapse-interval-calculator exposure-triangle-calculator latitude-longitude-converter],
      "timelapse-interval-calculator" => %w[golden-hour-calculator video-file-size-calculator photo-storage-calculator],
      "photo-storage-calculator" => %w[video-file-size-calculator byte-converter bandwidth-calculator]
    }.freeze
  end
end
