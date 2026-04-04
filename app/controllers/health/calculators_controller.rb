module Health
  class CalculatorsController < ApplicationController
    before_action :set_cache_headers

    def bmi; end
    def calorie; end
    def body_fat; end
    def pregnancy_due_date; end
    def tdee; end
    def macro; end
    def pace; end
    def water_intake; end
    def sleep; end
    def one_rep_max; end
    def dog_age; end
    def pregnancy_week; end
    def dog_food; end

    private

    def set_cache_headers
      expires_in 1.hour, public: true
    end
  end
end
