class EmbedsController < ApplicationController
  layout "embed"
  before_action :set_cache_headers
  before_action :allow_iframe
  helper_method :embed_mode?

  def show
    @category = params[:category]
    @slug = params[:slug]
    action_name = @slug.tr("-", "_").sub(/_calculator$/, "")
    render template: "#{@category}/calculators/#{action_name}", layout: "embed"
  rescue ActionView::MissingTemplate
    render plain: "Calculator not found", status: :not_found
  end

  def embed_mode?
    true
  end

  private

  def set_cache_headers
    expires_in 1.hour, public: true
  end

  def allow_iframe
    response.headers.delete("X-Frame-Options")
  end
end
