class EmbedsController < ApplicationController
  layout "embed"
  before_action :allow_iframe
  helper_method :embed_mode?

  VALID_CATEGORIES = %w[finance math physics health construction textile everyday].freeze

  def show
    @category = params[:category]
    @slug = params[:slug]

    unless VALID_CATEGORIES.include?(@category)
      return render plain: "Calculator not found", status: :not_found
    end

    action = @slug.tr("-", "_").sub(/_calculator$/, "")

    unless action.match?(/\A\w+\z/)
      return render plain: "Calculator not found", status: :not_found
    end

    path = "#{@category}/calculators/#{action}"

    if lookup_context.template_exists?(path)
      render template: path, layout: "embed"
    else
      render plain: "Calculator not found", status: :not_found
    end
  end

  def embed_mode?
    true
  end

  private

  def allow_iframe
    response.headers.delete("X-Frame-Options")
  end
end
