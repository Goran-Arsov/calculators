# frozen_string_literal: true

module Finance
  class NetWorthCalculator
    attr_reader :errors

    ASSET_FIELDS = %i[cash investments real_estate vehicles other_assets].freeze
    LIABILITY_FIELDS = %i[mortgage student_loans auto_loans credit_cards other_liabilities].freeze

    def initialize(assets: {}, liabilities: {})
      @assets = normalize_hash(assets, ASSET_FIELDS)
      @liabilities = normalize_hash(liabilities, LIABILITY_FIELDS)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_assets = @assets.values.sum
      total_liabilities = @liabilities.values.sum
      net_worth = total_assets - total_liabilities
      asset_to_debt_ratio = total_liabilities.zero? ? Float::INFINITY : (total_assets / total_liabilities).round(2)

      {
        valid: true,
        total_assets: total_assets.round(2),
        total_liabilities: total_liabilities.round(2),
        net_worth: net_worth.round(2),
        asset_to_debt_ratio: asset_to_debt_ratio,
        assets: @assets,
        liabilities: @liabilities
      }
    end

    private

    def normalize_hash(hash, allowed_keys)
      allowed_keys.each_with_object({}) do |key, result|
        result[key] = hash.fetch(key, 0).to_f
      end
    end

    def validate!
      @assets.each do |key, value|
        @errors << "#{key.to_s.humanize} cannot be negative" if value < 0
      end
      @liabilities.each do |key, value|
        @errors << "#{key.to_s.humanize} cannot be negative" if value < 0
      end
    end
  end
end
