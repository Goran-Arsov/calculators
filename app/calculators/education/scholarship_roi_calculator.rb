# frozen_string_literal: true

module Education
  class ScholarshipRoiCalculator
    attr_reader :errors

    def initialize(scholarship_amount:, hours_spent:, num_applications: 1, success_rate: 100.0, application_costs: 0)
      @scholarship_amount = scholarship_amount.to_f
      @hours_spent = hours_spent.to_f
      @num_applications = num_applications.to_i
      @success_rate = success_rate.to_f / 100.0
      @application_costs = application_costs.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      expected_value = @scholarship_amount * @success_rate
      net_gain = expected_value - @application_costs
      hourly_return = @hours_spent > 0 ? (net_gain / @hours_spent) : 0.0
      roi_percentage = @application_costs > 0 ? ((net_gain / @application_costs) * 100) : (net_gain > 0 ? Float::INFINITY : 0.0)
      hours_per_application = @num_applications > 0 ? (@hours_spent / @num_applications) : 0.0
      cost_per_application = @num_applications > 0 ? (@application_costs / @num_applications) : 0.0

      # Compare to typical part-time jobs
      min_wage_hourly = 15.0
      part_time_equivalent = @hours_spent * min_wage_hourly
      scholarship_advantage = net_gain - part_time_equivalent

      {
        valid: true,
        scholarship_amount: @scholarship_amount.round(2),
        expected_value: expected_value.round(2),
        net_gain: net_gain.round(2),
        hourly_return: hourly_return.round(2),
        roi_percentage: roi_percentage.is_a?(Float) && roi_percentage.infinite? ? "Infinite" : roi_percentage.round(2),
        hours_per_application: hours_per_application.round(2),
        cost_per_application: cost_per_application.round(2),
        total_hours: @hours_spent.round(2),
        num_applications: @num_applications,
        part_time_equivalent: part_time_equivalent.round(2),
        scholarship_advantage: scholarship_advantage.round(2),
        worth_it: hourly_return > min_wage_hourly
      }
    end

    private

    def validate!
      @errors << "Scholarship amount must be positive" unless @scholarship_amount > 0
      @errors << "Hours spent must be positive" unless @hours_spent > 0
      @errors << "Number of applications must be at least 1" unless @num_applications >= 1
      @errors << "Success rate must be between 0 and 100" unless @success_rate.between?(0, 1.0)
      @errors << "Application costs cannot be negative" if @application_costs < 0
    end
  end
end
