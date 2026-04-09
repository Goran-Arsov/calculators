# frozen_string_literal: true

module Everyday
  class StudentBudgetCalculator
    attr_reader :errors

    def initialize(tuition:, room_and_board:, books_supplies:, transportation:, personal_expenses:, financial_aid:, work_income:, other_scholarships:)
      @tuition = tuition.to_f
      @room_and_board = room_and_board.to_f
      @books_supplies = books_supplies.to_f
      @transportation = transportation.to_f
      @personal_expenses = personal_expenses.to_f
      @financial_aid = financial_aid.to_f
      @work_income = work_income.to_f
      @other_scholarships = other_scholarships.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_cost = @tuition + @room_and_board + @books_supplies + @transportation + @personal_expenses
      total_aid = @financial_aid + @work_income + @other_scholarships
      annual_gap = total_cost - total_aid
      monthly_gap_12 = annual_gap / 12.0
      monthly_gap_9 = annual_gap / 9.0

      {
        valid: true,
        total_cost: total_cost.round(2),
        total_aid: total_aid.round(2),
        annual_gap: annual_gap.round(2),
        monthly_gap_12_months: monthly_gap_12.round(2),
        monthly_gap_9_months: monthly_gap_9.round(2),
        category_breakdown: {
          tuition: @tuition.round(2),
          room_and_board: @room_and_board.round(2),
          books_supplies: @books_supplies.round(2),
          transportation: @transportation.round(2),
          personal_expenses: @personal_expenses.round(2)
        }
      }
    end

    private

    def validate!
      @errors << "Tuition cannot be negative" if @tuition.negative?
      @errors << "Room and board cannot be negative" if @room_and_board.negative?
      @errors << "Books and supplies cannot be negative" if @books_supplies.negative?
      @errors << "Transportation cannot be negative" if @transportation.negative?
      @errors << "Personal expenses cannot be negative" if @personal_expenses.negative?
      @errors << "Financial aid cannot be negative" if @financial_aid.negative?
      @errors << "Work income cannot be negative" if @work_income.negative?
      @errors << "Other scholarships cannot be negative" if @other_scholarships.negative?
    end
  end
end
