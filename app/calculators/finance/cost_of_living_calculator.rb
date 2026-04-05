# frozen_string_literal: true

module Finance
  class CostOfLivingCalculator
    attr_reader :errors

    def initialize(current_salary:, current_index:, target_index:)
      @current_salary = current_salary.to_f
      @current_index = current_index.to_f
      @target_index = target_index.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      ratio = @target_index / @current_index
      equivalent_salary = @current_salary * ratio
      salary_difference = equivalent_salary - @current_salary
      percentage_difference = ((ratio - 1.0) * 100.0)
      purchasing_power = @current_salary / ratio

      {
        valid: true,
        equivalent_salary: equivalent_salary.round(2),
        salary_difference: salary_difference.round(2),
        percentage_difference: percentage_difference.round(2),
        purchasing_power: purchasing_power.round(2),
        cost_ratio: ratio.round(4)
      }
    end

    private

    def validate!
      @errors << "Current salary must be greater than zero" unless @current_salary.positive?
      @errors << "Current city index must be greater than zero" unless @current_index.positive?
      @errors << "Target city index must be greater than zero" unless @target_index.positive?
    end
  end
end
