# frozen_string_literal: true

module Everyday
  class TailwindToCssCalculator
    # Converts a single Tailwind utility class to CSS declarations.
    # Returns nil when no mapping is found — the caller annotates the result.
    class ClassConverter
      include Mappings

      def self.call(cls)
        new.call(cls)
      end

      def call(cls)
        return Mappings::STATIC_MAPPINGS[cls] if Mappings::STATIC_MAPPINGS.key?(cls)

        convert_dynamic(cls)
      end

      private

      def convert_dynamic(cls)
        case cls
        when /\Ap-(.+)\z/        then spacing("padding", Regexp.last_match(1))
        when /\Apx-(.+)\z/       then spacing_axis("padding-left", "padding-right", Regexp.last_match(1))
        when /\Apy-(.+)\z/       then spacing_axis("padding-top", "padding-bottom", Regexp.last_match(1))
        when /\Apt-(.+)\z/       then spacing("padding-top", Regexp.last_match(1))
        when /\Apr-(.+)\z/       then spacing("padding-right", Regexp.last_match(1))
        when /\Apb-(.+)\z/       then spacing("padding-bottom", Regexp.last_match(1))
        when /\Apl-(.+)\z/       then spacing("padding-left", Regexp.last_match(1))
        when /\Am-(.+)\z/        then spacing("margin", Regexp.last_match(1))
        when /\Amx-(.+)\z/       then spacing_axis("margin-left", "margin-right", Regexp.last_match(1))
        when /\Amy-(.+)\z/       then spacing_axis("margin-top", "margin-bottom", Regexp.last_match(1))
        when /\Amt-(.+)\z/       then spacing("margin-top", Regexp.last_match(1))
        when /\Amr-(.+)\z/       then spacing("margin-right", Regexp.last_match(1))
        when /\Amb-(.+)\z/       then spacing("margin-bottom", Regexp.last_match(1))
        when /\Aml-(.+)\z/       then spacing("margin-left", Regexp.last_match(1))
        when /\Aw-(.+)\z/        then dimension("width", Regexp.last_match(1))
        when /\Ah-(.+)\z/        then dimension("height", Regexp.last_match(1))
        when /\Amin-w-(.+)\z/    then dimension("min-width", Regexp.last_match(1))
        when /\Amin-h-(.+)\z/    then dimension("min-height", Regexp.last_match(1))
        when /\Amax-w-(.+)\z/    then max_width(Regexp.last_match(1))
        when /\Amax-h-(.+)\z/    then dimension("max-height", Regexp.last_match(1))
        when /\Agap-(.+)\z/      then spacing("gap", Regexp.last_match(1))
        when /\Agap-x-(.+)\z/    then spacing("column-gap", Regexp.last_match(1))
        when /\Agap-y-(.+)\z/    then spacing("row-gap", Regexp.last_match(1))
        when /\Atext-(xs|sm|base|lg|xl|[2-9]xl)\z/
          font_size(Regexp.last_match(1))
        when /\Afont-(thin|extralight|light|normal|medium|semibold|bold|extrabold|black)\z/
          weight = Mappings::FONT_WEIGHT_SCALE[Regexp.last_match(1)]
          "font-weight: #{weight};" if weight
        when "rounded"
          "border-radius: #{Mappings::BORDER_RADIUS_SCALE['DEFAULT']};"
        when /\Arounded-(none|sm|md|lg|xl|2xl|3xl|full)\z/
          val = Mappings::BORDER_RADIUS_SCALE[Regexp.last_match(1)]
          "border-radius: #{val};" if val
        when "border"            then "border-width: 1px;"
        when /\Aborder-(\d+)\z/  then "border-width: #{Regexp.last_match(1)}px;"
        when /\Aopacity-(\d+)\z/
          val = Regexp.last_match(1).to_i
          "opacity: #{val / 100.0};"
        when /\Az-(\d+|auto)\z/  then "z-index: #{Regexp.last_match(1)};"
        when /\Atop-(.+)\z/      then spacing("top", Regexp.last_match(1))
        when /\Aright-(.+)\z/    then spacing("right", Regexp.last_match(1))
        when /\Abottom-(.+)\z/   then spacing("bottom", Regexp.last_match(1))
        when /\Aleft-(.+)\z/     then spacing("left", Regexp.last_match(1))
        when /\Ainset-(.+)\z/
          val = Mappings::SPACING_SCALE[Regexp.last_match(1)]
          "top: #{val};\nright: #{val};\nbottom: #{val};\nleft: #{val};" if val
        when /\Agrid-cols-(\d+)\z/
          "grid-template-columns: repeat(#{Regexp.last_match(1)}, minmax(0, 1fr));"
        when /\Acol-span-(\d+)\z/
          "grid-column: span #{Regexp.last_match(1)} / span #{Regexp.last_match(1)};"
        when /\Agrid-rows-(\d+)\z/
          "grid-template-rows: repeat(#{Regexp.last_match(1)}, minmax(0, 1fr));"
        when /\Arow-span-(\d+)\z/
          "grid-row: span #{Regexp.last_match(1)} / span #{Regexp.last_match(1)};"
        when /\Aduration-(\d+)\z/ then "transition-duration: #{Regexp.last_match(1)}ms;"
        when /\Aleading-(\d+)\z/  then "line-height: #{Regexp.last_match(1).to_f * 0.25}rem;"
        when "leading-none"       then "line-height: 1;"
        when "leading-tight"      then "line-height: 1.25;"
        when "leading-snug"       then "line-height: 1.375;"
        when "leading-normal"     then "line-height: 1.5;"
        when "leading-relaxed"    then "line-height: 1.625;"
        when "leading-loose"      then "line-height: 2;"
        when "tracking-tighter"   then "letter-spacing: -0.05em;"
        when "tracking-tight"     then "letter-spacing: -0.025em;"
        when "tracking-normal"    then "letter-spacing: 0em;"
        when "tracking-wide"      then "letter-spacing: 0.025em;"
        when "tracking-wider"     then "letter-spacing: 0.05em;"
        when "tracking-widest"    then "letter-spacing: 0.1em;"
        end
      end

      def spacing(property, value)
        val = Mappings::SPACING_SCALE[value]
        "#{property}: #{val};" if val
      end

      def spacing_axis(prop1, prop2, value)
        val = Mappings::SPACING_SCALE[value]
        "#{prop1}: #{val};\n#{prop2}: #{val};" if val
      end

      def dimension(property, value)
        val = Mappings::SPACING_SCALE[value]
        val ||= "#{value}%" if value =~ /\A\d+\/\d+\z/
        "#{property}: #{val};" if val
      end

      def max_width(value)
        val = Mappings::MAX_WIDTH_SCALE[value]
        "max-width: #{val};" if val
      end

      def font_size(value)
        size = Mappings::FONT_SIZE_SCALE[value]
        "font-size: #{size[0]};\nline-height: #{size[1]};" if size
      end
    end
  end
end
