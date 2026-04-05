# frozen_string_literal: true

module Everyday
  class MarkdownPreviewCalculator
    attr_reader :errors

    def initialize(text:)
      @text = text.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      {
        valid: true,
        html: markdown_to_html(@text),
        word_count: @text.split(/\s+/).reject(&:empty?).size,
        line_count: @text.split("\n").size,
        heading_count: @text.scan(/^#{1,6}\s/).size
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end

    def markdown_to_html(text)
      lines = text.split("\n")
      html_lines = []
      in_code_block = false
      in_list = false
      list_type = nil

      lines.each do |line|
        # Code blocks
        if line.strip.start_with?("```")
          if in_code_block
            html_lines << "</code></pre>"
            in_code_block = false
          else
            html_lines = close_list(html_lines, in_list, list_type)
            in_list = false
            html_lines << "<pre><code>"
            in_code_block = true
          end
          next
        end

        if in_code_block
          html_lines << escape_html(line)
          next
        end

        # Blank lines
        if line.strip.empty?
          html_lines = close_list(html_lines, in_list, list_type)
          in_list = false
          next
        end

        # Headings
        if line =~ /^(#{1,6})\s+(.*)/
          html_lines = close_list(html_lines, in_list, list_type)
          in_list = false
          level = $1.length
          content = inline_formatting($2)
          html_lines << "<h#{level}>#{content}</h#{level}>"
          next
        end

        # Unordered lists
        if line =~ /^\s*[-*+]\s+(.*)/
          unless in_list && list_type == :ul
            html_lines = close_list(html_lines, in_list, list_type)
            html_lines << "<ul>"
            in_list = true
            list_type = :ul
          end
          html_lines << "<li>#{inline_formatting($1)}</li>"
          next
        end

        # Ordered lists
        if line =~ /^\s*\d+\.\s+(.*)/
          unless in_list && list_type == :ol
            html_lines = close_list(html_lines, in_list, list_type)
            html_lines << "<ol>"
            in_list = true
            list_type = :ol
          end
          html_lines << "<li>#{inline_formatting($1)}</li>"
          next
        end

        # Horizontal rules
        if line =~ /^(\*{3,}|-{3,}|_{3,})$/
          html_lines = close_list(html_lines, in_list, list_type)
          in_list = false
          html_lines << "<hr>"
          next
        end

        # Regular paragraph
        html_lines = close_list(html_lines, in_list, list_type)
        in_list = false
        html_lines << "<p>#{inline_formatting(line)}</p>"
      end

      html_lines = close_list(html_lines, in_list, list_type)
      html_lines << "</code></pre>" if in_code_block

      html_lines.join("\n")
    end

    def close_list(html_lines, in_list, list_type)
      if in_list
        tag = list_type == :ol ? "ol" : "ul"
        html_lines << "</#{tag}>"
      end
      html_lines
    end

    def inline_formatting(text)
      result = escape_html(text)
      # Bold: **text** or __text__
      result = result.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
      result = result.gsub(/__(.+?)__/, '<strong>\1</strong>')
      # Italic: *text* or _text_
      result = result.gsub(/\*(.+?)\*/, '<em>\1</em>')
      result = result.gsub(/\b_(.+?)_\b/, '<em>\1</em>')
      # Inline code: `text`
      result = result.gsub(/`(.+?)`/, '<code>\1</code>')
      # Links: [text](url)
      result = result.gsub(/\[(.+?)\]\((.+?)\)/, '<a href="\2">\1</a>')
      result
    end

    def escape_html(text)
      text.gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
    end
  end
end
