class ProgrammaticController < ApplicationController
  include SeoHelper
  include CalculatorHelper

  before_action :load_page

  def show
    set_meta_tags(
      title: @page[:title],
      description: @page[:meta_description],
      canonical: request.original_url,
      og: {
        title: "#{@page[:title]} | CalcWise",
        description: @page[:meta_description],
        url: request.original_url,
        type: "website",
        site_name: "CalcWise"
      }
    )
  end

  private

  def load_page
    @page = ProgrammaticSeo::Registry.find(params[:programmatic_slug])
    raise ActionController::RoutingError, "Not Found" unless @page
    @slug = params[:programmatic_slug]
    @category = @page[:category]
  end
end
