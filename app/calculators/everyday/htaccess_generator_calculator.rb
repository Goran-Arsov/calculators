# frozen_string_literal: true

module Everyday
  class HtaccessGeneratorCalculator
    attr_reader :errors

    def initialize(options: {})
      @options = options.is_a?(Hash) ? options : {}
      @errors = []
    end

    def call
      sections = []

      sections << force_https if enabled?("force_https")
      sections << www_redirect if enabled?("www_redirect")
      sections << non_www_redirect if enabled?("non_www_redirect")
      sections << gzip_compression if enabled?("gzip")
      sections << browser_caching if enabled?("caching")
      sections << security_headers if enabled?("security_headers")
      sections << custom_error_pages if enabled?("error_pages")
      sections << directory_listing if enabled?("disable_directory_listing")
      sections << hotlink_protection if enabled?("hotlink_protection")
      sections << custom_redirects if @options["redirects"].is_a?(Array) && @options["redirects"].any?
      sections << block_ips if @options["blocked_ips"].is_a?(Array) && @options["blocked_ips"].any?
      sections << file_protection if enabled?("protect_sensitive_files")

      if sections.empty?
        return {
          valid: true,
          output: "# No options selected. Enable options to generate .htaccess rules.\n",
          section_count: 0
        }
      end

      output = sections.compact.join("\n\n") + "\n"

      {
        valid: true,
        output: output,
        section_count: sections.compact.size,
        line_count: output.lines.count
      }
    end

    private

    def enabled?(key)
      @options[key] == true || @options[key] == "true" || @options[key] == "1"
    end

    def force_https
      <<~HTACCESS.strip
        # Force HTTPS
        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
      HTACCESS
    end

    def www_redirect
      <<~HTACCESS.strip
        # Redirect non-www to www
        RewriteEngine On
        RewriteCond %{HTTP_HOST} !^www\\. [NC]
        RewriteRule ^(.*)$ https://www.%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
      HTACCESS
    end

    def non_www_redirect
      <<~HTACCESS.strip
        # Redirect www to non-www
        RewriteEngine On
        RewriteCond %{HTTP_HOST} ^www\\.(.*)$ [NC]
        RewriteRule ^(.*)$ https://%1%{REQUEST_URI} [L,R=301]
      HTACCESS
    end

    def gzip_compression
      <<~HTACCESS.strip
        # Enable Gzip Compression
        <IfModule mod_deflate.c>
          AddOutputFilterByType DEFLATE text/html
          AddOutputFilterByType DEFLATE text/css
          AddOutputFilterByType DEFLATE text/javascript
          AddOutputFilterByType DEFLATE application/javascript
          AddOutputFilterByType DEFLATE application/json
          AddOutputFilterByType DEFLATE application/xml
          AddOutputFilterByType DEFLATE image/svg+xml
          AddOutputFilterByType DEFLATE font/ttf
          AddOutputFilterByType DEFLATE font/otf
        </IfModule>
      HTACCESS
    end

    def browser_caching
      <<~HTACCESS.strip
        # Browser Caching
        <IfModule mod_expires.c>
          ExpiresActive On
          ExpiresByType text/css "access plus 1 month"
          ExpiresByType text/javascript "access plus 1 month"
          ExpiresByType application/javascript "access plus 1 month"
          ExpiresByType image/png "access plus 1 year"
          ExpiresByType image/jpg "access plus 1 year"
          ExpiresByType image/jpeg "access plus 1 year"
          ExpiresByType image/gif "access plus 1 year"
          ExpiresByType image/svg+xml "access plus 1 year"
          ExpiresByType image/webp "access plus 1 year"
          ExpiresByType font/ttf "access plus 1 year"
          ExpiresByType font/otf "access plus 1 year"
          ExpiresByType font/woff "access plus 1 year"
          ExpiresByType font/woff2 "access plus 1 year"
        </IfModule>
      HTACCESS
    end

    def security_headers
      <<~HTACCESS.strip
        # Security Headers
        <IfModule mod_headers.c>
          Header set X-Content-Type-Options "nosniff"
          Header set X-Frame-Options "SAMEORIGIN"
          Header set X-XSS-Protection "1; mode=block"
          Header set Referrer-Policy "strict-origin-when-cross-origin"
          Header set Permissions-Policy "geolocation=(), microphone=(), camera=()"
        </IfModule>
      HTACCESS
    end

    def custom_error_pages
      <<~HTACCESS.strip
        # Custom Error Pages
        ErrorDocument 400 /errors/400.html
        ErrorDocument 401 /errors/401.html
        ErrorDocument 403 /errors/403.html
        ErrorDocument 404 /errors/404.html
        ErrorDocument 500 /errors/500.html
      HTACCESS
    end

    def directory_listing
      <<~HTACCESS.strip
        # Disable Directory Listing
        Options -Indexes
      HTACCESS
    end

    def hotlink_protection
      domain = @options["domain"] || "example.com"
      <<~HTACCESS.strip
        # Hotlink Protection
        RewriteEngine On
        RewriteCond %{HTTP_REFERER} !^$
        RewriteCond %{HTTP_REFERER} !^https?://(www\\.)?#{Regexp.escape(domain)} [NC]
        RewriteRule \\.(jpg|jpeg|png|gif|webp|svg)$ - [F,NC,L]
      HTACCESS
    end

    def custom_redirects
      lines = [ "# Custom Redirects", "RewriteEngine On" ]
      @options["redirects"].each do |redirect|
        next unless redirect.is_a?(Hash)
        from = redirect["from"] || redirect[:from]
        to = redirect["to"] || redirect[:to]
        code = redirect["code"] || redirect[:code] || "301"
        lines << "RewriteRule ^#{from}$ #{to} [R=#{code},L]" if from && to
      end
      lines.join("\n")
    end

    def block_ips
      lines = [ "# Block IP Addresses" ]
      @options["blocked_ips"].each do |ip|
        next if ip.to_s.strip.empty?
        lines << "Deny from #{ip.strip}"
      end
      lines.join("\n")
    end

    def file_protection
      <<~HTACCESS.strip
        # Protect Sensitive Files
        <FilesMatch "^\\.(htaccess|htpasswd|env|git|gitignore)">
          Order Allow,Deny
          Deny from all
        </FilesMatch>

        <FilesMatch "\\.(bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist)$">
          Order Allow,Deny
          Deny from all
        </FilesMatch>
      HTACCESS
    end
  end
end
