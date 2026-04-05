# frozen_string_literal: true

module Construction
  class LumberCalculator
    attr_reader :errors

    def initialize(thickness_in:, width_in:, length_ft:, quantity: 1, price_per_bf: 0)
      @thickness_in = thickness_in.to_f
      @width_in = width_in.to_f
      @length_ft = length_ft.to_f
      @quantity = quantity.to_i
      @price_per_bf = price_per_bf.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Board feet = (thickness x width x length) / 12
      # where thickness and width are in inches, length in feet
      board_feet_each = (@thickness_in * @width_in * @length_ft) / 12.0
      total_board_feet = board_feet_each * @quantity

      # Cost
      cost_each = board_feet_each * @price_per_bf
      total_cost = total_board_feet * @price_per_bf

      # Linear feet
      total_linear_feet = @length_ft * @quantity

      {
        valid: true,
        board_feet_each: board_feet_each.round(4),
        total_board_feet: total_board_feet.round(4),
        total_linear_feet: total_linear_feet.round(2),
        quantity: @quantity,
        cost_each: cost_each.round(2),
        total_cost: total_cost.round(2)
      }
    end

    private

    def validate!
      @errors << "Thickness must be greater than zero" unless @thickness_in.positive?
      @errors << "Width must be greater than zero" unless @width_in.positive?
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Quantity must be at least 1" unless @quantity >= 1
      @errors << "Price per board foot cannot be negative" if @price_per_bf.negative?
    end
  end
end
