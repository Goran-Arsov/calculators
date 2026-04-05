class PagesController < ApplicationController
  before_action :set_cache_headers

  def privacy_policy
    set_meta_tags(
      title: "Privacy Policy",
      description: "CalcWise privacy policy. Learn how we handle your data, cookies, and advertising.",
      canonical: privacy_policy_url
    )
  end

  def terms_of_service
    set_meta_tags(
      title: "Terms of Service",
      description: "CalcWise terms of service. Read our terms and conditions for using our free online calculators.",
      canonical: terms_of_service_url
    )
  end

  def about
    set_meta_tags(
      title: "About CalcWise",
      description: "CalcWise provides 74+ free online calculators for finance, math, physics, health, construction, and everyday life. Learn about our mission.",
      canonical: about_url
    )
  end

  def contact
    set_meta_tags(
      title: "Contact Us",
      description: "Get in touch with CalcWise. Send us feedback, report issues, or suggest new calculators.",
      canonical: contact_url
    )
  end

  def disclaimer
    set_meta_tags(
      title: "Disclaimer",
      description: "Important disclaimers about CalcWise calculators. Our tools are for informational purposes only and not a substitute for professional advice.",
      canonical: disclaimer_url
    )
  end

  private

  def set_cache_headers
    expires_in 1.day, public: true, stale_while_revalidate: 6.hours
  end
end
