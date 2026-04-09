# frozen_string_literal: true

require "openssl"
require "base64"
require "securerandom"

module Everyday
  class TextEncryptorCalculator
    attr_reader :errors

    ITERATIONS = 100_000
    KEY_LENGTH = 32        # AES-256
    SALT_LENGTH = 16
    IV_LENGTH = 12         # GCM standard
    TAG_LENGTH = 16        # GCM auth tag

    def initialize(input_text:, password:, mode: "encrypt")
      @input_text = input_text.to_s
      @password = password.to_s
      @mode = mode.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors, success: false } if @errors.any?

      if @mode == "encrypt"
        encrypt
      else
        decrypt
      end
    end

    private

    def validate!
      @errors << "Input text cannot be empty" if @input_text.empty?
      @errors << "Password cannot be empty" if @password.empty?
      @errors << "Mode must be 'encrypt' or 'decrypt'" unless %w[encrypt decrypt].include?(@mode)
    end

    def encrypt
      salt = SecureRandom.random_bytes(SALT_LENGTH)
      key = derive_key(@password, salt)

      cipher = OpenSSL::Cipher::AES.new(256, :GCM)
      cipher.encrypt
      cipher.key = key
      iv = cipher.random_iv

      ciphertext = cipher.update(@input_text) + cipher.final
      tag = cipher.auth_tag(TAG_LENGTH)

      # Format: base64(salt:iv:ciphertext:tag)
      combined = [
        Base64.strict_encode64(salt),
        Base64.strict_encode64(iv),
        Base64.strict_encode64(ciphertext),
        Base64.strict_encode64(tag)
      ].join(":")

      result_text = Base64.strict_encode64(combined)

      {
        valid: true,
        success: true,
        result_text: result_text,
        mode: "encrypt"
      }
    end

    def decrypt
      combined = Base64.strict_decode64(@input_text)
      parts = combined.split(":")

      unless parts.length == 4
        @errors << "Invalid encrypted format: expected 4 parts (salt:iv:ciphertext:tag)"
        return { valid: false, errors: @errors, success: false }
      end

      salt = Base64.strict_decode64(parts[0])
      iv = Base64.strict_decode64(parts[1])
      ciphertext = Base64.strict_decode64(parts[2])
      tag = Base64.strict_decode64(parts[3])

      key = derive_key(@password, salt)

      cipher = OpenSSL::Cipher::AES.new(256, :GCM)
      cipher.decrypt
      cipher.key = key
      cipher.iv = iv
      cipher.auth_tag = tag

      plaintext = cipher.update(ciphertext) + cipher.final

      {
        valid: true,
        success: true,
        result_text: plaintext,
        mode: "decrypt"
      }
    rescue ArgumentError => e
      @errors << "Invalid Base64 input: #{e.message}"
      { valid: false, errors: @errors, success: false }
    rescue OpenSSL::Cipher::CipherError
      @errors << "Decryption failed: wrong password or corrupted data"
      { valid: false, errors: @errors, success: false }
    end

    def derive_key(password, salt)
      OpenSSL::KDF.pbkdf2_hmac(
        password,
        salt: salt,
        iterations: ITERATIONS,
        length: KEY_LENGTH,
        hash: "SHA256"
      )
    end
  end
end
