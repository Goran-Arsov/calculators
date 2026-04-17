require "test_helper"

module Education
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    {
      student_loan_forgiveness: :education_student_loan_forgiveness_url,
      college_cost_comparison: :education_college_cost_comparison_url,
      scholarship_roi: :education_scholarship_roi_url,
      class_schedule_builder: :education_class_schedule_builder_url,
      research_paper_word_count: :education_research_paper_word_count_url,
      credit_transfer: :education_credit_transfer_url,
      tuition_savings_529: :education_tuition_savings_529_url
    }.each do |action, url_helper|
      test "should get #{action}" do
        get send(url_helper)
        assert_response :success
        assert_select "h1"
      end
    end
  end
end
