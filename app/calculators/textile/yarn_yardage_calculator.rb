# frozen_string_literal: true

module Textile
  class YarnYardageCalculator
    attr_reader :errors

    # Average yardage (yards) by project, size, and yarn weight category
    # Columns: lace(0), fingering(1), sport(2), dk(3), worsted(4), aran(5), bulky(6), super_bulky(7)
    YARDAGE_TABLE = {
      "scarf"     => { "small"  => [ 500, 400, 350, 300, 250, 200, 180, 150 ],
                       "medium" => [ 700, 600, 500, 450, 400, 350, 300, 250 ],
                       "large"  => [ 900, 800, 700, 600, 550, 500, 400, 350 ] },
      "hat"       => { "small"  => [ 300, 250, 200, 180, 150, 130, 110, 90 ],
                       "medium" => [ 400, 350, 300, 250, 200, 180, 150, 130 ],
                       "large"  => [ 500, 450, 400, 350, 280, 250, 200, 180 ] },
      "mittens"   => { "small"  => [ 250, 200, 180, 150, 130, 110, 100, 80 ],
                       "medium" => [ 350, 300, 250, 200, 180, 150, 130, 110 ],
                       "large"  => [ 450, 400, 350, 280, 230, 200, 170, 140 ] },
      "socks"     => { "small"  => [ 250, 200, 180, 150, 130, 100, 90, 70 ],
                       "medium" => [ 400, 350, 300, 250, 200, 180, 150, 130 ],
                       "large"  => [ 500, 450, 400, 330, 280, 250, 210, 180 ] },
      "baby_blanket" => { "small"  => [ 700, 600, 500, 450, 400, 350, 300, 250 ],
                           "medium" => [ 900, 800, 700, 600, 550, 500, 450, 400 ],
                           "large"  => [ 1200, 1050, 950, 850, 800, 700, 600, 500 ] },
      "throw"     => { "small"  => [ 1200, 1050, 950, 850, 800, 700, 600, 500 ],
                       "medium" => [ 1600, 1450, 1300, 1200, 1100, 1000, 900, 800 ],
                       "large"  => [ 2000, 1800, 1650, 1500, 1400, 1250, 1100, 1000 ] },
      "sweater"   => { "small"  => [ 1200, 1000, 900, 800, 700, 650, 550, 450 ],
                       "medium" => [ 1500, 1300, 1150, 1000, 900, 800, 700, 600 ],
                       "large"  => [ 2000, 1750, 1550, 1400, 1250, 1100, 950, 800 ] },
      "cardigan"  => { "small"  => [ 1300, 1100, 1000, 900, 800, 700, 600, 500 ],
                       "medium" => [ 1700, 1500, 1350, 1200, 1050, 950, 800, 700 ],
                       "large"  => [ 2200, 1950, 1750, 1550, 1400, 1250, 1100, 900 ] },
      "shawl"     => { "small"  => [ 500, 450, 400, 350, 300, 280, 250, 200 ],
                       "medium" => [ 800, 700, 650, 600, 550, 500, 450, 400 ],
                       "large"  => [ 1200, 1100, 1000, 900, 850, 750, 650, 550 ] }
    }.freeze

    WEIGHT_NAMES = [ "Lace (0)", "Fingering (1)", "Sport (2)", "DK (3)", "Worsted (4)", "Aran (5)", "Bulky (6)", "Super Bulky (7)" ].freeze

    SIZES = %w[small medium large].freeze

    def initialize(project:, size:, weight_category:)
      @project = project.to_s
      @size = size.to_s
      @weight_category = weight_category.is_a?(Integer) ? weight_category : weight_category.to_i
      @weight_category_raw = weight_category
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      yards = YARDAGE_TABLE[@project][@size][@weight_category]
      meters = yards * 0.9144

      {
        valid: true,
        project: @project,
        size: @size,
        weight_category: @weight_category,
        weight_name: WEIGHT_NAMES[@weight_category],
        yards: yards.to_i,
        meters: meters.round(1),
        skeins_100yd: (yards / 100.0).ceil,
        skeins_200yd: (yards / 200.0).ceil
      }
    end

    private

    def validate!
      @errors << "Project must be one of: #{YARDAGE_TABLE.keys.join(', ')}" unless YARDAGE_TABLE.key?(@project)
      @errors << "Size must be small, medium, or large" unless SIZES.include?(@size)
      unless @weight_category_raw.is_a?(Integer) || @weight_category_raw.to_s.match?(/\A\d+\z/)
        @errors << "Weight category must be an integer between 0 and 7"
      end
      unless @weight_category.between?(0, 7)
        @errors << "Weight category must be between 0 and 7"
      end
    end
  end
end
