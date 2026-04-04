class CategoriesController < ApplicationController
  include CalculatorHelper

  def show
    expires_in 1.hour, public: true
    @slug = params[:category]
    @category = ALL_CATEGORIES[@slug]
    raise ActionController::RoutingError, "Not Found" unless @category

    @calculators = @category[:calculators].map do |calc|
      calc.merge(path: resolve_calculator_path(calc))
    end

    set_meta_tags(
      title: @category[:title],
      description: @category[:description],
      canonical: category_url(@slug),
      og: {
        title: "#{@category[:title]} | CalcWise",
        description: @category[:description],
        url: category_url(@slug),
        type: "website",
        site_name: "CalcWise"
      }
    )
  end
end
