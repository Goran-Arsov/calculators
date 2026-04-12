# frozen_string_literal: true

module Education
  class ResearchPaperWordCountCalculator
    attr_reader :errors

    VALID_FONTS = %w[times_new_roman arial calibri courier georgia verdana].freeze
    VALID_SPACINGS = %w[single 1.5 double].freeze

    # Words per page lookup: [font][spacing]
    # Based on standard 1-inch margins, 12pt font
    WORDS_PER_PAGE = {
      "times_new_roman" => { "single" => 500, "1.5" => 375, "double" => 250 },
      "arial" => { "single" => 450, "1.5" => 338, "double" => 225 },
      "calibri" => { "single" => 470, "1.5" => 353, "double" => 235 },
      "courier" => { "single" => 420, "1.5" => 315, "double" => 210 },
      "georgia" => { "single" => 470, "1.5" => 353, "double" => 235 },
      "verdana" => { "single" => 400, "1.5" => 300, "double" => 200 }
    }.freeze

    MARGIN_FACTORS = {
      "1_inch" => 1.0,
      "1.25_inch" => 0.92,
      "1.5_inch" => 0.84,
      "0.75_inch" => 1.10
    }.freeze

    FONT_SIZE_FACTORS = {
      10 => 1.20,
      11 => 1.10,
      12 => 1.00,
      13 => 0.92,
      14 => 0.85
    }.freeze

    def initialize(page_count:, font: "times_new_roman", spacing: "double", margins: "1_inch", font_size: 12, has_references: false, reference_pages: 0)
      @page_count = page_count.to_f
      @font = font.to_s.downcase.strip
      @spacing = spacing.to_s.strip
      @margins = margins.to_s.strip
      @font_size = font_size.to_i
      @has_references = has_references
      @reference_pages = reference_pages.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      content_pages = @has_references ? [@page_count - @reference_pages, 0].max : @page_count
      base_wpp = WORDS_PER_PAGE.dig(@font, @spacing) || 250
      margin_factor = MARGIN_FACTORS.fetch(@margins, 1.0)
      size_factor = FONT_SIZE_FACTORS.fetch(@font_size, 1.0)

      adjusted_wpp = (base_wpp * margin_factor * size_factor).round(0)
      estimated_words = (content_pages * adjusted_wpp).round(0)

      # Reading and writing time estimates
      reading_time_minutes = (estimated_words / 238.0).round(1)
      speaking_time_minutes = (estimated_words / 150.0).round(1)

      # Typical academic structure
      paragraphs = (estimated_words / 150.0).round(0)
      sentences = (estimated_words / 20.0).round(0)

      {
        valid: true,
        estimated_words: estimated_words.to_i,
        words_per_page: adjusted_wpp.to_i,
        content_pages: content_pages.round(1),
        total_pages: @page_count,
        font: @font,
        spacing: @spacing,
        margins: @margins,
        font_size: @font_size,
        reading_time_minutes: reading_time_minutes,
        speaking_time_minutes: speaking_time_minutes,
        estimated_paragraphs: paragraphs.to_i,
        estimated_sentences: sentences.to_i,
        reference_pages: @has_references ? @reference_pages : 0
      }
    end

    private

    def validate!
      @errors << "Page count must be positive" unless @page_count > 0
      @errors << "Invalid font" unless VALID_FONTS.include?(@font)
      @errors << "Invalid spacing" unless VALID_SPACINGS.include?(@spacing)
      @errors << "Invalid font size (must be 10-14)" unless FONT_SIZE_FACTORS.key?(@font_size)
      @errors << "Reference pages cannot exceed total pages" if @has_references && @reference_pages >= @page_count
    end
  end
end
