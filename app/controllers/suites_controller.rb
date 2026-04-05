class SuitesController < ApplicationController
  before_action :set_cache_headers

  def home_buying
    set_meta_tags(
      title: "Home Buying Calculator Suite - CalcWise",
      description: "Complete home buying calculator suite: mortgage, down payment, affordability, and closing costs in one guided workflow."
    )
  end

  def fitness
    set_meta_tags(
      title: "Fitness Calculator Suite - CalcWise",
      description: "Complete fitness calculator suite: BMI, TDEE, macro calculator, and calorie planning in one guided workflow."
    )
  end

  def business_startup
    set_meta_tags(
      title: "Business Startup Calculator Suite - CalcWise",
      description: "Complete business startup calculator suite: break-even analysis, loan, ROI, and salary planning."
    )
  end

  private

  def set_cache_headers
    expires_in 1.hour, public: true, stale_while_revalidate: 30.minutes
  end
end
