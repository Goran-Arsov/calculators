# frozen_string_literal: true

module Everyday
  class MarkdownToHtmlCalculator
    attr_reader :errors

    def initialize(markdown:)
      @markdown = markdown.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      html = convert_markdown_to_html(@markdown)

      {
        valid: true,
        html: html,
        input_length: @markdown.length,
        output_length: html.length
      }
    end

    private

    def convert_markdown_to_html(md)
      lines = md.lines.map(&:chomp)
      html_parts = []
      i = 0

      while i < lines.size
        line = lines[i]

        # Fenced code blocks
        if line.match?(/\A```/)
          lang = line.sub(/\A```/, "").strip
          code_lines = []
          i += 1
          while i < lines.size && !lines[i].match?(/\A```/)
            code_lines << escape_html(lines[i])
            i += 1
          end
          i += 1 # skip closing ```
          if lang.empty?
            html_parts << "<pre><code>#{code_lines.join("\n")}</code></pre>"
          else
            html_parts << "<pre><code class=\"language-#{escape_html(lang)}\">#{code_lines.join("\n")}</code></pre>"
          end
          next
        end

        # Headings
        if (m = line.match(/\A(\#{1,6})\s+(.+)/))
          level = m[1].length
          content = inline_format(m[2].strip)
          html_parts << "<h#{level}>#{content}</h#{level}>"
          i += 1
          next
        end

        # Horizontal rule
        if line.match?(/\A(\*{3,}|-{3,}|_{3,})\s*\z/)
          html_parts << "<hr>"
          i += 1
          next
        end

        # Blockquote
        if line.start_with?("> ")
          quote_lines = []
          while i < lines.size && lines[i].start_with?("> ")
            quote_lines << lines[i].sub(/\A>\s?/, "")
            i += 1
          end
          html_parts << "<blockquote><p>#{inline_format(quote_lines.join(" "))}</p></blockquote>"
          next
        end

        # Unordered list
        if line.match?(/\A\s*[-*+]\s+/)
          list_items = []
          while i < lines.size && lines[i].match?(/\A\s*[-*+]\s+/)
            list_items << inline_format(lines[i].sub(/\A\s*[-*+]\s+/, ""))
            i += 1
          end
          html_parts << "<ul>#{list_items.map { |li| "<li>#{li}</li>" }.join}</ul>"
          next
        end

        # Ordered list
        if line.match?(/\A\s*\d+\.\s+/)
          list_items = []
          while i < lines.size && lines[i].match?(/\A\s*\d+\.\s+/)
            list_items << inline_format(lines[i].sub(/\A\s*\d+\.\s+/, ""))
            i += 1
          end
          html_parts << "<ol>#{list_items.map { |li| "<li>#{li}</li>" }.join}</ol>"
          next
        end

        # Empty line
        if line.strip.empty?
          i += 1
          next
        end

        # Paragraph
        para_lines = []
        while i < lines.size && !lines[i].strip.empty? && !lines[i].match?(/\A(\#{1,6}\s|```|>\s|[-*+]\s|\d+\.\s|\*{3,}|-{3,}|_{3,})/)
          para_lines << lines[i]
          i += 1
        end
        html_parts << "<p>#{inline_format(para_lines.join(" "))}</p>"
      end

      html_parts.join("\n")
    end

    def inline_format(text)
      text = escape_html(text)
      # Images before links
      text = text.gsub(/!\[([^\]]*)\]\(([^)]+)\)/) { "<img src=\"#{$2}\" alt=\"#{$1}\">" }
      # Links
      text = text.gsub(/\[([^\]]+)\]\(([^)]+)\)/) { "<a href=\"#{$2}\">#{$1}</a>" }
      # Bold + italic
      text = text.gsub(/\*{3}(.+?)\*{3}/, '<strong><em>\1</em></strong>')
      # Bold
      text = text.gsub(/\*{2}(.+?)\*{2}/, '<strong>\1</strong>')
      text = text.gsub(/_{2}(.+?)_{2}/, '<strong>\1</strong>')
      # Italic
      text = text.gsub(/\*(.+?)\*/, '<em>\1</em>')
      text = text.gsub(/_(.+?)_/, '<em>\1</em>')
      # Inline code
      text = text.gsub(/`([^`]+)`/, '<code>\1</code>')
      # Strikethrough
      text = text.gsub(/~~(.+?)~~/, '<del>\1</del>')
      text
    end

    def escape_html(text)
      text.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
    end

    def validate!
      @errors << "Markdown text cannot be empty" if @markdown.strip.empty?
    end
  end
end
