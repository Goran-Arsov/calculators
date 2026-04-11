# frozen_string_literal: true

module Construction
  class WaterHeaterSizingCalculator
    attr_reader :errors

    # Peak-hour gallon demand per fixture use (ASHRAE 2019, GAMA water heater
    # sizing guide). Tank water heaters are sized by First-Hour Rating (FHR)
    # which should meet or exceed the household's peak hour demand.
    FIXTURE_GALLONS = {
      shower: 10.0,
      bath: 20.0,
      shave: 2.0,
      hand_wash: 2.0,
      kitchen_sink: 4.0,
      dishwasher: 6.0,
      clothes_washer: 7.0
    }.freeze

    # Recommended tank sizes when using people + bathroom rule-of-thumb.
    TANK_SIZE_TABLE = [
      { people: 1..2, baths: 1..1, gallons: 30 },
      { people: 1..2, baths: 2..99, gallons: 40 },
      { people: 3..3, baths: 1..1, gallons: 40 },
      { people: 3..3, baths: 2..99, gallons: 50 },
      { people: 4..4, baths: 1..2, gallons: 50 },
      { people: 4..4, baths: 3..99, gallons: 75 },
      { people: 5..6, baths: 1..99, gallons: 75 },
      { people: 7..99, baths: 1..99, gallons: 80 }
    ].freeze

    TANKLESS_FLOW_RATES_GPM = {
      shower: 2.5,
      bath: 4.0,
      kitchen_sink: 1.5,
      hand_wash: 1.0,
      dishwasher: 1.5,
      clothes_washer: 2.0
    }.freeze

    def initialize(people:, bathrooms:, showers: nil, baths: nil, dishwasher: false,
                   clothes_washer: false)
      @people = people.to_i
      @bathrooms = bathrooms.to_i
      @showers = (showers || @people).to_i
      @baths = baths.to_i
      @dishwasher = dishwasher == true || dishwasher.to_s == "true"
      @clothes_washer = clothes_washer == true || clothes_washer.to_s == "true"
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      peak_gallons = compute_peak_demand
      recommended_tank = lookup_tank_size
      tankless_gpm = compute_tankless_gpm

      {
        valid: true,
        peak_hour_gallons: peak_gallons.round(1),
        recommended_tank_gallons: recommended_tank,
        required_fhr_gallons: peak_gallons.round(1),
        tankless_gpm_required: tankless_gpm.round(1)
      }
    end

    private

    def compute_peak_demand
      total = 0.0
      total += @showers * FIXTURE_GALLONS[:shower]
      total += @baths * FIXTURE_GALLONS[:bath]
      total += @people * FIXTURE_GALLONS[:hand_wash]
      total += FIXTURE_GALLONS[:kitchen_sink]
      total += FIXTURE_GALLONS[:dishwasher] if @dishwasher
      total += FIXTURE_GALLONS[:clothes_washer] if @clothes_washer
      total
    end

    def lookup_tank_size
      row = TANK_SIZE_TABLE.find { |r| r[:people].cover?(@people) && r[:baths].cover?(@bathrooms) }
      row ? row[:gallons] : 80
    end

    def compute_tankless_gpm
      # Assume two simultaneous fixtures at peak (common sizing assumption).
      gpm = TANKLESS_FLOW_RATES_GPM[:shower] * 2
      gpm += TANKLESS_FLOW_RATES_GPM[:kitchen_sink] if @dishwasher || @clothes_washer
      gpm
    end

    def validate!
      @errors << "Number of people must be at least 1" unless @people >= 1
      @errors << "Number of bathrooms must be at least 1" unless @bathrooms >= 1
    end
  end
end
