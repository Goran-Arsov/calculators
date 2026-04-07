# frozen_string_literal: true

module Everyday
  class ImageResizerCalculator
    attr_reader :errors

    VALID_FORMATS = %w[png jpeg webp].freeze
    MAX_DIMENSION = 10_000
    MIN_DIMENSION = 1

    def initialize(width:, height:, maintain_aspect_ratio: true, format: "png", original_width: nil, original_height: nil, quality: 92)
      @width = width.to_i
      @height = height.to_i
      @maintain_aspect_ratio = ActiveModel::Type::Boolean.new.cast(maintain_aspect_ratio)
      @format = format.to_s.downcase
      @original_width = original_width&.to_i
      @original_height = original_height&.to_i
      @quality = quality.to_i.clamp(1, 100)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      final_width, final_height = compute_dimensions

      {
        valid: true,
        width: final_width,
        height: final_height,
        format: @format,
        quality: @quality,
        maintain_aspect_ratio: @maintain_aspect_ratio,
        original_width: @original_width,
        original_height: @original_height,
        scale_x: @original_width ? (final_width.to_f / @original_width).round(4) : nil,
        scale_y: @original_height ? (final_height.to_f / @original_height).round(4) : nil
      }
    end

    private

    def compute_dimensions
      if @maintain_aspect_ratio && @original_width && @original_height && @original_width > 0 && @original_height > 0
        aspect_ratio = @original_width.to_f / @original_height
        if @width > 0 && @height > 0
          # Fit within both constraints
          if @width.to_f / @height > aspect_ratio
            [ (@height * aspect_ratio).round, @height ]
          else
            [ @width, (@width / aspect_ratio).round ]
          end
        elsif @width > 0
          [ @width, (@width / aspect_ratio).round ]
        elsif @height > 0
          [ (@height * aspect_ratio).round, @height ]
        else
          [ @original_width, @original_height ]
        end
      else
        [ @width, @height ]
      end
    end

    def validate!
      @errors << "Width must be between #{MIN_DIMENSION} and #{MAX_DIMENSION}" if @width < MIN_DIMENSION || @width > MAX_DIMENSION
      @errors << "Height must be between #{MIN_DIMENSION} and #{MAX_DIMENSION}" if @height < MIN_DIMENSION || @height > MAX_DIMENSION
      @errors << "Format must be one of: #{VALID_FORMATS.join(', ')}" unless VALID_FORMATS.include?(@format)
    end
  end
end
