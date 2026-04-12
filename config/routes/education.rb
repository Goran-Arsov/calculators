namespace :education do
  get "student-loan-forgiveness-calculator", to: "calculators#student_loan_forgiveness", as: :student_loan_forgiveness
  get "college-cost-comparison-calculator", to: "calculators#college_cost_comparison", as: :college_cost_comparison
  get "scholarship-roi-calculator", to: "calculators#scholarship_roi", as: :scholarship_roi
  get "class-schedule-builder", to: "calculators#class_schedule_builder", as: :class_schedule_builder
  get "research-paper-word-count-estimator", to: "calculators#research_paper_word_count", as: :research_paper_word_count
  get "credit-transfer-calculator", to: "calculators#credit_transfer", as: :credit_transfer
  get "tuition-savings-529-calculator", to: "calculators#tuition_savings_529", as: :tuition_savings_529
end
