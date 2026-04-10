# frozen_string_literal: true

module Alcohol
  # Calculates beer color in SRM (Standard Reference Method) using the Morey equation:
  #
  #   MCU  = sum( weight_lb * color_lovibond ) / batch_volume_gal
  #   SRM  = 1.4922 * MCU ** 0.6859
  #   EBC  = SRM * 1.97
  #
  # Malts are passed as an array of hashes:
  #   [{ weight_lb:, lovibond: }, ...]
  class SrmCalculator
    attr_reader :errors

    def initialize(malts:, batch_volume_gal:)
      @malts = Array(malts)
      @volume_gal = batch_volume_gal.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      malt_color_units = @malts.sum { |m| m[:weight_lb].to_f * m[:lovibond].to_f } / @volume_gal
      srm = 1.4922 * (malt_color_units ** 0.6859)
      ebc = srm * 1.97

      {
        valid: true,
        mcu: malt_color_units.round(2),
        srm: srm.round(1),
        ebc: ebc.round(1),
        beer_style: srm_to_style(srm),
        hex_color: srm_to_hex(srm)
      }
    end

    private

    def srm_to_style(srm)
      case srm
      when 0...3 then "Pale straw (light lager, witbier)"
      when 3...6 then "Straw (pilsner, kölsch, helles)"
      when 6...9 then "Pale gold (blonde ale, weissbier)"
      when 9...14 then "Deep gold (pale ale, saison)"
      when 14...17 then "Amber (amber ale, ESB, märzen)"
      when 17...22 then "Copper (amber ale, bock)"
      when 22...30 then "Brown (brown ale, dunkel)"
      when 30...40 then "Dark brown (porter, doppelbock)"
      else "Black (stout, imperial stout, schwarzbier)"
      end
    end

    # Approximate hex color from SRM (sRGB swatches widely used by brewing software).
    def srm_to_hex(srm)
      table = {
        1 => "#FFE699", 2 => "#FFD878", 3 => "#FFCA5A", 4 => "#FFBF42",
        5 => "#FBB123", 6 => "#F8A600", 7 => "#F39C00", 8 => "#EA8F00",
        9 => "#E58500", 10 => "#DE7C00", 11 => "#D77200", 12 => "#CF6900",
        13 => "#CB6200", 14 => "#C35900", 15 => "#BB5100", 16 => "#B54C00",
        17 => "#B04500", 18 => "#A63E00", 19 => "#A13700", 20 => "#9B3200",
        21 => "#952D00", 22 => "#8E2900", 23 => "#882300", 24 => "#821E00",
        25 => "#7B1A00", 26 => "#771900", 27 => "#701400", 28 => "#6A0E00",
        29 => "#660D00", 30 => "#5E0B00", 35 => "#4E0900", 40 => "#3D0708"
      }
      key = table.keys.min_by { |k| (k - srm).abs }
      table[key]
    end

    def validate!
      @errors << "Batch volume must be greater than zero" unless @volume_gal.positive?
      @errors << "At least one malt is required" if @malts.empty?

      @malts.each_with_index do |malt, i|
        @errors << "Malt ##{i + 1}: weight must be positive" unless malt[:weight_lb].to_f.positive?
        @errors << "Malt ##{i + 1}: lovibond color must be positive" unless malt[:lovibond].to_f.positive?
      end
    end
  end
end
