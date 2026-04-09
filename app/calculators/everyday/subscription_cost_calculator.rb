# frozen_string_literal: true

module Everyday
  class SubscriptionCostCalculator
    attr_reader :errors

    FREQUENCY_MULTIPLIERS = {
      "weekly" => 4.33,
      "monthly" => 1.0,
      "yearly" => 1.0 / 12.0
    }.freeze

    def initialize(subscriptions:)
      @subscriptions = Array(subscriptions).map do |s|
        {
          name: s[:name].to_s,
          cost: s[:cost].to_f,
          frequency: s[:frequency].to_s.downcase
        }
      end
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      per_subscription = @subscriptions.map do |s|
        multiplier = FREQUENCY_MULTIPLIERS[s[:frequency]]
        monthly = s[:cost] * multiplier
        {
          name: s[:name],
          cost: s[:cost].round(2),
          frequency: s[:frequency],
          monthly_cost: monthly.round(2)
        }
      end

      total_monthly = per_subscription.sum { |s| s[:monthly_cost] }
      total_annual = total_monthly * 12
      count = per_subscription.size
      average_per_subscription = count.positive? ? (total_monthly / count) : 0.0
      most_expensive = per_subscription.max_by { |s| s[:monthly_cost] }

      {
        valid: true,
        total_monthly: total_monthly.round(2),
        total_annual: total_annual.round(2),
        count: count,
        average_per_subscription: average_per_subscription.round(2),
        most_expensive: most_expensive,
        per_subscription: per_subscription
      }
    end

    private

    def validate!
      @errors << "At least one subscription is required" if @subscriptions.empty?
      @subscriptions.each_with_index do |s, i|
        @errors << "Subscription #{i + 1} cost must be positive" unless s[:cost].positive?
        unless FREQUENCY_MULTIPLIERS.key?(s[:frequency])
          @errors << "Subscription #{i + 1} frequency must be weekly, monthly, or yearly"
        end
      end
    end
  end
end
