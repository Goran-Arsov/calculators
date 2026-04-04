# frozen_string_literal: true

module Construction
  class FenceCalculator
    attr_reader :errors

    TALL_FENCE_THRESHOLD_FT = 6
    PICKET_WIDTH_FT = 0.5

    def initialize(total_length_ft:, height_ft: 6, post_spacing_ft: 8)
      @total_length_ft = total_length_ft.to_f
      @height_ft = height_ft.to_f
      @post_spacing_ft = post_spacing_ft.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      sections = (@total_length_ft / @post_spacing_ft).ceil
      posts = sections + 1
      rails_per_section = @height_ft > TALL_FENCE_THRESHOLD_FT ? 3 : 2
      rails = sections * rails_per_section
      pickets = (@total_length_ft / PICKET_WIDTH_FT).ceil

      {
        posts: posts,
        rails: rails,
        pickets: pickets,
        sections: sections
      }
    end

    private

    def validate!
      @errors << "Total length must be greater than zero" unless @total_length_ft.positive?
      @errors << "Height must be greater than zero" unless @height_ft.positive?
      @errors << "Post spacing must be greater than zero" unless @post_spacing_ft.positive?
    end
  end
end
