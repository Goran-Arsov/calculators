class HomeController < ApplicationController
  include CalculatorHelper

  def index
    set_meta_tags(
      title: "Free Online Calculators",
      description: "Calc Hammer offers free online calculators for finance, math, and health. Mortgage, loan, BMI, percentage calculators and more — fast, accurate, and easy to use.",
      canonical: root_url,
      og: {
        title: "Calc Hammer — Free Online Calculators",
        description: "Free online calculators for finance, math, and health.",
        url: root_url,
        type: "website",
        site_name: "Calc Hammer"
      }
    )

    @trending_calculators = Rails.cache.fetch("trending_calculators", expires_in: 1.hour) do
      trending_calculators
    end

    @latest_blog_posts = Rails.cache.fetch("home_latest_blog_posts", expires_in: 1.hour) do
      BlogPost.published.recent.limit(3).to_a
    end
  end
end
