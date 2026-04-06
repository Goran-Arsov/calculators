class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_default_meta_tags
  before_action :set_http_cache

  helper_method :embed_mode?

  def embed_mode?
    false
  end

  private

  def set_default_meta_tags
    domain = ENV.fetch("DOMAIN", request.base_url)
    set_meta_tags(
      og: {
        image: "#{domain}/og-image.png",
        site_name: "CalcWise"
      },
      twitter: {
        card: "summary_large_image",
        site: "@calcwise",
        image: "#{domain}/og-image.png"
      }
    )
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
