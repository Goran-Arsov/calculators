# frozen_string_literal: true

module Education
  class CollegeCostComparisonCalculator
    attr_reader :errors

    def initialize(
      college_a_name: "College A",
      college_a_tuition:, college_a_room_board:, college_a_fees: 0, college_a_aid: 0,
      college_b_name: "College B",
      college_b_tuition:, college_b_room_board:, college_b_fees: 0, college_b_aid: 0,
      years: 4, annual_inflation: 3.0
    )
      @college_a_name = college_a_name.to_s.strip
      @college_a_tuition = college_a_tuition.to_f
      @college_a_room_board = college_a_room_board.to_f
      @college_a_fees = college_a_fees.to_f
      @college_a_aid = college_a_aid.to_f
      @college_b_name = college_b_name.to_s.strip
      @college_b_tuition = college_b_tuition.to_f
      @college_b_room_board = college_b_room_board.to_f
      @college_b_fees = college_b_fees.to_f
      @college_b_aid = college_b_aid.to_f
      @years = years.to_i
      @annual_inflation = annual_inflation.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      college_a = calculate_college(@college_a_tuition, @college_a_room_board, @college_a_fees, @college_a_aid)
      college_b = calculate_college(@college_b_tuition, @college_b_room_board, @college_b_fees, @college_b_aid)

      difference = (college_a[:total_cost] - college_b[:total_cost]).abs
      cheaper = college_a[:total_cost] <= college_b[:total_cost] ? @college_a_name : @college_b_name

      {
        valid: true,
        college_a: college_a.merge(name: @college_a_name),
        college_b: college_b.merge(name: @college_b_name),
        difference: difference.round(2),
        cheaper: cheaper,
        years: @years,
        annual_inflation: (@annual_inflation * 100).round(2)
      }
    end

    private

    def validate!
      @errors << "College A tuition must be positive" unless @college_a_tuition > 0
      @errors << "College B tuition must be positive" unless @college_b_tuition > 0
      @errors << "Room and board cannot be negative" if @college_a_room_board < 0 || @college_b_room_board < 0
      @errors << "Financial aid cannot be negative" if @college_a_aid < 0 || @college_b_aid < 0
      @errors << "Years must be between 1 and 6" unless @years.between?(1, 6)
      @errors << "Inflation rate cannot be negative" if @annual_inflation < 0
    end

    def calculate_college(tuition, room_board, fees, aid)
      yearly_costs = []
      total_cost = 0.0

      @years.times do |year|
        inflation_factor = (1 + @annual_inflation)**year
        year_tuition = (tuition * inflation_factor).round(2)
        year_room_board = (room_board * inflation_factor).round(2)
        year_fees = (fees * inflation_factor).round(2)
        year_gross = year_tuition + year_room_board + year_fees
        year_net = [year_gross - aid, 0].max

        yearly_costs << {
          year: year + 1,
          tuition: year_tuition,
          room_board: year_room_board,
          fees: year_fees,
          aid: aid.round(2),
          gross: year_gross.round(2),
          net: year_net.round(2)
        }

        total_cost += year_net
      end

      annual_net = yearly_costs.first[:net]

      {
        annual_net: annual_net.round(2),
        total_cost: total_cost.round(2),
        yearly_costs: yearly_costs
      }
    end
  end
end
