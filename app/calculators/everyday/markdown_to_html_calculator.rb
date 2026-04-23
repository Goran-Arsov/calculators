# frozen_string_literal: true

module Everyday
  class MarkdownToHtmlCalculator
    FENCE_RE      = /\A```/
    HEADING_RE    = /\A(\#{1,6})\s+(.+)/
    HR_RE         = /\A(\*{3,}|-{3,}|_{3,})\s*\z/
    UL_RE         = /\A\s*[-*+]\s+/
    OL_RE         = /\A\s*\d+\.\s+/
    UL_STRIP_RE   = /\A\s*[-*+]\s+/
    OL_STRIP_RE   = /\A\s*\d+\.\s+/
    BLOCK_START_RE = %r{\A(\#{1,6}\s|```|>\s|[-*+]\s|\d+\.\s|\*{3,}|-{3,}|_{3,})}

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
        part, i = parse_block(lines, i)
        html_parts << part if part
      end

      html_parts.join("\n")
    end

    def parse_block(lines, i)
      line = lines[i]

      return parse_fence_code(lines, i)   if line.match?(FENCE_RE)
      return [ parse_heading(line), i + 1 ] if line.match?(HEADING_RE)
      return [ "<hr>", i + 1 ]              if line.match?(HR_RE)
      return parse_blockquote(lines, i)   if line.start_with?("> ")
      return parse_unordered_list(lines, i) if line.match?(UL_RE)
      return parse_ordered_list(lines, i)   if line.match?(OL_RE)
      return [ nil, i + 1 ]                 if line.strip.empty?

      parse_paragraph(lines, i)
    end

    def parse_fence_code(lines, i)
      lang = lines[i].sub(FENCE_RE, "").strip
      code_lines = []
      i += 1
      while i < lines.size && !lines[i].match?(FENCE_RE)
        code_lines << escape_html(lines[i])
        i += 1
      end
      i += 1 # skip closing ```
      [ build_code_block(lang, code_lines), i ]
    end

    def build_code_block(lang, code_lines)
      body = code_lines.join("\n")
      return "<pre><code>#{body}</code></pre>" if lang.empty?

      "<pre><code class=\"language-#{escape_html(lang)}\">#{body}</code></pre>"
    end

    def parse_heading(line)
      m = line.match(HEADING_RE)
      level = m[1].length
      content = inline_format(m[2].strip)
      "<h#{level}>#{content}</h#{level}>"
    end

    def parse_blockquote(lines, i)
      quote_lines = []
      while i < lines.size && lines[i].start_with?("> ")
        quote_lines << lines[i].sub(/\A>\s?/, "")
        i += 1
      end
      [ "<blockquote><p>#{inline_format(quote_lines.join(" "))}</p></blockquote>", i ]
    end

    def parse_unordered_list(lines, i)
      parse_list(lines, i, match_re: UL_RE, strip_re: UL_STRIP_RE, tag: "ul")
    end

    def parse_ordered_list(lines, i)
      parse_list(lines, i, match_re: OL_RE, strip_re: OL_STRIP_RE, tag: "ol")
    end

    def parse_list(lines, i, match_re:, strip_re:, tag:)
      list_items = []
      while i < lines.size && lines[i].match?(match_re)
        list_items << inline_format(lines[i].sub(strip_re, ""))
        i += 1
      end
      items_html = list_items.map { |li| "<li>#{li}</li>" }.join
      [ "<#{tag}>#{items_html}</#{tag}>", i ]
    end

    def parse_paragraph(lines, i)
      para_lines = []
      while i < lines.size && !lines[i].strip.empty? && !lines[i].match?(BLOCK_START_RE)
        para_lines << lines[i]
        i += 1
      end
      [ "<p>#{inline_format(para_lines.join(" "))}</p>", i ]
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
