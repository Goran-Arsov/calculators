# frozen_string_literal: true

class SearchController < ApplicationController
  include CalculatorHelper

  def index
    @query = params[:q].to_s.strip
    @results = matching_calculators(@query)

    page_title = @query.present? ? "Search results for \"#{@query}\"" : "Search calculators"
    page_description = "Find calculators and tools by name across every category on Calc Hammer."

    set_meta_tags(
      title: page_title,
      description: page_description,
      noindex: true,
      og: {
        title: "#{page_title} | Calc Hammer",
        description: page_description,
        url: search_url(q: @query.presence),
        type: "website",
        site_name: "Calc Hammer"
      }
    )
  end

  private

  def matching_calculators(query)
    return [] if query.empty?

    needles = query.downcase.split(/\s+/)
    CalculatorRegistry::ALL_CATEGORIES.flat_map do |_slug, category|
      category[:calculators].filter_map do |calc|
        searchable = "#{calc[:name]} #{calc[:description]}".downcase
        matched = needles.count { |n| searchable.include?(n) }
        next if matched.zero?

        calc.merge(category_title: category[:title], path: resolve_calculator_path(calc), _score: matched)
      end
    end.sort_by { |c| -c[:_score] }.each { |c| c.delete(:_score) }
  end
end
