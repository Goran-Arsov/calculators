# frozen_string_literal: true

module Relationships
  class DivorceCostCalculator
    attr_reader :errors

    BASE_COSTS = {
      "uncontested" => { low: 1000, mid: 2500, high: 4500 },
      "mediated" => { low: 3000, mid: 7500, high: 12000 },
      "collaborative" => { low: 7500, mid: 15000, high: 25000 },
      "contested" => { low: 15000, mid: 30000, high: 60000 }
    }.freeze

    CHILDREN_EXTRA = 3500
    PROPERTY_EXTRA = 4500
    BUSINESS_EXTRA = 8000

    def initialize(path:, has_children: false, has_property: false, has_business: false)
      @path = path.to_s
      @has_children = !!has_children
      @has_property = !!has_property
      @has_business = !!has_business
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      base = BASE_COSTS[@path]
      extras = 0
      extras += CHILDREN_EXTRA if @has_children
      extras += PROPERTY_EXTRA if @has_property
      extras += BUSINESS_EXTRA if @has_business

      {
        valid: true,
        path: @path,
        low_estimate: base[:low] + extras,
        mid_estimate: base[:mid] + extras,
        high_estimate: base[:high] + extras,
        extras: extras
      }
    end

    private

    def validate!
      @errors << "Divorce path is invalid" unless BASE_COSTS.key?(@path)
    end
  end
end
