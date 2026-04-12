# frozen_string_literal: true

module Education
  class CreditTransferCalculator
    attr_reader :errors

    def initialize(total_credits_earned:, transferable_credits:, degree_credits_required: 120, cost_per_credit_old: 0, cost_per_credit_new:, credits_per_semester: 15)
      @total_credits_earned = total_credits_earned.to_i
      @transferable_credits = transferable_credits.to_i
      @degree_credits_required = degree_credits_required.to_i
      @cost_per_credit_old = cost_per_credit_old.to_f
      @cost_per_credit_new = cost_per_credit_new.to_f
      @credits_per_semester = credits_per_semester.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      credits_lost = @total_credits_earned - @transferable_credits
      remaining_credits = [@degree_credits_required - @transferable_credits, 0].max
      remaining_semesters = @credits_per_semester > 0 ? (remaining_credits.to_f / @credits_per_semester).ceil : 0
      remaining_years = (remaining_semesters / 2.0).ceil

      cost_of_remaining = remaining_credits * @cost_per_credit_new
      cost_if_no_transfer = @degree_credits_required * @cost_per_credit_new
      cost_savings = cost_if_no_transfer - cost_of_remaining

      time_saved_semesters = @credits_per_semester > 0 ? (@transferable_credits.to_f / @credits_per_semester).floor : 0

      transfer_rate = @total_credits_earned > 0 ? ((@transferable_credits.to_f / @total_credits_earned) * 100) : 0.0

      value_of_lost_credits = credits_lost * @cost_per_credit_old

      {
        valid: true,
        total_credits_earned: @total_credits_earned,
        transferable_credits: @transferable_credits,
        credits_lost: credits_lost,
        transfer_rate: transfer_rate.round(1),
        remaining_credits: remaining_credits,
        remaining_semesters: remaining_semesters,
        remaining_years: remaining_years,
        cost_of_remaining: cost_of_remaining.round(2),
        cost_if_no_transfer: cost_if_no_transfer.round(2),
        cost_savings: cost_savings.round(2),
        time_saved_semesters: time_saved_semesters,
        value_of_lost_credits: value_of_lost_credits.round(2),
        degree_credits_required: @degree_credits_required,
        cost_per_credit_new: @cost_per_credit_new.round(2)
      }
    end

    private

    def validate!
      @errors << "Total credits earned must be positive" unless @total_credits_earned > 0
      @errors << "Transferable credits cannot be negative" if @transferable_credits < 0
      @errors << "Transferable credits cannot exceed total credits earned" if @transferable_credits > @total_credits_earned
      @errors << "Degree credits required must be positive" unless @degree_credits_required > 0
      @errors << "Cost per credit at new school must be positive" unless @cost_per_credit_new > 0
      @errors << "Credits per semester must be positive" unless @credits_per_semester > 0
    end
  end
end
