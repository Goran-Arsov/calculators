# frozen_string_literal: true

module Everyday
  class PlagiarismCalculator
    attr_reader :errors

    def initialize(text1:, text2:)
      @text1 = text1.to_s
      @text2 = text2.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      words1 = normalize(@text1)
      words2 = normalize(@text2)

      ngrams1 = generate_ngrams(words1, 3)
      ngrams2 = generate_ngrams(words2, 3)

      intersection = ngrams1 & ngrams2
      union = ngrams1 | ngrams2

      similarity = union.empty? ? 0.0 : (intersection.size.to_f / union.size * 100)

      {
        valid: true,
        similarity_percent: similarity.round(2),
        matching_phrases_count: intersection.size,
        total_phrases_text1: ngrams1.size,
        total_phrases_text2: ngrams2.size
      }
    end

    private

    def validate!
      @errors << "Text 1 cannot be empty" if @text1.strip.empty?
      @errors << "Text 2 cannot be empty" if @text2.strip.empty?
    end

    def normalize(text)
      text.downcase.gsub(/[^a-z0-9\s]/, "").split(/\s+/).reject(&:empty?)
    end

    def generate_ngrams(words, n)
      return [] if words.size < n
      words.each_cons(n).map { |gram| gram.join(" ") }.uniq
    end
  end
end
