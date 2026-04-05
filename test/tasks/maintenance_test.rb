require "test_helper"
require "rake"

class MaintenancePurgeOldRatingsTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("maintenance:purge_old_ratings")
    # Re-enable so the task can run multiple times in tests
    Rake::Task["maintenance:purge_old_ratings"].reenable
  end

  test "purge_old_ratings removes ratings older than 6 months" do
    old_rating = CalculatorRating.create!(
      calculator_slug: "test-calc",
      direction: "up",
      ip_hash: "old_hash_001",
      created_at: 7.months.ago
    )
    recent_rating = CalculatorRating.create!(
      calculator_slug: "test-calc",
      direction: "down",
      ip_hash: "recent_hash_001",
      created_at: 1.month.ago
    )

    assert_difference -> { CalculatorRating.count }, -1 do
      Rake::Task["maintenance:purge_old_ratings"].invoke
    end

    assert_not CalculatorRating.exists?(old_rating.id)
    assert CalculatorRating.exists?(recent_rating.id)
  end

  test "purge_old_ratings handles no old ratings gracefully" do
    assert_no_difference -> { CalculatorRating.count } do
      Rake::Task["maintenance:purge_old_ratings"].invoke
    end
  end
end

class MaintenanceOptimizeDbTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("maintenance:optimize_db")
    Rake::Task["maintenance:optimize_db"].reenable
  end

  test "optimize_db task is defined" do
    assert Rake::Task.task_defined?("maintenance:optimize_db"),
           "maintenance:optimize_db rake task should be defined"
    # VACUUM cannot run inside a test transaction, so we verify the task
    # is correctly defined rather than executing it.
  end
end
