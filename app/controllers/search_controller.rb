# frozen_string_literal: true

class SearchController < ApplicationController
  include CalculatorHelper

  def index
    @query = params[:q].to_s.strip
    @results = matching_calculators(@query)

    set_meta_tags(
      title: @query.present? ? "Search results for \"#{@query}\"" : "Search calculators",
      description: "Find calculators and tools by name across every category on Calc Hammer.",
      noindex: true
    )
  end

  private

  def matching_calculators(query)
    return [] if query.empty?

    needle = query.downcase
    CalculatorRegistry::ALL_CATEGORIES.flat_map do |_slug, category|
      category[:calculators]
        .select { |calc| calc[:name].to_s.downcase.include?(needle) }
        .map { |calc| calc.merge(category_title: category[:title], path: resolve_calculator_path(calc)) }
    end
  end
end
