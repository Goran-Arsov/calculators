class HomeController < ApplicationController
  def index
    expires_in 1.hour, public: true
    set_meta_tags(
      title: "Free Online Calculators",
      description: "CalcWise offers free online calculators for finance, math, and health. Mortgage, loan, BMI, percentage calculators and more — fast, accurate, and easy to use.",
      canonical: root_url,
      og: {
        title: "CalcWise — Free Online Calculators",
        description: "Free online calculators for finance, math, and health.",
        url: root_url,
        type: "website",
        site_name: "CalcWise"
      }
    )
  end
end
