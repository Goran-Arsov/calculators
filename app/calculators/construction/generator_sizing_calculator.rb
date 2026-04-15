# frozen_string_literal: true

module Construction
  class GeneratorSizingCalculator
    attr_reader :errors

    # Common household appliance running and starting wattages.
    # Starting watts = typical inrush for motor loads (about 2-3× running
    # for most induction motors). Resistive loads have starting = running.
    APPLIANCES = {
      "fridge"         => { running: 700,  starting: 2200, label: "Refrigerator" },
      "freezer"        => { running: 500,  starting: 1500, label: "Chest freezer" },
      "furnace_blower" => { running: 800,  starting: 2400, label: "Furnace blower motor" },
      "well_pump_1hp"  => { running: 1200, starting: 3600, label: "Well pump (1 HP)" },
      "ac_1ton"        => { running: 1500, starting: 4500, label: "AC / heat pump 1-ton" },
      "ac_2ton"        => { running: 3000, starting: 9000, label: "AC / heat pump 2-ton" },
      "ac_3ton"        => { running: 4500, starting: 13500, label: "AC / heat pump 3-ton" },
      "sump_pump"      => { running: 800,  starting: 2400, label: "Sump pump (1/2 HP)" },
      "dishwasher"     => { running: 1500, starting: 1500, label: "Dishwasher" },
      "microwave"      => { running: 1200, starting: 1200, label: "Microwave" },
      "electric_range" => { running: 3000, starting: 3000, label: "Electric range (one burner)" },
      "water_heater"   => { running: 4500, starting: 4500, label: "Electric water heater (1 element)" },
      "washer"         => { running: 500,  starting: 1500, label: "Washing machine" },
      "dryer_electric" => { running: 5500, starting: 6750, label: "Electric dryer" },
      "dryer_gas"      => { running: 700,  starting: 1800, label: "Gas dryer" },
      "lighting"       => { running: 200,  starting: 200,  label: "LED lighting (whole house)" },
      "tv"             => { running: 150,  starting: 150,  label: "TV + entertainment" },
      "computer"       => { running: 300,  starting: 300,  label: "Computer + monitor" },
      "small_loads"    => { running: 500,  starting: 500,  label: "Small outlets (phone chargers, etc.)" }
    }.freeze

    def initialize(appliance_counts:, headroom_pct: 20.0)
      # appliance_counts: { "fridge" => 1, "ac_2ton" => 1, ... }
      @counts = appliance_counts || {}
      @headroom_pct = headroom_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_running = 0
      peak_surge = 0 # running watts for all + the biggest starting delta
      biggest_start_delta = 0

      @counts.each do |key, count|
        next if count.to_i <= 0
        app = APPLIANCES[key.to_s]
        next unless app

        qty = count.to_i
        run = app[:running] * qty
        start_delta = (app[:starting] - app[:running]) * 1 # only one motor starts at a time
        total_running += run
        biggest_start_delta = start_delta if start_delta > biggest_start_delta
      end

      peak_surge = total_running + biggest_start_delta
      recommended_with_headroom = peak_surge * (1 + @headroom_pct / 100.0)

      {
        valid: true,
        total_running_watts: total_running.round(0),
        peak_surge_watts: peak_surge.round(0),
        recommended_watts: recommended_with_headroom.round(0),
        recommended_kw: (recommended_with_headroom / 1000.0).round(2),
        headroom_pct: @headroom_pct.round(0)
      }
    end

    private

    def validate!
      @errors << "Headroom percent cannot be negative" if @headroom_pct.negative?
      if @counts.empty? || @counts.values.none? { |v| v.to_i.positive? }
        @errors << "Select at least one appliance"
      end
    end
  end
end
