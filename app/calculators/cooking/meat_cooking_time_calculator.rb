# frozen_string_literal: true

module Cooking
  class MeatCookingTimeCalculator
    attr_reader :errors

    # Cooking time data: minutes per pound at standard oven temp (325-350 F)
    # Structure: { meat_type => { cut => { doneness => { method => { minutes_per_lb:, internal_temp_f: } } } } }
    COOKING_DATA = {
      "beef" => {
        "roast" => {
          "rare" => { "oven" => { minutes_per_lb: 15, internal_temp_f: 125 }, "grill" => { minutes_per_lb: 13, internal_temp_f: 125 } },
          "medium_rare" => { "oven" => { minutes_per_lb: 18, internal_temp_f: 135 }, "grill" => { minutes_per_lb: 16, internal_temp_f: 135 } },
          "medium" => { "oven" => { minutes_per_lb: 20, internal_temp_f: 145 }, "grill" => { minutes_per_lb: 18, internal_temp_f: 145 } },
          "medium_well" => { "oven" => { minutes_per_lb: 23, internal_temp_f: 155 }, "grill" => { minutes_per_lb: 21, internal_temp_f: 155 } },
          "well_done" => { "oven" => { minutes_per_lb: 27, internal_temp_f: 165 }, "grill" => { minutes_per_lb: 25, internal_temp_f: 165 } }
        },
        "steak" => {
          "rare" => { "oven" => { minutes_per_lb: 12, internal_temp_f: 125 }, "grill" => { minutes_per_lb: 10, internal_temp_f: 125 } },
          "medium_rare" => { "oven" => { minutes_per_lb: 15, internal_temp_f: 135 }, "grill" => { minutes_per_lb: 12, internal_temp_f: 135 } },
          "medium" => { "oven" => { minutes_per_lb: 18, internal_temp_f: 145 }, "grill" => { minutes_per_lb: 14, internal_temp_f: 145 } },
          "medium_well" => { "oven" => { minutes_per_lb: 22, internal_temp_f: 155 }, "grill" => { minutes_per_lb: 17, internal_temp_f: 155 } },
          "well_done" => { "oven" => { minutes_per_lb: 25, internal_temp_f: 165 }, "grill" => { minutes_per_lb: 20, internal_temp_f: 165 } }
        },
        "brisket" => {
          "well_done" => { "oven" => { minutes_per_lb: 60, internal_temp_f: 200 }, "smoker" => { minutes_per_lb: 75, internal_temp_f: 200 } }
        }
      },
      "pork" => {
        "roast" => {
          "medium" => { "oven" => { minutes_per_lb: 20, internal_temp_f: 145 }, "grill" => { minutes_per_lb: 18, internal_temp_f: 145 } },
          "well_done" => { "oven" => { minutes_per_lb: 26, internal_temp_f: 160 }, "grill" => { minutes_per_lb: 24, internal_temp_f: 160 } }
        },
        "chops" => {
          "medium" => { "oven" => { minutes_per_lb: 18, internal_temp_f: 145 }, "grill" => { minutes_per_lb: 15, internal_temp_f: 145 } },
          "well_done" => { "oven" => { minutes_per_lb: 23, internal_temp_f: 160 }, "grill" => { minutes_per_lb: 20, internal_temp_f: 160 } }
        },
        "ribs" => {
          "well_done" => { "oven" => { minutes_per_lb: 40, internal_temp_f: 190 }, "smoker" => { minutes_per_lb: 60, internal_temp_f: 190 } }
        },
        "pulled_pork" => {
          "well_done" => { "oven" => { minutes_per_lb: 55, internal_temp_f: 200 }, "smoker" => { minutes_per_lb: 75, internal_temp_f: 200 } }
        }
      },
      "chicken" => {
        "whole" => {
          "well_done" => { "oven" => { minutes_per_lb: 20, internal_temp_f: 165 }, "grill" => { minutes_per_lb: 18, internal_temp_f: 165 } }
        },
        "breast" => {
          "well_done" => { "oven" => { minutes_per_lb: 22, internal_temp_f: 165 }, "grill" => { minutes_per_lb: 18, internal_temp_f: 165 } }
        },
        "thigh" => {
          "well_done" => { "oven" => { minutes_per_lb: 25, internal_temp_f: 175 }, "grill" => { minutes_per_lb: 22, internal_temp_f: 175 } }
        }
      },
      "turkey" => {
        "whole" => {
          "well_done" => { "oven" => { minutes_per_lb: 15, internal_temp_f: 165 }, "smoker" => { minutes_per_lb: 30, internal_temp_f: 165 } }
        },
        "breast" => {
          "well_done" => { "oven" => { minutes_per_lb: 20, internal_temp_f: 165 }, "smoker" => { minutes_per_lb: 35, internal_temp_f: 165 } }
        }
      },
      "lamb" => {
        "leg" => {
          "rare" => { "oven" => { minutes_per_lb: 15, internal_temp_f: 125 }, "grill" => { minutes_per_lb: 13, internal_temp_f: 125 } },
          "medium_rare" => { "oven" => { minutes_per_lb: 18, internal_temp_f: 135 }, "grill" => { minutes_per_lb: 16, internal_temp_f: 135 } },
          "medium" => { "oven" => { minutes_per_lb: 20, internal_temp_f: 145 }, "grill" => { minutes_per_lb: 18, internal_temp_f: 145 } },
          "well_done" => { "oven" => { minutes_per_lb: 25, internal_temp_f: 170 }, "grill" => { minutes_per_lb: 23, internal_temp_f: 170 } }
        },
        "rack" => {
          "rare" => { "oven" => { minutes_per_lb: 12, internal_temp_f: 125 }, "grill" => { minutes_per_lb: 10, internal_temp_f: 125 } },
          "medium_rare" => { "oven" => { minutes_per_lb: 15, internal_temp_f: 135 }, "grill" => { minutes_per_lb: 13, internal_temp_f: 135 } },
          "medium" => { "oven" => { minutes_per_lb: 18, internal_temp_f: 145 }, "grill" => { minutes_per_lb: 16, internal_temp_f: 145 } },
          "well_done" => { "oven" => { minutes_per_lb: 22, internal_temp_f: 170 }, "grill" => { minutes_per_lb: 20, internal_temp_f: 170 } }
        },
        "chops" => {
          "rare" => { "oven" => { minutes_per_lb: 10, internal_temp_f: 125 }, "grill" => { minutes_per_lb: 8, internal_temp_f: 125 } },
          "medium_rare" => { "oven" => { minutes_per_lb: 13, internal_temp_f: 135 }, "grill" => { minutes_per_lb: 11, internal_temp_f: 135 } },
          "medium" => { "oven" => { minutes_per_lb: 16, internal_temp_f: 145 }, "grill" => { minutes_per_lb: 14, internal_temp_f: 145 } },
          "well_done" => { "oven" => { minutes_per_lb: 20, internal_temp_f: 170 }, "grill" => { minutes_per_lb: 18, internal_temp_f: 170 } }
        }
      }
    }.freeze

    def initialize(meat_type:, cut:, weight_lbs:, doneness:, method:)
      @meat_type = meat_type.to_s.strip
      @cut = cut.to_s.strip
      @weight_lbs = weight_lbs.to_f
      @doneness = doneness.to_s.strip
      @method = method.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      data = COOKING_DATA[@meat_type][@cut][@doneness][@method]
      total_minutes = (data[:minutes_per_lb] * @weight_lbs).round(0)
      hours = total_minutes / 60
      minutes = total_minutes % 60

      {
        valid: true,
        meat_type: @meat_type,
        cut: @cut,
        weight_lbs: @weight_lbs,
        doneness: @doneness,
        method: @method,
        minutes_per_lb: data[:minutes_per_lb],
        internal_temp_f: data[:internal_temp_f],
        total_minutes: total_minutes,
        hours: hours,
        minutes: minutes,
        rest_time_minutes: rest_time
      }
    end

    def self.available_options
      COOKING_DATA
    end

    private

    def validate!
      @errors << "Weight must be positive" unless @weight_lbs > 0
      unless COOKING_DATA.key?(@meat_type)
        @errors << "Unknown meat type: #{@meat_type}"
        return
      end
      unless COOKING_DATA[@meat_type].key?(@cut)
        @errors << "Unknown cut for #{@meat_type}: #{@cut}"
        return
      end
      unless COOKING_DATA[@meat_type][@cut].key?(@doneness)
        @errors << "Doneness '#{@doneness}' not available for #{@meat_type} #{@cut}"
        return
      end
      unless COOKING_DATA[@meat_type][@cut][@doneness].key?(@method)
        @errors << "Method '#{@method}' not available for #{@meat_type} #{@cut} #{@doneness}"
      end
    end

    def rest_time
      case @meat_type
      when "beef"
        @weight_lbs >= 3 ? 20 : 10
      when "pork"
        @cut == "pulled_pork" ? 30 : 10
      when "turkey"
        @weight_lbs >= 10 ? 30 : 20
      when "lamb"
        15
      else
        10
      end
    end
  end
end
