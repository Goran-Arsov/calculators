# frozen_string_literal: true

module Everyday
  class HtmlToMarkdownCalculator
    attr_reader :errors

    def initialize(html:)
      @html = html.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      require "nokogiri"
      doc = Nokogiri::HTML.fragment(@html)
      markdown = convert_node(doc).strip
      markdown = clean_whitespace(markdown)

      {
        valid: true,
        markdown: markdown,
        input_length: @html.length,
        output_length: markdown.length
      }
    rescue => e
      @errors << "Failed to parse HTML: #{e.message}"
      { valid: false, errors: @errors }
    end

    private

    def convert_node(node)
      result = +""

      node.children.each do |child|
        case child.type
        when Nokogiri::XML::Node::TEXT_NODE
          result << child.text
        when Nokogiri::XML::Node::ELEMENT_NODE
          result << convert_element(child)
        end
      end

      result
    end

    def convert_element(el)
      case el.name.downcase
      when "h1" then "\n# #{convert_node(el).strip}\n\n"
      when "h2" then "\n## #{convert_node(el).strip}\n\n"
      when "h3" then "\n### #{convert_node(el).strip}\n\n"
      when "h4" then "\n#### #{convert_node(el).strip}\n\n"
      when "h5" then "\n##### #{convert_node(el).strip}\n\n"
      when "h6" then "\n###### #{convert_node(el).strip}\n\n"
      when "p" then "\n#{convert_node(el).strip}\n\n"
      when "br" then "  \n"
      when "hr" then "\n---\n\n"
      when "strong", "b" then "**#{convert_node(el).strip}**"
      when "em", "i" then "*#{convert_node(el).strip}*"
      when "del", "s", "strike" then "~~#{convert_node(el).strip}~~"
      when "code"
        if el.parent&.name == "pre"
          convert_node(el)
        else
          "`#{convert_node(el).strip}`"
        end
      when "pre"
        code_el = el.at_css("code")
        if code_el
          lang = code_el["class"]&.match(/language-(\S+)/)&.captures&.first || ""
          "\n```#{lang}\n#{convert_node(code_el).strip}\n```\n\n"
        else
          "\n```\n#{convert_node(el).strip}\n```\n\n"
        end
      when "a"
        href = el["href"] || ""
        text = convert_node(el).strip
        "[#{text}](#{href})"
      when "img"
        alt = el["alt"] || ""
        src = el["src"] || ""
        "![#{alt}](#{src})"
      when "ul"
        items = el.css("> li").map { |li| "- #{convert_node(li).strip}" }
        "\n#{items.join("\n")}\n\n"
      when "ol"
        items = el.css("> li").each_with_index.map { |li, idx| "#{idx + 1}. #{convert_node(li).strip}" }
        "\n#{items.join("\n")}\n\n"
      when "li"
        convert_node(el)
      when "blockquote"
        lines = convert_node(el).strip.split("\n")
        quoted = lines.map { |l| "> #{l}" }.join("\n")
        "\n#{quoted}\n\n"
      when "table"
        convert_table(el)
      when "div", "section", "article", "main", "header", "footer", "span"
        convert_node(el)
      else
        convert_node(el)
      end
    end

    def convert_table(table)
      rows = table.css("tr")
      return "" if rows.empty?

      md_rows = rows.map do |tr|
        cells = tr.css("th, td").map { |cell| convert_node(cell).strip }
        "| #{cells.join(" | ")} |"
      end

      # Insert separator after header row
      if md_rows.size > 1
        col_count = rows.first.css("th, td").size
        separator = "| #{(["---"] * col_count).join(" | ")} |"
        md_rows.insert(1, separator)
      end

      "\n#{md_rows.join("\n")}\n\n"
    end

    def clean_whitespace(text)
      text.gsub(/\n{3,}/, "\n\n").strip + "\n"
    end

    def validate!
      @errors << "HTML text cannot be empty" if @html.strip.empty?
    end
  end
end
