class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_default_meta_tags

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
end
