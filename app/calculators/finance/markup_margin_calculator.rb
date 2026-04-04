module Finance
  class MarkupMarginCalculator
    attr_reader :errors

    MODES = %w[markup_to_margin margin_to_markup].freeze

    def initialize(mode:, value:)
      @mode = mode.to_s
      @value = value.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @mode == "markup_to_margin"
        markup = @value
        margin = (markup / (100.0 + markup)) * 100.0

        {
          valid: true,
          markup: markup.round(4),
          margin: margin.round(4),
          mode: @mode
        }
      else
        margin = @value
        markup = (margin / (100.0 - margin)) * 100.0

        {
          valid: true,
          markup: markup.round(4),
          margin: margin.round(4),
          mode: @mode
        }
      end
    end

    private

    def validate!
      @errors << "Mode must be markup_to_margin or margin_to_markup" unless MODES.include?(@mode)

      if @mode == "markup_to_margin"
        @errors << "Markup percentage must be greater than -100%" unless @value > -100.0
      elsif @mode == "margin_to_markup"
        @errors << "Margin percentage must be less than 100%" if @value >= 100.0
        @errors << "Margin percentage must be greater than -100%" unless @value > -100.0
      end
    end
  end
end
