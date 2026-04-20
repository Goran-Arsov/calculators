class SuitesController < ApplicationController
  def home_buying
    set_meta_tags(
      title: "Home Buying Calculator Suite - Calc Hammer",
      description: "Complete home buying calculator suite: mortgage, down payment, affordability, and closing costs in one guided workflow.",
      canonical: suite_home_buying_url,
      og: {
        title: "Home Buying Calculator Suite | Calc Hammer",
        description: "Complete home buying calculator suite: mortgage, down payment, affordability, and closing costs in one guided workflow.",
        url: suite_home_buying_url,
        type: "website",
        site_name: "Calc Hammer"
      }
    )
  end

  def fitness
    set_meta_tags(
      title: "Fitness Calculator Suite - Calc Hammer",
      description: "Complete fitness calculator suite: BMI, TDEE, macro calculator, and calorie planning in one guided workflow.",
      canonical: suite_fitness_url,
      og: {
        title: "Fitness Calculator Suite | Calc Hammer",
        description: "Complete fitness calculator suite: BMI, TDEE, macro calculator, and calorie planning in one guided workflow.",
        url: suite_fitness_url,
        type: "website",
        site_name: "Calc Hammer"
      }
    )
  end

  def business_startup
    set_meta_tags(
      title: "Business Startup Calculator Suite - Calc Hammer",
      description: "Complete business startup calculator suite: break-even analysis, loan, ROI, and salary planning.",
      canonical: suite_business_startup_url,
      og: {
        title: "Business Startup Calculator Suite | Calc Hammer",
        description: "Complete business startup calculator suite: break-even analysis, loan, ROI, and salary planning.",
        url: suite_business_startup_url,
        type: "website",
        site_name: "Calc Hammer"
      }
    )
  end
end
