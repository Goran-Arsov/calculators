# frozen_string_literal: true

module Finance
  class CostPerClickCalculator
    attr_reader :errors

    def initialize(total_spend:, clicks:, impressions: nil)
      @total_spend = total_spend.to_f
      @clicks = clicks.to_i
      @impressions = impressions.nil? || impressions.to_s.strip.empty? ? nil : impressions.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      cpc = @total_spend / @clicks

      result = {
        valid: true,
        cost_per_click: cpc.round(4),
        total_spend: @total_spend.round(2),
        clicks: @clicks
      }

      if @impressions && @impressions > 0
        cpm = (@total_spend / @impressions) * 1000.0
        ctr = (@clicks.to_f / @impressions) * 100.0
        result[:impressions] = @impressions
        result[:cpm] = cpm.round(4)
        result[:click_through_rate] = ctr.round(4)
      end

      result
    end

    private

    def validate!
      @errors << "Total spend must be positive" unless @total_spend > 0
      @errors << "Clicks must be positive" unless @clicks > 0
      @errors << "Impressions must be positive" if @impressions && @impressions <= 0
    end
  end
end
