class PagesController < ApplicationController
  def privacy_policy
    set_meta_tags(
      title: "Privacy Policy",
      description: "Calc Hammer privacy policy. Learn how we handle your data, cookies, and advertising.",
      canonical: privacy_policy_url
    )
  end

  def terms_of_service
    set_meta_tags(
      title: "Terms of Service",
      description: "Calc Hammer terms of service. Read our terms and conditions for using our free online calculators.",
      canonical: terms_of_service_url
    )
  end

  def about
    set_meta_tags(
      title: "About Calc Hammer",
      description: "Calc Hammer provides 74+ free online calculators for finance, math, physics, health, construction, and everyday life. Learn about our mission.",
      canonical: about_url
    )
  end

  def contact
    set_meta_tags(
      title: "Contact Us",
      description: "Get in touch with Calc Hammer. Send us feedback, report issues, or suggest new calculators.",
      canonical: contact_url
    )
  end

  def disclaimer
    set_meta_tags(
      title: "Disclaimer",
      description: "Important disclaimers about Calc Hammer calculators. Our tools are for informational purposes only and not a substitute for professional advice.",
      canonical: disclaimer_url
    )
  end

  private

  # Static pages change only on deploy — cache aggressively.
  def set_http_cache
    return unless request.get? || request.head?

    expires_in 1.day, public: true,
      stale_while_revalidate: 6.hours,
      stale_if_error: 7.days

    fresh_when etag: [ CACHE_VERSION, request.path ], public: true
  end
end
