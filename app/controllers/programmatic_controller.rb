class ProgrammaticController < ApplicationController
  include SeoHelper
  include CalculatorHelper

  before_action :load_page

  def show
    meta = {
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
    }

    # Prevent indexing of thin/low-quality auto-generated pages
    unless @page[:indexable]
      meta[:noindex] = true
      meta[:nofollow] = true
    end

    set_meta_tags(meta)
  end

  private

  def load_page
    @page = ProgrammaticSeo::Registry.find(params[:programmatic_slug])
    raise ActionController::RoutingError, "Not Found" unless @page
    @slug = params[:programmatic_slug]
    @category = @page[:category]
  end
end
