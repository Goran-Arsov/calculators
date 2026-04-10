# frozen_string_literal: true

module Textile
  class FabricShrinkageCalculator
    attr_reader :errors

    def initialize(before_length:, after_length:, before_width:, after_width:, project_size_length: nil, project_size_width: nil)
      @before_length = before_length.to_f
      @after_length = after_length.to_f
      @before_width = before_width.to_f
      @after_width = after_width.to_f
      @project_size_length = project_size_length.nil? || project_size_length.to_s.strip.empty? ? nil : project_size_length.to_f
      @project_size_width = project_size_width.nil? || project_size_width.to_s.strip.empty? ? nil : project_size_width.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      length_shrinkage_pct = ((@before_length - @after_length) / @before_length) * 100.0
      width_shrinkage_pct = ((@before_width - @after_width) / @before_width) * 100.0
      avg_shrinkage_pct = (length_shrinkage_pct + width_shrinkage_pct) / 2.0

      result = {
        valid: true,
        length_shrinkage_pct: length_shrinkage_pct.round(2),
        width_shrinkage_pct: width_shrinkage_pct.round(2),
        avg_shrinkage_pct: avg_shrinkage_pct.round(2),
        classification: classify(avg_shrinkage_pct),
        project_mode: project_mode?
      }

      if project_mode?
        length_factor = 1 - (length_shrinkage_pct / 100.0)
        width_factor = 1 - (width_shrinkage_pct / 100.0)

        if length_factor <= 0 || width_factor <= 0
          @errors << "Shrinkage rate too extreme to compute cut size"
          return { valid: false, errors: @errors }
        end

        cut_length = @project_size_length / length_factor
        cut_width = @project_size_width / width_factor
        extra_length = cut_length - @project_size_length
        extra_width = cut_width - @project_size_width

        result[:cut_length] = cut_length.round(3)
        result[:cut_width] = cut_width.round(3)
        result[:extra_length] = extra_length.round(3)
        result[:extra_width] = extra_width.round(3)
      end

      result
    end

    private

    def project_mode?
      !@project_size_length.nil? && !@project_size_width.nil?
    end

    def classify(avg_pct)
      abs = avg_pct.abs
      if avg_pct < 0
        "Negative shrinkage — fabric stretched when washed"
      elsif abs < 2
        "Minimal shrinkage (likely synthetic or pre-shrunk)"
      elsif abs < 5
        "Low shrinkage (typical for treated cottons)"
      elsif abs < 10
        "Moderate shrinkage (standard untreated cotton)"
      elsif abs < 15
        "High shrinkage (linen, flannel, some wovens)"
      else
        "Very high shrinkage (some knits, unwashed linen, wool)"
      end
    end

    def validate!
      @errors << "Before length must be greater than zero" unless @before_length.positive?
      @errors << "After length must be greater than zero" unless @after_length.positive?
      @errors << "Before width must be greater than zero" unless @before_width.positive?
      @errors << "After width must be greater than zero" unless @after_width.positive?

      if !@project_size_length.nil? && !@project_size_length.positive?
        @errors << "Project length must be greater than zero"
      end
      if !@project_size_width.nil? && !@project_size_width.positive?
        @errors << "Project width must be greater than zero"
      end
    end
  end
end
