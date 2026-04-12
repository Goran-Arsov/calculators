require "test_helper"

class Relationships::CalculatorsControllerTest < ActionDispatch::IntegrationTest
  CALCULATOR_PATHS = [
    [ :relationships_love_compatibility_path, /Love Compatibility Calculator/ ],
    [ :relationships_zodiac_compatibility_path, /Zodiac Compatibility Calculator/ ],
    [ :relationships_age_gap_path, /Age Gap Calculator/ ],
    [ :relationships_when_meet_path, /When Will I Meet Someone Calculator/ ],
    [ :relationships_flames_path, /FLAMES Calculator/ ],
    [ :relationships_wedding_budget_path, /Wedding Budget Planner Calculator/ ],
    [ :relationships_wedding_splitter_path, /Wedding Cost Splitter/ ],
    [ :relationships_honeymoon_savings_path, /Honeymoon Savings Calculator/ ],
    [ :relationships_engagement_ring_path, /Engagement Ring Budget Calculator/ ],
    [ :relationships_child_cost_path, /Cost of Raising a Child Calculator/ ],
    [ :relationships_date_night_budget_path, /Date Night Budget Calculator/ ],
    [ :relationships_anniversary_path, /Anniversary Calculator/ ],
    [ :relationships_dating_duration_path, /Dating Duration Calculator/ ],
    [ :relationships_days_until_wedding_path, /Days Until Wedding Calculator/ ],
    [ :relationships_milestones_path, /Relationship Milestone Calculator/ ],
    [ :relationships_breakup_recovery_path, /Breakup Recovery Calculator/ ],
    [ :relationships_divorce_cost_path, /Divorce Cost Calculator/ ],
    [ :relationships_alimony_path, /Alimony Calculator/ ],
    [ :relationships_child_support_path, /Child Support Calculator/ ],
    [ :relationships_dating_pool_path, /Dating Pool Calculator/ ],
    [ :relationships_half_plus_seven_path, /Half Your Age Plus Seven Calculator/ ],
    [ :relationships_online_dating_roi_path, /Online Dating ROI Calculator/ ]
  ].freeze

  CALCULATOR_PATHS.each do |helper, heading|
    test "GET #{helper} renders successfully" do
      get send(helper)
      assert_response :success
      assert_select "h1", heading
    end
  end
end
