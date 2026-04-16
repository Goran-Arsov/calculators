class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_locale
  before_action :set_default_meta_tags
  before_action :set_http_cache

  helper_method :embed_mode?

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::RoutingError, with: :not_found

  def embed_mode?
    false
  end

  private

  SUPPORTED_LOCALES = %w[de fr es pt mk].freeze

  def set_locale
    locale = params[:locale]
    if locale && SUPPORTED_LOCALES.include?(locale)
      I18n.locale = locale.to_sym
      prepend_view_path Rails.root.join("app", "views", "locales", locale)
    else
      I18n.locale = I18n.default_locale
    end
  end

  CATEGORY_OG_SLUGS = %w[finance math physics health construction textile everyday alcohol automotive cooking education gardening geography pets photography relationships].freeze

  def set_default_meta_tags
    domain = ENV.fetch("DOMAIN", request.base_url)
    image_url = "#{domain}/#{category_og_image}"
    set_meta_tags(
      og: {
        image: image_url,
        site_name: "Calc Hammer"
      },
      twitter: {
        card: "summary_large_image",
        site: "@calchammer",
        image: image_url
      }
    )
  end

  # Pick a category-specific OG image based on the current controller's module.
  # Falls back to the generic og-image.png for non-category controllers.
  def category_og_image
    category = controller_path.split("/").first
    CATEGORY_OG_SLUGS.include?(category) ? "og-#{category}.png" : "og-image.png"
  end

  def not_found
    respond_to do |format|
      format.html { render file: Rails.root.join("public/404.html"), layout: false, status: :not_found }
      format.json { render json: { error: "Not found" }, status: :not_found }
      format.any  { head :not_found }
    end
  end

  # Default HTTP caching for all pages. Override in subclasses for different TTLs.
  # Calculator pages are fully static (Stimulus handles all computation client-side),
  # so they can be cached aggressively.
  def set_http_cache
    return unless request.get? || request.head?

    expires_in 6.hours, public: true,
      stale_while_revalidate: 2.hours,
      stale_if_error: 1.day

    # Conditional GET: browsers/CDNs with a matching ETag get a 304 (no body),
    # skipping view rendering entirely. The ETag changes on every deploy.
    fresh_when etag: [ CACHE_VERSION, request.path ], public: true
  end
end
