# frozen_string_literal: true

module Finance
  class CostPerLeadCalculator
    attr_reader :errors

    def initialize(total_spend:, leads:, qualified_leads: nil, total_visitors: nil)
      @total_spend = total_spend.to_f
      @leads = leads.to_i
      @qualified_leads = qualified_leads.nil? || qualified_leads.to_s.strip.empty? ? nil : qualified_leads.to_i
      @total_visitors = total_visitors.nil? || total_visitors.to_s.strip.empty? ? nil : total_visitors.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      cpl = @total_spend / @leads

      result = {
        valid: true,
        cost_per_lead: cpl.round(4),
        total_spend: @total_spend.round(2),
        leads: @leads
      }

      if @qualified_leads && @qualified_leads > 0
        cpql = @total_spend / @qualified_leads
        qualification_rate = (@qualified_leads.to_f / @leads) * 100.0
        result[:qualified_leads] = @qualified_leads
        result[:cost_per_qualified_lead] = cpql.round(4)
        result[:qualification_rate] = qualification_rate.round(4)
      end

      if @total_visitors && @total_visitors > 0
        conversion_rate = (@leads.to_f / @total_visitors) * 100.0
        result[:total_visitors] = @total_visitors
        result[:conversion_rate] = conversion_rate.round(4)
      end

      result
    end

    private

    def validate!
      @errors << "Total spend must be positive" unless @total_spend > 0
      @errors << "Leads must be positive" unless @leads > 0
      @errors << "Qualified leads must be positive" if @qualified_leads && @qualified_leads <= 0
      @errors << "Qualified leads cannot exceed total leads" if @qualified_leads && @qualified_leads > @leads
      @errors << "Total visitors must be positive" if @total_visitors && @total_visitors <= 0
    end
  end
end
