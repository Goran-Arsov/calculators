# frozen_string_literal: true

module Everyday
  class CurlToCodeCalculator
    attr_reader :errors

    SUPPORTED_LANGUAGES = %w[python javascript ruby php].freeze

    def initialize(curl:, language: "python")
      @curl = curl.to_s.strip
      @language = language.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      parsed = parse_curl
      return { valid: false, errors: @errors } if @errors.any?

      code = generate_code(parsed)

      {
        valid: true,
        code: code,
        language: @language,
        method: parsed[:method],
        url: parsed[:url],
        header_count: parsed[:headers].size,
        has_body: !parsed[:data].nil?
      }
    end

    private

    def validate!
      @errors << "cURL command cannot be empty" if @curl.empty?
      @errors << "Unsupported language: #{@language}. Supported: #{SUPPORTED_LANGUAGES.join(', ')}" unless SUPPORTED_LANGUAGES.include?(@language)
    end

    def parse_curl
      cmd = @curl.gsub(/\\\n\s*/, " ").strip
      cmd = cmd.sub(/\Acurl\s+/, "") if cmd.start_with?("curl")

      unless @curl.match?(/\bcurl\b/) || cmd.match?(/^['"]?https?:/)
        @errors << "Input does not appear to be a valid cURL command"
        return {}
      end

      result = { method: "GET", url: "", headers: {}, data: nil, user: nil }

      tokens = shellsplit(cmd)
      i = 0
      while i < tokens.length
        token = tokens[i]
        case token
        when "-X", "--request"
          result[:method] = tokens[i + 1]&.upcase || "GET"
          i += 2
        when "-H", "--header"
          header = tokens[i + 1]
          if header&.include?(":")
            key, value = header.split(":", 2)
            result[:headers][key.strip] = value.strip
          end
          i += 2
        when "-d", "--data", "--data-raw", "--data-binary"
          result[:data] = tokens[i + 1]
          result[:method] = "POST" if result[:method] == "GET"
          i += 2
        when "-u", "--user"
          result[:user] = tokens[i + 1]
          i += 2
        when /\A-/
          i += 2
        else
          result[:url] = token.gsub(/\A['"]|['"]\z/, "") if result[:url].empty?
          i += 1
        end
      end

      result
    end

    def shellsplit(line)
      tokens = []
      current = +""
      in_single = false
      in_double = false
      escaped = false

      line.each_char do |c|
        if escaped
          current << c
          escaped = false
        elsif c == "\\"
          escaped = true
        elsif c == "'" && !in_double
          in_single = !in_single
        elsif c == '"' && !in_single
          in_double = !in_double
        elsif c =~ /\s/ && !in_single && !in_double
          tokens << current unless current.empty?
          current = +""
        else
          current << c
        end
      end
      tokens << current unless current.empty?
      tokens
    end

    def generate_code(parsed)
      send(:"generate_#{@language}", parsed)
    end

    def generate_python(p)
      lines = [ "import requests", "" ]
      if p[:headers].any?
        lines << "headers = {"
        p[:headers].each { |k, v| lines << "    \"#{k}\": \"#{v}\"," }
        lines << "}"
        lines << ""
      end
      args = [ "\"#{p[:url]}\"" ]
      args << "headers=headers" if p[:headers].any?
      args << "data='#{p[:data]}'" if p[:data]
      args << "auth=(\"#{p[:user].split(':', 2).first}\", \"#{p[:user].split(':', 2).last}\")" if p[:user]
      lines << "response = requests.#{p[:method].downcase}(#{args.join(', ')})"
      lines << "print(response.status_code)"
      lines << "print(response.text)"
      lines.join("\n")
    end

    def generate_javascript(p)
      lines = []
      if p[:data] || p[:headers].any? || p[:method] != "GET"
        lines << "const options = {"
        lines << "  method: '#{p[:method]}',"
        if p[:headers].any?
          lines << "  headers: {"
          p[:headers].each { |k, v| lines << "    '#{k}': '#{v}'," }
          lines << "  },"
        end
        lines << "  body: '#{p[:data]}'," if p[:data]
        lines << "};"
        lines << ""
        lines << "const response = await fetch('#{p[:url]}', options);"
      else
        lines << "const response = await fetch('#{p[:url]}');"
      end
      lines << "const data = await response.text();"
      lines << "console.log(data);"
      lines.join("\n")
    end

    def generate_ruby(p)
      lines = [ "require 'net/http'", "require 'uri'", "" ]
      lines << "uri = URI.parse('#{p[:url]}')"
      lines << "http = Net::HTTP.new(uri.host, uri.port)"
      lines << "http.use_ssl = true" if p[:url].start_with?("https")
      lines << ""
      klass = case p[:method]
              when "POST" then "Post"
              when "PUT" then "Put"
              when "PATCH" then "Patch"
              when "DELETE" then "Delete"
              else "Get"
              end
      lines << "request = Net::HTTP::#{klass}.new(uri.request_uri)"
      p[:headers].each { |k, v| lines << "request['#{k}'] = '#{v}'" }
      lines << "request.body = '#{p[:data]}'" if p[:data]
      lines << "request.basic_auth('#{p[:user].split(':', 2).first}', '#{p[:user].split(':', 2).last}')" if p[:user]
      lines << ""
      lines << "response = http.request(request)"
      lines << "puts response.code"
      lines << "puts response.body"
      lines.join("\n")
    end

    def generate_php(p)
      lines = [ "<?php", "" ]
      lines << "$ch = curl_init();"
      lines << "curl_setopt($ch, CURLOPT_URL, '#{p[:url]}');"
      lines << "curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);"
      lines << "curl_setopt($ch, CURLOPT_CUSTOMREQUEST, '#{p[:method]}');" if p[:method] != "GET"
      if p[:headers].any?
        lines << "curl_setopt($ch, CURLOPT_HTTPHEADER, ["
        p[:headers].each { |k, v| lines << "    '#{k}: #{v}'," }
        lines << "]);"
      end
      lines << "curl_setopt($ch, CURLOPT_POSTFIELDS, '#{p[:data]}');" if p[:data]
      if p[:user]
        lines << "curl_setopt($ch, CURLOPT_USERPWD, '#{p[:user]}');"
      end
      lines << ""
      lines << "$response = curl_exec($ch);"
      lines << "curl_close($ch);"
      lines << "echo $response;"
      lines.join("\n")
    end
  end
end
