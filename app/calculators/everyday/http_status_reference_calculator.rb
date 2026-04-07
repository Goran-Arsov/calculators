# frozen_string_literal: true

module Everyday
  class HttpStatusReferenceCalculator
    attr_reader :errors

    STATUS_CODES = {
      # 1xx Informational
      100 => { name: "Continue", description: "The server has received the request headers and the client should proceed to send the request body." },
      101 => { name: "Switching Protocols", description: "The server is switching protocols as requested by the client via the Upgrade header." },
      102 => { name: "Processing", description: "The server has received and is processing the request, but no response is available yet." },
      103 => { name: "Early Hints", description: "Used to return some response headers before final HTTP message, allowing preloading of resources." },

      # 2xx Success
      200 => { name: "OK", description: "The request has succeeded. The meaning depends on the HTTP method used." },
      201 => { name: "Created", description: "The request has been fulfilled and a new resource has been created." },
      202 => { name: "Accepted", description: "The request has been accepted for processing, but the processing has not been completed." },
      203 => { name: "Non-Authoritative Information", description: "The returned metadata is from a local or third-party copy, not the origin server." },
      204 => { name: "No Content", description: "The server successfully processed the request but is not returning any content." },
      205 => { name: "Reset Content", description: "The server successfully processed the request and asks the client to reset the document view." },
      206 => { name: "Partial Content", description: "The server is delivering only part of the resource due to a Range header sent by the client." },
      207 => { name: "Multi-Status", description: "A WebDAV response that conveys information about multiple resources." },
      208 => { name: "Already Reported", description: "Used in DAV bindings to avoid enumerating the same resource multiple times." },

      # 3xx Redirection
      300 => { name: "Multiple Choices", description: "The request has more than one possible response. The user should choose one of them." },
      301 => { name: "Moved Permanently", description: "The resource has been permanently moved to a new URL. Search engines will update their links." },
      302 => { name: "Found", description: "The resource is temporarily at a different URL. The client should continue to use the original URL." },
      303 => { name: "See Other", description: "The response to the request can be found under another URL using a GET method." },
      304 => { name: "Not Modified", description: "The resource has not been modified since the last request. The client can use its cached version." },
      307 => { name: "Temporary Redirect", description: "The request should be repeated with another URL, but future requests should still use the original." },
      308 => { name: "Permanent Redirect", description: "The request and all future requests should be repeated using another URL. Method must not change." },

      # 4xx Client Errors
      400 => { name: "Bad Request", description: "The server cannot process the request due to malformed syntax or invalid request framing." },
      401 => { name: "Unauthorized", description: "Authentication is required. The client must provide valid credentials to access the resource." },
      402 => { name: "Payment Required", description: "Reserved for future use. Originally intended for digital payment schemes." },
      403 => { name: "Forbidden", description: "The server understood the request but refuses to authorize it, even with authentication." },
      404 => { name: "Not Found", description: "The server cannot find the requested resource. The URL may be incorrect or the resource deleted." },
      405 => { name: "Method Not Allowed", description: "The HTTP method used is not supported for the requested resource." },
      406 => { name: "Not Acceptable", description: "The resource cannot generate content matching the Accept headers sent by the client." },
      407 => { name: "Proxy Authentication Required", description: "The client must first authenticate itself with the proxy server." },
      408 => { name: "Request Timeout", description: "The server timed out waiting for the request. The client may repeat the request." },
      409 => { name: "Conflict", description: "The request conflicts with the current state of the server, such as an edit conflict." },
      410 => { name: "Gone", description: "The resource is permanently gone and will not be available again. Different from 404." },
      411 => { name: "Length Required", description: "The server requires a Content-Length header to be sent with the request." },
      412 => { name: "Precondition Failed", description: "One or more conditions in the request header fields evaluated to false." },
      413 => { name: "Payload Too Large", description: "The request body is larger than the server is willing or able to process." },
      414 => { name: "URI Too Long", description: "The URI provided was too long for the server to process." },
      415 => { name: "Unsupported Media Type", description: "The media format of the requested data is not supported by the server." },
      416 => { name: "Range Not Satisfiable", description: "The range specified in the Range header cannot be fulfilled." },
      418 => { name: "I'm a Teapot", description: "The server refuses to brew coffee because it is a teapot. Defined in RFC 2324 as an April Fools joke." },
      422 => { name: "Unprocessable Entity", description: "The request was well-formed but could not be processed due to semantic errors." },
      425 => { name: "Too Early", description: "The server is unwilling to risk processing a request that might be replayed." },
      429 => { name: "Too Many Requests", description: "The user has sent too many requests in a given amount of time (rate limiting)." },
      431 => { name: "Request Header Fields Too Large", description: "The server refuses the request because the header fields are too large." },
      451 => { name: "Unavailable For Legal Reasons", description: "The resource is unavailable due to legal demands, such as government censorship." },

      # 5xx Server Errors
      500 => { name: "Internal Server Error", description: "The server encountered an unexpected condition that prevented it from fulfilling the request." },
      501 => { name: "Not Implemented", description: "The server does not support the functionality required to fulfill the request." },
      502 => { name: "Bad Gateway", description: "The server acting as a gateway received an invalid response from the upstream server." },
      503 => { name: "Service Unavailable", description: "The server is temporarily unable to handle the request due to overload or maintenance." },
      504 => { name: "Gateway Timeout", description: "The server acting as a gateway did not receive a timely response from the upstream server." },
      505 => { name: "HTTP Version Not Supported", description: "The server does not support the HTTP version used in the request." },
      507 => { name: "Insufficient Storage", description: "The server cannot store the representation needed to complete the request." },
      508 => { name: "Loop Detected", description: "The server detected an infinite loop while processing the request." },
      511 => { name: "Network Authentication Required", description: "The client needs to authenticate to gain network access, such as a captive portal." }
    }.freeze

    CATEGORIES = {
      "1xx" => "Informational",
      "2xx" => "Success",
      "3xx" => "Redirection",
      "4xx" => "Client Error",
      "5xx" => "Server Error"
    }.freeze

    def initialize(query: "")
      @query = query.to_s.strip.downcase
      @errors = []
    end

    def call
      if @query.empty?
        return {
          valid: true,
          codes: STATUS_CODES,
          categories: CATEGORIES,
          total_count: STATUS_CODES.size,
          filtered: false
        }
      end

      filtered = STATUS_CODES.select do |code, info|
        code.to_s.include?(@query) ||
          info[:name].downcase.include?(@query) ||
          info[:description].downcase.include?(@query)
      end

      {
        valid: true,
        codes: filtered,
        categories: CATEGORIES,
        total_count: STATUS_CODES.size,
        match_count: filtered.size,
        filtered: true,
        query: @query
      }
    end
  end
end
