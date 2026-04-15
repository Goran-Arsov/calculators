# frozen_string_literal: true

module Construction
  class BoardFootCalculator
    attr_reader :errors

    # 1 board foot = 144 cubic inches = 12" × 12" × 1" = 0.00235974 m³.
    # Hardwood pricing uses quarter-inch notation: 4/4 = 1", 5/4 = 1.25",
    # 6/4 = 1.5", 8/4 = 2", 12/4 = 3", 16/4 = 4".
    CUBIC_INCHES_PER_BF = 144.0
    CUBIC_METERS_PER_BF = 0.002359737216

    def initialize(thickness_in:, width_in:, length_ft:, quantity: 1, price_per_bf: nil)
      @thickness_in = thickness_in.to_f
      @width_in = width_in.to_f
      @length_ft = length_ft.to_f
      @quantity = quantity.to_i
      @price_per_bf = price_per_bf.nil? ? nil : price_per_bf.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      bf_each = (@thickness_in * @width_in * @length_ft) / 12.0
      total_bf = bf_each * @quantity
      cubic_meters = total_bf * CUBIC_METERS_PER_BF
      total_linear_feet = @length_ft * @quantity
      total_cost = @price_per_bf ? total_bf * @price_per_bf : nil

      {
        valid: true,
        bf_each: bf_each.round(4),
        total_bf: total_bf.round(2),
        cubic_meters: cubic_meters.round(4),
        total_linear_feet: total_linear_feet.round(2),
        total_cost: total_cost ? total_cost.round(2) : nil
      }
    end

    private

    def validate!
      @errors << "Thickness must be greater than zero" unless @thickness_in.positive?
      @errors << "Width must be greater than zero" unless @width_in.positive?
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Quantity must be at least 1" unless @quantity >= 1
      @errors << "Price cannot be negative" if @price_per_bf && @price_per_bf.negative?
    end
  end
end
