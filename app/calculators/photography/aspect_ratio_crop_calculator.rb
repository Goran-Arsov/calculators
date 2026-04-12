# frozen_string_literal: true

module Photography
  class AspectRatioCropCalculator
    attr_reader :errors

    COMMON_RATIOS = {
      "1:1" => [ 1, 1 ],
      "3:2" => [ 3, 2 ],
      "4:3" => [ 4, 3 ],
      "5:4" => [ 5, 4 ],
      "16:9" => [ 16, 9 ],
      "16:10" => [ 16, 10 ],
      "21:9" => [ 21, 9 ],
      "2:3" => [ 2, 3 ],
      "3:4" => [ 3, 4 ],
      "9:16" => [ 9, 16 ]
    }.freeze

    def initialize(original_width:, original_height:, target_ratio_w:, target_ratio_h:)
      @original_width = original_width.to_f
      @original_height = original_height.to_f
      @target_ratio_w = target_ratio_w.to_f
      @target_ratio_h = target_ratio_h.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      target_ratio = @target_ratio_w / @target_ratio_h
      original_ratio = @original_width / @original_height

      if target_ratio > original_ratio
        # Width-constrained: use full width, crop height
        crop_width = @original_width
        crop_height = @original_width / target_ratio
      else
        # Height-constrained: use full height, crop width
        crop_height = @original_height
        crop_width = @original_height * target_ratio
      end

      crop_width = crop_width.round(0).to_i
      crop_height = crop_height.round(0).to_i

      pixels_removed = (@original_width * @original_height) - (crop_width * crop_height)
      percentage_kept = ((crop_width * crop_height) / (@original_width * @original_height) * 100)

      offset_x = ((@original_width - crop_width) / 2.0).round(0).to_i
      offset_y = ((@original_height - crop_height) / 2.0).round(0).to_i

      {
        valid: true,
        crop_width: crop_width,
        crop_height: crop_height,
        offset_x: offset_x,
        offset_y: offset_y,
        pixels_removed: pixels_removed.round(0).to_i,
        percentage_kept: percentage_kept.round(1),
        original_ratio_display: simplify_ratio(@original_width.to_i, @original_height.to_i),
        target_ratio_display: "#{@target_ratio_w.to_i}:#{@target_ratio_h.to_i}",
        megapixels_after: ((crop_width * crop_height) / 1_000_000.0).round(1)
      }
    end

    private

    def simplify_ratio(w, h)
      g = w.gcd(h)
      "#{w / g}:#{h / g}"
    end

    def validate!
      @errors << "Original width must be positive" unless @original_width > 0
      @errors << "Original height must be positive" unless @original_height > 0
      @errors << "Target ratio width must be positive" unless @target_ratio_w > 0
      @errors << "Target ratio height must be positive" unless @target_ratio_h > 0
    end
  end
end
