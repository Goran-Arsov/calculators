class PagesController < ApplicationController
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
      description: "CalcWise provides free, accurate online calculators for finance, math, and health. Learn more about our mission.",
      canonical: about_url
    )
  end
end
