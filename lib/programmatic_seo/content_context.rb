# frozen_string_literal: true

module ProgrammaticSeo
  # Small value object carrying the four strings that describe what a
  # programmatic-SEO page is about. Previously these travelled together as
  # four positional arguments through build_intro / build_how_it_works /
  # build_example / build_tips / build_faq, which RuboCop-Reek flagged as a
  # long-parameter-list + DataClump smell.
  #
  # Fields:
  #   noun     — the thing being calculated, e.g. "mortgage payment"
  #   label    — the pattern label, e.g. "Monthly" or "For Self-Employed"
  #   context  — a phrase slotted into sentences, e.g. "per month"
  #   category — one of "finance" | "health" | "construction" | "math" |
  #              "physics" | "everyday"
  ContentContext = Struct.new(:noun, :label, :context, :category, keyword_init: true) do
    def to_format_options
      { noun: noun, context: context, label: label, category: category }
    end

    def to_faq_format_options
      { noun: noun, context: context, label: label.downcase, category: category }
    end

    def capitalized_noun
      noun.split.map(&:capitalize).join(" ")
    end
  end
end
