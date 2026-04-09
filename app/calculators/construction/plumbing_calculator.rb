# frozen_string_literal: true

module Construction
  class PlumbingCalculator
    attr_reader :errors

    FIXTURE_UNITS = {
      toilet: 4,
      sink: 1,
      shower: 2,
      bathtub: 2,
      dishwasher: 2,
      washing_machine: 2
    }.freeze

    PIPE_SIZE_TABLE = [
      { range: 1..6, size: "3/4\"" },
      { range: 7..15, size: "1\"" },
      { range: 16..30, size: "1-1/4\"" },
      { range: 31..50, size: "1-1/2\"" }
    ].freeze

    DEFAULT_LARGE_PIPE = "2\""

    def initialize(num_toilets: 0, num_sinks: 0, num_showers: 0, num_bathtubs: 0, num_dishwashers: 0, num_washing_machines: 0)
      @num_toilets = num_toilets.to_i
      @num_sinks = num_sinks.to_i
      @num_showers = num_showers.to_i
      @num_bathtubs = num_bathtubs.to_i
      @num_dishwashers = num_dishwashers.to_i
      @num_washing_machines = num_washing_machines.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      fixture_breakdown = {
        toilets: { count: @num_toilets, units_each: FIXTURE_UNITS[:toilet], total: @num_toilets * FIXTURE_UNITS[:toilet] },
        sinks: { count: @num_sinks, units_each: FIXTURE_UNITS[:sink], total: @num_sinks * FIXTURE_UNITS[:sink] },
        showers: { count: @num_showers, units_each: FIXTURE_UNITS[:shower], total: @num_showers * FIXTURE_UNITS[:shower] },
        bathtubs: { count: @num_bathtubs, units_each: FIXTURE_UNITS[:bathtub], total: @num_bathtubs * FIXTURE_UNITS[:bathtub] },
        dishwashers: { count: @num_dishwashers, units_each: FIXTURE_UNITS[:dishwasher], total: @num_dishwashers * FIXTURE_UNITS[:dishwasher] },
        washing_machines: { count: @num_washing_machines, units_each: FIXTURE_UNITS[:washing_machine], total: @num_washing_machines * FIXTURE_UNITS[:washing_machine] }
      }

      total_units = fixture_breakdown.values.sum { |v| v[:total] }
      recommended_main_pipe_size = determine_pipe_size(total_units)
      supply_line_size = total_units >= 20 ? "1\"" : "3/4\""

      {
        valid: true,
        total_fixture_units: total_units,
        recommended_main_pipe_size: recommended_main_pipe_size,
        supply_line_size: supply_line_size,
        fixture_breakdown: fixture_breakdown
      }
    end

    private

    def validate!
      @errors << "Number of toilets cannot be negative" if @num_toilets.negative?
      @errors << "Number of sinks cannot be negative" if @num_sinks.negative?
      @errors << "Number of showers cannot be negative" if @num_showers.negative?
      @errors << "Number of bathtubs cannot be negative" if @num_bathtubs.negative?
      @errors << "Number of dishwashers cannot be negative" if @num_dishwashers.negative?
      @errors << "Number of washing machines cannot be negative" if @num_washing_machines.negative?
      total = @num_toilets + @num_sinks + @num_showers + @num_bathtubs + @num_dishwashers + @num_washing_machines
      @errors << "At least one fixture is required" if total.zero? && @errors.empty?
    end

    def determine_pipe_size(units)
      PIPE_SIZE_TABLE.each do |entry|
        return entry[:size] if entry[:range].cover?(units)
      end
      DEFAULT_LARGE_PIPE
    end
  end
end
