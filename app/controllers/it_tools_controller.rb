# frozen_string_literal: true

class ItToolsController < ApplicationController
  include CalculatorHelper

  def index
    everyday_calcs = CalculatorRegistry::ALL_CATEGORIES["everyday"][:calculators]
    @tools = everyday_calcs
      .select { |c| CalculatorRegistry::IT_TOOL_SLUGS.include?(c[:slug]) }
      .map { |c| c.merge(path: resolve_calculator_path(c)) }

    set_meta_tags(
      title: "IT Tools - Free Online Developer Utilities",
      description: "Free IT tools for developers: hash generators, JSON formatters, JWT decoders, subnet calculators, code minifiers, PDF converters, and more. No sign-up required.",
      canonical: it_tools_url,
      og: {
        title: "IT Tools - Free Online Developer Utilities | CalcWise",
        description: "Free online IT tools for developers. Hash generators, JWT decoders, subnet calculators, code formatters, file converters, and more.",
        url: it_tools_url,
        type: "website",
        site_name: "CalcWise"
      }
    )
  end
end
