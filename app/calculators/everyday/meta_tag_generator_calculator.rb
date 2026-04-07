# frozen_string_literal: true

module Everyday
  class MetaTagGeneratorCalculator
    attr_reader :errors

    def initialize(title: "", description: "", keywords: "", author: "", viewport: "width=device-width, initial-scale=1.0", robots: "index, follow", og_title: "", og_description: "", og_image: "", og_url: "", twitter_card: "summary_large_image")
      @title = title.to_s.strip
      @description = description.to_s.strip
      @keywords = keywords.to_s.strip
      @author = author.to_s.strip
      @viewport = viewport.to_s.strip
      @robots = robots.to_s.strip
      @og_title = og_title.to_s.strip
      @og_description = og_description.to_s.strip
      @og_image = og_image.to_s.strip
      @og_url = og_url.to_s.strip
      @twitter_card = twitter_card.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      tags = build_tags
      {
        valid: true,
        html: tags,
        title_length: @title.length,
        description_length: @description.length,
        title_status: title_status,
        description_status: description_status
      }
    end

    private

    def validate!
      @errors << "Title cannot be empty" if @title.empty?
    end

    def title_status
      if @title.length <= 60
        "good"
      elsif @title.length <= 70
        "warning"
      else
        "too_long"
      end
    end

    def description_status
      return "empty" if @description.empty?

      if @description.length <= 160
        "good"
      elsif @description.length <= 180
        "warning"
      else
        "too_long"
      end
    end

    def build_tags
      lines = []
      lines << %(<title>#{escape(@title)}</title>)
      lines << %(<meta name="description" content="#{escape(@description)}">)  unless @description.empty?
      lines << %(<meta name="keywords" content="#{escape(@keywords)}">)        unless @keywords.empty?
      lines << %(<meta name="author" content="#{escape(@author)}">)            unless @author.empty?
      lines << %(<meta name="viewport" content="#{escape(@viewport)}">)        unless @viewport.empty?
      lines << %(<meta name="robots" content="#{escape(@robots)}">)            unless @robots.empty?

      # Open Graph
      og_title_val = @og_title.empty? ? @title : @og_title
      og_desc_val = @og_description.empty? ? @description : @og_description

      lines << ""
      lines << "<!-- Open Graph -->"
      lines << %(<meta property="og:title" content="#{escape(og_title_val)}">)
      lines << %(<meta property="og:description" content="#{escape(og_desc_val)}">)  unless og_desc_val.empty?
      lines << %(<meta property="og:image" content="#{escape(@og_image)}">)          unless @og_image.empty?
      lines << %(<meta property="og:url" content="#{escape(@og_url)}">)              unless @og_url.empty?
      lines << %(<meta property="og:type" content="website">)

      # Twitter Card
      lines << ""
      lines << "<!-- Twitter Card -->"
      lines << %(<meta name="twitter:card" content="#{escape(@twitter_card)}">)
      lines << %(<meta name="twitter:title" content="#{escape(og_title_val)}">)
      lines << %(<meta name="twitter:description" content="#{escape(og_desc_val)}">) unless og_desc_val.empty?
      lines << %(<meta name="twitter:image" content="#{escape(@og_image)}">)         unless @og_image.empty?

      lines.join("\n")
    end

    def escape(text)
      text.gsub("&", "&amp;").gsub('"', "&quot;").gsub("<", "&lt;").gsub(">", "&gt;")
    end
  end
end
