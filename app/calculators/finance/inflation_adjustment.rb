# frozen_string_literal: true

module Finance
  # Mix-in for calculators that want an optional "adjust for inflation" output.
  # Host class must set @annual_inflation_rate (as a decimal, e.g. 0.03) or leave it nil.
  # When nil, apply_inflation is a no-op and nothing is added to the result hash.
  module InflationAdjustment
    # result         - the nominal result hash returned by the calculator
    # years:         - the time horizon over which to discount (usually @years)
    # nominal_keys:  - which numeric keys in `result` should have real_* counterparts added
    def apply_inflation(result, years:, nominal_keys:)
      return result if @annual_inflation_rate.nil?
      return result unless years.to_f > 0

      factor = (1 + @annual_inflation_rate)**years.to_f
      adjusted = nominal_keys.each_with_object({}) do |key, h|
        value = result[key]
        h[:"real_#{key}"] = (value.to_f / factor).round(2) if value.is_a?(Numeric)
      end
      result.merge(adjusted).merge(annual_inflation_rate: (@annual_inflation_rate * 100).round(4))
    end

    # Returns the error string if the stored inflation rate is negative; nil otherwise.
    # Host should push this into @errors during validation when non-nil.
    def inflation_rate_error
      return nil if @annual_inflation_rate.nil?
      "Inflation rate cannot be negative" if @annual_inflation_rate < 0
    end
  end
end
