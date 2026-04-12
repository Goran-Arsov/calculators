# frozen_string_literal: true

module Photography
  class DepthOfFieldCalculator
    attr_reader :errors

    SENSOR_COC = {
      "full_frame" => 0.03,
      "apsc_canon" => 0.019,
      "apsc_nikon" => 0.02,
      "micro_four_thirds" => 0.015,
      "medium_format" => 0.043
    }.freeze

    MAX_FOCAL_LENGTH_MM = 2000
    MIN_APERTURE = 0.7
    MAX_APERTURE = 128

    def initialize(focal_length:, aperture:, distance:, sensor_size: "full_frame")
      @focal_length = focal_length.to_f  # mm
      @aperture = aperture.to_f           # f-number
      @distance = distance.to_f           # meters
      @sensor_size = sensor_size.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      coc = circle_of_confusion
      hyperfocal = hyperfocal_distance(coc)
      near = near_limit(hyperfocal)
      far = far_limit(hyperfocal)
      dof = far == Float::INFINITY ? Float::INFINITY : far - near

      {
        valid: true,
        depth_of_field: dof == Float::INFINITY ? "Infinite" : (dof * 1000).round(1),
        near_limit: (near * 1000).round(1),
        far_limit: far == Float::INFINITY ? "Infinite" : (far * 1000).round(1),
        hyperfocal: (hyperfocal * 1000).round(1),
        unit: "mm"
      }
    end

    private

    def circle_of_confusion
      SENSOR_COC.fetch(@sensor_size, 0.03)
    end

    # H = f^2 / (N * c) + f  (all in mm, result converted to meters)
    def hyperfocal_distance(coc)
      ((@focal_length**2) / (@aperture * coc) + @focal_length) / 1000.0
    end

    # D_n = (H * s) / (H + (s - f))
    def near_limit(hyperfocal)
      s = @distance
      f = @focal_length / 1000.0
      (hyperfocal * s) / (hyperfocal + (s - f))
    end

    # D_f = (H * s) / (H - (s - f))
    def far_limit(hyperfocal)
      s = @distance
      f = @focal_length / 1000.0
      denominator = hyperfocal - (s - f)
      denominator <= 0 ? Float::INFINITY : (hyperfocal * s) / denominator
    end

    def validate!
      @errors << "Focal length must be positive" unless @focal_length > 0
      @errors << "Aperture must be positive" unless @aperture > 0
      @errors << "Distance must be positive" unless @distance > 0
      @errors << "Focal length cannot exceed #{MAX_FOCAL_LENGTH_MM}mm" if @focal_length > MAX_FOCAL_LENGTH_MM
      @errors << "Aperture must be between #{MIN_APERTURE} and #{MAX_APERTURE}" unless @aperture.between?(MIN_APERTURE, MAX_APERTURE)
    end
  end
end
