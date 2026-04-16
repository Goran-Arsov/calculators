# frozen_string_literal: true

class CalculatorRegistry
  EDUCATION_CALCULATORS = [
    { name: "Student Loan Forgiveness Calculator", slug: "student-loan-forgiveness-calculator", path: :education_student_loan_forgiveness_path, description: "Estimate savings under PSLF and IDR forgiveness programs based on income, loan balance, and payment plan.", icon_path: "M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" },
    { name: "College Cost Comparison Calculator", slug: "college-cost-comparison-calculator", path: :education_college_cost_comparison_path, description: "Compare total 4-year cost of two colleges including tuition, room, board, fees, and financial aid.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Scholarship ROI Calculator", slug: "scholarship-roi-calculator", path: :education_scholarship_roi_path, description: "Calculate hourly return on time spent applying for scholarships versus working a part-time job.", icon_path: "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" },
    { name: "Class Schedule Builder", slug: "class-schedule-builder", path: :education_class_schedule_builder_path, description: "Detect time conflicts and gaps in a weekly class schedule to optimize your college timetable.", icon_path: "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" },
    { name: "Research Paper Word Count Estimator", slug: "research-paper-word-count-estimator", path: :education_research_paper_word_count_path, description: "Estimate word count from page count based on font, spacing, margins, and font size.", icon_path: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" },
    { name: "Credit Transfer Calculator", slug: "credit-transfer-calculator", path: :education_credit_transfer_path, description: "Calculate transferable credits, remaining credits, and estimated time and cost savings.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Tuition Savings 529 Calculator", slug: "tuition-savings-529-calculator", path: :education_tuition_savings_529_path, description: "Project 529 plan growth with tax-free earnings and state tax deductions over time.", icon_path: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" }
  ].freeze

end
