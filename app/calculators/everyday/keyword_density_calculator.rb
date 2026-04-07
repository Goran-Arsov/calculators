# frozen_string_literal: true

module Everyday
  class KeywordDensityCalculator
    attr_reader :errors

    STOP_WORDS = %w[
      the a an is are was were am be been being
      and or but nor not so yet both either neither
      in on at to for of with by from as
      it its this that these those
      i me my we us our you your he him his she her they them their
      what which who whom whose when where why how
      do does did will would shall should can could may might must
      have has had having
      if then else than because since while although though
      about above after again against all also another any before
      between into through during each few more most other some such
      no only own same too very just over under
    ].to_set.freeze

    def initialize(text:)
      @text = text.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      words = extract_words
      filtered_words = words.reject { |w| STOP_WORDS.include?(w) }
      total_words = words.size

      word_freq = Hash.new(0)
      filtered_words.each { |w| word_freq[w] += 1 }

      top_words = word_freq
        .sort_by { |_, count| -count }
        .first(20)
        .map { |word, count| { word: word, count: count, density_percent: ((count.to_f / total_words) * 100).round(2) } }

      bigrams = build_ngrams(filtered_words, 2)
      trigrams = build_ngrams(filtered_words, 3)

      {
        valid: true,
        total_words: total_words,
        unique_words: words.uniq.size,
        top_words: top_words,
        top_bigrams: bigrams.first(10),
        top_trigrams: trigrams.first(10)
      }
    end

    private

    def extract_words
      @text.downcase.gsub(/[^a-z0-9'\s-]/, "").split(/\s+/).reject(&:empty?)
    end

    def build_ngrams(words, n)
      return [] if words.size < n

      ngram_freq = Hash.new(0)
      words.each_cons(n) { |group| ngram_freq[group.join(" ")] += 1 }

      total = words.size
      ngram_freq
        .sort_by { |_, count| -count }
        .map { |phrase, count| { word: phrase, count: count, density_percent: ((count.to_f / total) * 100).round(2) } }
    end

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end
  end
end
