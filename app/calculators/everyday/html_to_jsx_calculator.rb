# frozen_string_literal: true

module Everyday
  class HtmlToJsxCalculator
    attr_reader :errors

    ATTRIBUTE_MAP = {
      "class" => "className",
      "for" => "htmlFor",
      "tabindex" => "tabIndex",
      "readonly" => "readOnly",
      "maxlength" => "maxLength",
      "cellpadding" => "cellPadding",
      "cellspacing" => "cellSpacing",
      "rowspan" => "rowSpan",
      "colspan" => "colSpan",
      "enctype" => "encType",
      "contenteditable" => "contentEditable",
      "crossorigin" => "crossOrigin",
      "accesskey" => "accessKey",
      "autocomplete" => "autoComplete",
      "autofocus" => "autoFocus",
      "autoplay" => "autoPlay",
      "formaction" => "formAction",
      "novalidate" => "noValidate",
      "spellcheck" => "spellCheck",
      "srcdoc" => "srcDoc",
      "srcset" => "srcSet",
      "usemap" => "useMap",
      "charset" => "charSet",
      "datetime" => "dateTime",
      "hreflang" => "hrefLang",
      "http-equiv" => "httpEquiv"
    }.freeze

    VOID_ELEMENTS = %w[area base br col embed hr img input link meta param source track wbr].freeze

    EVENT_PATTERN = /\Aon([a-z]+)\z/

    def initialize(html:)
      @html = html.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      jsx = convert_to_jsx(@html)
      changes = count_changes(@html, jsx)

      {
        valid: true,
        jsx: jsx,
        changes_made: changes,
        input_length: @html.length,
        output_length: jsx.length
      }
    end

    private

    def validate!
      @errors << "HTML cannot be empty" if @html.strip.empty?
    end

    def convert_to_jsx(html)
      result = html.dup

      # Convert HTML comments to JSX comments
      result.gsub!(/<!--(.*?)-->/m, '{/* \1 */}')

      # Self-close void elements that aren't already self-closed
      VOID_ELEMENTS.each do |tag|
        result.gsub!(%r{<(#{tag})((?:\s[^>]*)?)(?<!/)\s*>}i, '<\1\2 />')
      end

      # Convert attributes
      result.gsub!(/<([a-zA-Z][a-zA-Z0-9]*)((?:\s+[^>]*?)?)>/m) do |_match|
        tag = ::Regexp.last_match(1)
        attrs = ::Regexp.last_match(2)

        converted_attrs = convert_attributes(attrs)
        "<#{tag}#{converted_attrs}>"
      end

      result
    end

    def convert_attributes(attrs)
      return attrs if attrs.strip.empty?

      result = attrs.dup

      # Convert mapped attributes
      ATTRIBUTE_MAP.each do |html_attr, jsx_attr|
        result.gsub!(/\b#{Regexp.escape(html_attr)}(?=\s*=|\s*[>\s\/])/, jsx_attr)
      end

      # Convert event handlers (onclick -> onClick, etc.)
      result.gsub!(/\bon([a-z]+)(?=\s*=)/) do
        "on#{::Regexp.last_match(1).capitalize}"
      end

      # Convert style strings to objects: style="color: red; font-size: 14px" -> style={{color: 'red', fontSize: '14px'}}
      result.gsub!(/style\s*=\s*"([^"]*)"/) do
        css = ::Regexp.last_match(1)
        props = css.split(";").map(&:strip).reject(&:empty?).map do |prop|
          key, value = prop.split(":", 2).map(&:strip)
          camel_key = key.gsub(/-([a-z])/) { ::Regexp.last_match(1).upcase }
          "#{camel_key}: '#{value}'"
        end
        "style={{#{props.join(', ')}}}"
      end

      result
    end

    def count_changes(original, converted)
      changes = 0
      changes += (converted.scan(/className/).length - original.scan(/className/).length)
      changes += (converted.scan(/htmlFor/).length - original.scan(/htmlFor/).length)
      changes += (converted.scan(%r{\s/>}).length - original.scan(%r{\s/>}).length)
      changes += (converted.scan(/\{\/\*/).length - original.scan(/\{\/\*/).length)
      changes += (converted.scan(/style=\{\{/).length - original.scan(/style=\{\{/).length)
      [ changes, 0 ].max
    end
  end
end
