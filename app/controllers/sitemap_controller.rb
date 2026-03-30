class SitemapController < ApplicationController
  def show
    @urls = []

    # Homepage
    @urls << { loc: root_url, changefreq: "weekly", priority: "1.0" }

    # Category pages
    %w[finance math health].each do |cat|
      @urls << { loc: category_url(cat), changefreq: "weekly", priority: "0.9" }
    end

    # Finance calculators
    @urls << { loc: finance_mortgage_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: finance_compound_interest_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: finance_loan_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: finance_investment_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: finance_retirement_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: finance_debt_payoff_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: finance_salary_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: finance_savings_goal_url, changefreq: "monthly", priority: "0.8" }

    # Math calculators
    @urls << { loc: math_percentage_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: math_fraction_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: math_area_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: math_circumference_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: math_exponent_url, changefreq: "monthly", priority: "0.8" }

    # Health calculators
    @urls << { loc: health_bmi_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: health_calorie_url, changefreq: "monthly", priority: "0.8" }
    @urls << { loc: health_body_fat_url, changefreq: "monthly", priority: "0.8" }

    # Blog posts
    BlogPost.published.recent.each do |post|
      @urls << { loc: blog_post_url(post.slug), changefreq: "monthly", priority: "0.6" }
    end

    # Static pages
    @urls << { loc: blog_url, changefreq: "weekly", priority: "0.7" }
    @urls << { loc: about_url, changefreq: "monthly", priority: "0.5" }
    @urls << { loc: privacy_policy_url, changefreq: "yearly", priority: "0.3" }
    @urls << { loc: terms_of_service_url, changefreq: "yearly", priority: "0.3" }

    respond_to do |format|
      format.xml
    end
  end
end
