# frozen_string_literal: true

module Everyday
  class MorseCodeCalculator
    attr_reader :errors

    CHAR_TO_MORSE = {
      "A" => ".-",    "B" => "-...",  "C" => "-.-.",  "D" => "-..",
      "E" => ".",     "F" => "..-.",  "G" => "--.",   "H" => "....",
      "I" => "..",    "J" => ".---",  "K" => "-.-",   "L" => ".-..",
      "M" => "--",    "N" => "-.",    "O" => "---",   "P" => ".--.",
      "Q" => "--.-",  "R" => ".-.",   "S" => "...",   "T" => "-",
      "U" => "..-",   "V" => "...-",  "W" => ".--",   "X" => "-..-",
      "Y" => "-.--",  "Z" => "--..",
      "0" => "-----", "1" => ".----", "2" => "..---", "3" => "...--",
      "4" => "....-", "5" => ".....", "6" => "-....", "7" => "--...",
      "8" => "---..", "9" => "----.",
      "." => ".-.-.-", "," => "--..--", "?" => "..--..", "'" => ".----.",
      "!" => "-.-.--", "/" => "-..-.",  "(" => "-.--.",  ")" => "-.--.-",
      "&" => ".-...",  ":" => "---...", ";" => "-.-.-.", "=" => "-...-",
      "+" => ".-.-.",  "-" => "-....-", "_" => "..--.-", '"' => ".-..-.",
      "$" => "...-..-", "@" => ".--.-."
    }.freeze

    MORSE_TO_CHAR = CHAR_TO_MORSE.invert.freeze

    MAX_LENGTH = 5000

    def initialize(text:, direction: :to_morse)
      @text = text.to_s
      @direction = direction.to_sym
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @direction == :to_morse
        translate_to_morse
      else
        translate_from_morse
      end
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
      @errors << "Text exceeds maximum length of #{MAX_LENGTH} characters" if @text.length > MAX_LENGTH
      unless [ :to_morse, :from_morse ].include?(@direction)
        @errors << "Invalid direction: must be :to_morse or :from_morse"
      end
    end

    def translate_to_morse
      result = []
      unknown_chars = []

      @text.upcase.each_char do |char|
        if char == " "
          result << "/"
        elsif CHAR_TO_MORSE.key?(char)
          result << CHAR_TO_MORSE[char]
        else
          unknown_chars << char
        end
      end

      {
        valid: true,
        direction: :to_morse,
        input: @text,
        output: result.join(" "),
        unknown_characters: unknown_chars.uniq,
        character_count: @text.length,
        morse_symbol_count: result.join(" ").length
      }
    end

    def translate_from_morse
      words = @text.strip.split(%r{\s*/\s*})
      result = []
      unknown_codes = []

      words.each_with_index do |word, idx|
        result << " " if idx > 0
        codes = word.strip.split(/\s+/)
        codes.each do |code|
          if MORSE_TO_CHAR.key?(code)
            result << MORSE_TO_CHAR[code]
          else
            unknown_codes << code unless code.empty?
          end
        end
      end

      {
        valid: true,
        direction: :from_morse,
        input: @text,
        output: result.join,
        unknown_codes: unknown_codes.uniq,
        character_count: result.join.length,
        morse_symbol_count: @text.length
      }
    end
  end
end
