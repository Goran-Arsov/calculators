# frozen_string_literal: true

require "uri"
require "cgi"

module Everyday
  class UrlParserCalculator
    attr_reader :errors

    def initialize(url:)
      @url = url.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      parsed = URI.parse(@url)

      query_params = parse_query_params(parsed.query)

      {
        valid: true,
        original_url: @url,
        scheme: parsed.scheme,
        userinfo: parsed.userinfo,
        host: parsed.host,
        port: parsed.port,
        default_port: default_port_for(parsed.scheme),
        port_is_default: parsed.port == default_port_for(parsed.scheme),
        path: parsed.path.empty? ? "/" : parsed.path,
        query: parsed.query,
        fragment: parsed.fragment,
        query_params: query_params,
        query_param_count: query_params.size
      }
    rescue URI::InvalidURIError => e
      @errors << "Invalid URL: #{e.message}"
      { valid: false, errors: @errors }
    end

    private

    def validate!
      @errors << "URL cannot be empty" if @url.empty?
    end

    def parse_query_params(query_string)
      return {} if query_string.nil? || query_string.empty?

      CGI.parse(query_string).transform_values do |values|
        values.length == 1 ? values.first : values
      end
    end

    def default_port_for(scheme)
      case scheme&.downcase
      when "http" then 80
      when "https" then 443
      when "ftp" then 21
      when "ssh" then 22
      when "mailto" then nil
      else nil
      end
    end
  end
end
