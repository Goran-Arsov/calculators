# frozen_string_literal: true

module Everyday
  class CostPerPageCalculator
    attr_reader :errors

    def initialize(cartridge_cost:, page_yield:, pages_per_month: 0)
      @cartridge_cost = cartridge_cost.to_f
      @page_yield = page_yield.to_f
      @pages_per_month = pages_per_month.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      cost_per_page = @cartridge_cost / @page_yield
      cost_per_100_pages = cost_per_page * 100

      result = {
        valid: true,
        cost_per_page: cost_per_page.round(4),
        cost_per_100_pages: cost_per_100_pages.round(2),
        cartridge_cost: @cartridge_cost.round(2),
        page_yield: @page_yield.round(0)
      }

      if @pages_per_month.positive?
        monthly_cost = cost_per_page * @pages_per_month
        yearly_cost = monthly_cost * 12
        cartridges_per_year = (@pages_per_month * 12) / @page_yield

        result.merge!(
          monthly_cost: monthly_cost.round(2),
          yearly_cost: yearly_cost.round(2),
          cartridges_per_year: cartridges_per_year.round(1)
        )
      end

      result
    end

    private

    def validate!
      @errors << "Cartridge cost must be greater than zero" unless @cartridge_cost.positive?
      @errors << "Page yield must be greater than zero" unless @page_yield.positive?
      @errors << "Pages per month cannot be negative" if @pages_per_month.negative?
    end
  end
end
