# frozen_string_literal: true

module Physics
  class LensOpticsCalculator
    attr_reader :errors

    VALID_MODES = %w[find_image find_focal find_object].freeze

    def initialize(mode:, focal_length: nil, object_distance: nil, image_distance: nil)
      @mode = mode.to_s.downcase.strip
      @focal_length = focal_length.present? ? focal_length.to_f : nil
      @object_distance = object_distance.present? ? object_distance.to_f : nil
      @image_distance = image_distance.present? ? image_distance.to_f : nil
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "find_image"
        calculate_image_distance
      when "find_focal"
        calculate_focal_length
      when "find_object"
        calculate_object_distance
      end
    end

    private

    def calculate_image_distance
      # 1/f = 1/do + 1/di => 1/di = 1/f - 1/do => di = 1/(1/f - 1/do)
      inv_di = (1.0 / @focal_length) - (1.0 / @object_distance)

      if inv_di == 0
        @errors << "Image forms at infinity (object is at focal point)"
        return { valid: false, errors: @errors }
      end

      di = 1.0 / inv_di
      magnification = -di / @object_distance

      build_result(
        focal_length: @focal_length,
        object_distance: @object_distance,
        image_distance: di,
        magnification: magnification
      )
    end

    def calculate_focal_length
      # 1/f = 1/do + 1/di => f = 1/(1/do + 1/di)
      inv_f = (1.0 / @object_distance) + (1.0 / @image_distance)

      if inv_f == 0
        @errors << "Focal length is infinite with the given distances"
        return { valid: false, errors: @errors }
      end

      f = 1.0 / inv_f
      magnification = -@image_distance / @object_distance

      build_result(
        focal_length: f,
        object_distance: @object_distance,
        image_distance: @image_distance,
        magnification: magnification
      )
    end

    def calculate_object_distance
      # 1/f = 1/do + 1/di => 1/do = 1/f - 1/di => do = 1/(1/f - 1/di)
      inv_do = (1.0 / @focal_length) - (1.0 / @image_distance)

      if inv_do == 0
        @errors << "Object distance is infinite (image is at focal point)"
        return { valid: false, errors: @errors }
      end

      do_val = 1.0 / inv_do
      magnification = -@image_distance / do_val

      build_result(
        focal_length: @focal_length,
        object_distance: do_val,
        image_distance: @image_distance,
        magnification: magnification
      )
    end

    def build_result(focal_length:, object_distance:, image_distance:, magnification:)
      real_image = image_distance > 0
      upright = magnification > 0
      abs_mag = magnification.abs

      image_type = if real_image
                     "Real (forms on opposite side of lens)"
      else
                     "Virtual (forms on same side as object)"
      end

      orientation = upright ? "Upright" : "Inverted"

      size_description = if abs_mag > 1.001
                           "Enlarged (#{abs_mag.round(2)}x)"
      elsif abs_mag < 0.999
                           "Reduced (#{abs_mag.round(2)}x)"
      else
                           "Same size (1x)"
      end

      lens_type = focal_length > 0 ? "Converging (convex)" : "Diverging (concave)"

      {
        valid: true,
        mode: @mode,
        focal_length_cm: focal_length.round(4),
        object_distance_cm: object_distance.round(4),
        image_distance_cm: image_distance.round(4),
        magnification: magnification.round(4),
        absolute_magnification: abs_mag.round(4),
        image_type: image_type,
        orientation: orientation,
        size_description: size_description,
        lens_type: lens_type,
        real_image: real_image
      }
    end

    def validate!
      unless VALID_MODES.include?(@mode)
        @errors << "Mode must be 'find_image', 'find_focal', or 'find_object'"
        return
      end

      case @mode
      when "find_image"
        validate_presence(:focal_length, @focal_length, "Focal length")
        validate_presence(:object_distance, @object_distance, "Object distance")
        validate_nonzero(@focal_length, "Focal length") if @focal_length
        validate_nonzero(@object_distance, "Object distance") if @object_distance
      when "find_focal"
        validate_presence(:object_distance, @object_distance, "Object distance")
        validate_presence(:image_distance, @image_distance, "Image distance")
        validate_nonzero(@object_distance, "Object distance") if @object_distance
        validate_nonzero(@image_distance, "Image distance") if @image_distance
      when "find_object"
        validate_presence(:focal_length, @focal_length, "Focal length")
        validate_presence(:image_distance, @image_distance, "Image distance")
        validate_nonzero(@focal_length, "Focal length") if @focal_length
        validate_nonzero(@image_distance, "Image distance") if @image_distance
      end
    end

    def validate_presence(_field, value, label)
      @errors << "#{label} is required" if value.nil?
    end

    def validate_nonzero(value, label)
      @errors << "#{label} must be non-zero" if value == 0
    end
  end
end
