# frozen_string_literal: true

module Everyday
  class LoremIpsumCalculator
    attr_reader :errors

    WORDS = %w[
      lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor
      incididunt ut labore et dolore magna aliqua enim ad minim veniam quis nostrud
      exercitation ullamco laboris nisi aliquip ex ea commodo consequat duis aute
      irure in reprehenderit voluptate velit esse cillum fugiat nulla pariatur
      excepteur sint occaecat cupidatat non proident sunt culpa qui officia deserunt
      mollit anim id est laborum perspiciatis unde omnis iste natus error voluptatem
      accusantium totam rem aperiam eaque ipsa quae ab illo inventore veritatis
      quasi architecto beatae vitae dicta explicabo nemo ipsam quia voluptas
      aspernatur aut odit fugit sed consequuntur magni dolores eos ratione
      sequi nesciunt neque porro quisquam dolorem adipisci numquam eius modi
      tempora incidunt magnam aliquam quaerat voluptatem
    ].freeze

    def initialize(count:, unit: "paragraphs")
      @count = count.to_i
      @unit = unit.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      text = generate_text
      word_count = text.split(/\s+/).reject(&:empty?).size

      {
        valid: true,
        text: text,
        word_count: word_count,
        unit: @unit,
        count: @count
      }
    end

    private

    def validate!
      @errors << "Count must be greater than zero" if @count <= 0
      @errors << "Count must be 100 or less" if @count > 100
      @errors << "Unit must be paragraphs, sentences, or words" unless %w[paragraphs sentences words].include?(@unit)
    end

    def generate_text
      case @unit
      when "words"
        generate_words(@count)
      when "sentences"
        @count.times.map { generate_sentence }.join(" ")
      when "paragraphs"
        @count.times.map { generate_paragraph }.join("\n\n")
      end
    end

    def generate_words(n)
      result = []
      while result.size < n
        result.concat(WORDS.shuffle)
      end
      result.first(n).join(" ")
    end

    def generate_sentence
      word_count = rand(8..16)
      words = generate_words(word_count).split(" ")
      words[0] = words[0].capitalize
      words.join(" ") + "."
    end

    def generate_paragraph
      sentence_count = rand(4..8)
      sentence_count.times.map { generate_sentence }.join(" ")
    end
  end
end
