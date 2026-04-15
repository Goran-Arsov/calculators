# frozen_string_literal: true

class BrowseController < ApplicationController
  include CalculatorHelper

  def index
    @categories = CalculatorRegistry::ALL_CATEGORIES.map do |slug, category|
      calcs = category[:calculators].map do |calc|
        calc.merge(path: resolve_calculator_path(calc))
      end
      { slug: slug, title: category[:title], description: category[:description], calculators: calcs }
    end

    set_meta_tags(
      title: "All Calculators & Tools - Browse Everything",
      description: "Browse all free online calculators and tools: finance, math, physics, health, construction, everyday, and IT tools. Find exactly what you need.",
      canonical: browse_url,
      og: {
        title: "All Calculators & Tools | Calc Hammer",
        description: "Browse every calculator and tool on Calc Hammer. Finance, math, physics, health, construction, everyday, and IT tools.",
        url: browse_url,
        type: "website",
        site_name: "Calc Hammer"
      }
    )
  end
end
