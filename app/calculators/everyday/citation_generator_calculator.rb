# frozen_string_literal: true

module Everyday
  class CitationGeneratorCalculator
    attr_reader :errors

    VALID_SOURCE_TYPES = %w[book journal website].freeze

    def initialize(source_type:, authors: "", title: "", year: "", publisher: "", journal_name: "", volume: "", issue: "", pages: "", url: "", access_date: "")
      @source_type = source_type.to_s.strip.downcase
      @authors = authors.to_s.strip
      @title = title.to_s.strip
      @year = year.to_s.strip
      @publisher = publisher.to_s.strip
      @journal_name = journal_name.to_s.strip
      @volume = volume.to_s.strip
      @issue = issue.to_s.strip
      @pages = pages.to_s.strip
      @url = url.to_s.strip
      @access_date = access_date.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      author_list = parse_authors(@authors)

      {
        valid: true,
        apa_citation: generate_apa(author_list),
        mla_citation: generate_mla(author_list),
        chicago_citation: generate_chicago(author_list)
      }
    end

    private

    def validate!
      @errors << "Source type must be book, journal, or website" unless VALID_SOURCE_TYPES.include?(@source_type)
      @errors << "Authors cannot be empty" if @authors.empty?
      @errors << "Title cannot be empty" if @title.empty?
      @errors << "Year cannot be empty" if @year.empty?
      @errors << "Publisher is required for books" if @source_type == "book" && @publisher.empty?
      @errors << "Journal name is required for journal articles" if @source_type == "journal" && @journal_name.empty?
      @errors << "URL is required for websites" if @source_type == "website" && @url.empty?
    end

    def parse_authors(authors_str)
      authors_str.split(",").map(&:strip).reject(&:empty?)
    end

    def format_author_apa(name)
      parts = name.strip.split(/\s+/)
      return name if parts.size < 2
      last = parts.last
      initials = parts[0..-2].map { |p| "#{p[0].upcase}." }.join(" ")
      "#{last}, #{initials}"
    end

    def format_authors_apa(author_list)
      formatted = author_list.map { |a| format_author_apa(a) }
      if formatted.size == 1
        formatted.first
      elsif formatted.size == 2
        "#{formatted[0]} & #{formatted[1]}"
      elsif formatted.size <= 20
        "#{formatted[0..-2].join(', ')}, & #{formatted.last}"
      else
        "#{formatted[0..18].join(', ')}, ... #{formatted.last}"
      end
    end

    def format_author_mla_first(name)
      parts = name.strip.split(/\s+/)
      return name if parts.size < 2
      last = parts.last
      first = parts[0..-2].join(" ")
      "#{last}, #{first}"
    end

    def format_authors_mla(author_list)
      if author_list.size == 1
        format_author_mla_first(author_list.first)
      elsif author_list.size == 2
        "#{format_author_mla_first(author_list[0])}, and #{author_list[1]}"
      else
        "#{format_author_mla_first(author_list[0])}, et al."
      end
    end

    def format_authors_chicago(author_list)
      if author_list.size == 1
        format_author_mla_first(author_list.first)
      elsif author_list.size <= 3
        formatted = [ format_author_mla_first(author_list[0]) ]
        formatted += author_list[1..].map(&:strip)
        if formatted.size == 2
          "#{formatted[0]} and #{formatted[1]}"
        else
          "#{formatted[0..-2].join(', ')}, and #{formatted.last}"
        end
      else
        "#{format_author_mla_first(author_list[0])}, et al."
      end
    end

    def generate_apa(author_list)
      authors = format_authors_apa(author_list)
      case @source_type
      when "book"
        "#{authors} (#{@year}). #{italicize(@title)}. #{@publisher}."
      when "journal"
        base = "#{authors} (#{@year}). #{@title}. #{italicize(@journal_name)}"
        base += ", #{@volume}" unless @volume.empty?
        base += "(#{@issue})" unless @issue.empty?
        base += ", #{@pages}" unless @pages.empty?
        base + "."
      when "website"
        base = "#{authors} (#{@year}). #{@title}"
        base += ". Retrieved #{@access_date}," unless @access_date.empty?
        base += " from #{@url}."
        base
      end
    end

    def generate_mla(author_list)
      authors = format_authors_mla(author_list)
      case @source_type
      when "book"
        "#{authors}. #{italicize(@title)}. #{@publisher}, #{@year}."
      when "journal"
        base = "#{authors}. \"#{@title}.\" #{italicize(@journal_name)}"
        base += ", vol. #{@volume}" unless @volume.empty?
        base += ", no. #{@issue}" unless @issue.empty?
        base += ", #{@year}"
        base += ", pp. #{@pages}" unless @pages.empty?
        base + "."
      when "website"
        base = "#{authors}. \"#{@title}.\" #{italicize('Web')}, #{@year}"
        base += ", #{@url}"
        base += ". Accessed #{@access_date}" unless @access_date.empty?
        base + "."
      end
    end

    def generate_chicago(author_list)
      authors = format_authors_chicago(author_list)
      case @source_type
      when "book"
        "#{authors}. #{italicize(@title)}. #{@publisher}, #{@year}."
      when "journal"
        base = "#{authors}. \"#{@title}.\" #{italicize(@journal_name)}"
        base += " #{@volume}" unless @volume.empty?
        base += ", no. #{@issue}" unless @issue.empty?
        base += " (#{@year})"
        base += ": #{@pages}" unless @pages.empty?
        base + "."
      when "website"
        base = "#{authors}. \"#{@title}.\""
        base += " #{@year}."
        base += " #{@url}"
        base += ". Accessed #{@access_date}" unless @access_date.empty?
        base + "."
      end
    end

    def italicize(text)
      "*#{text}*"
    end
  end
end
