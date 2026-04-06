# frozen_string_literal: true

module Everyday
  class NginxConfigGeneratorCalculator
    attr_reader :errors

    VALID_PORTS = [80, 443, 8080, 8443, 3000, 5000, 9000].freeze

    def initialize(server_name:, listen_port: 80, root_path: "/var/www/html", proxy_pass: "", ssl: false,
                   ssl_certificate: "/etc/ssl/certs/server.crt", ssl_certificate_key: "/etc/ssl/private/server.key",
                   gzip: false, cache_static: false, redirect_http: false)
      @server_name = server_name.to_s.strip
      @listen_port = listen_port.to_i
      @root_path = root_path.to_s.strip
      @proxy_pass = proxy_pass.to_s.strip
      @ssl = ActiveModel::Type::Boolean.new.cast(ssl)
      @ssl_certificate = ssl_certificate.to_s.strip
      @ssl_certificate_key = ssl_certificate_key.to_s.strip
      @gzip = ActiveModel::Type::Boolean.new.cast(gzip)
      @cache_static = ActiveModel::Type::Boolean.new.cast(cache_static)
      @redirect_http = ActiveModel::Type::Boolean.new.cast(redirect_http)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      config = build_config

      {
        valid: true,
        config: config,
        server_name: @server_name,
        listen_port: @listen_port,
        ssl: @ssl,
        gzip: @gzip,
        cache_static: @cache_static,
        redirect_http: @redirect_http,
        has_proxy: @proxy_pass.present?,
        line_count: config.lines.count
      }
    end

    private

    def validate!
      @errors << "Server name is required" if @server_name.blank?
      @errors << "Server name contains invalid characters" if @server_name.present? && !@server_name.match?(/\A[a-zA-Z0-9.\-_*]+\z/)
      @errors << "Listen port must be between 1 and 65535" if @listen_port < 1 || @listen_port > 65_535
      @errors << "Root path is required" if @root_path.blank? && @proxy_pass.blank?
      @errors << "SSL certificate path is required when SSL is enabled" if @ssl && @ssl_certificate.blank?
      @errors << "SSL certificate key path is required when SSL is enabled" if @ssl && @ssl_certificate_key.blank?
      @errors << "Proxy pass URL must start with http:// or https://" if @proxy_pass.present? && !@proxy_pass.match?(%r{\Ahttps?://})
    end

    def build_config
      lines = []

      # HTTP to HTTPS redirect block
      if @redirect_http && @ssl
        lines << "server {"
        lines << "    listen 80;"
        lines << "    listen [::]:80;"
        lines << "    server_name #{@server_name};"
        lines << ""
        lines << "    return 301 https://$host$request_uri;"
        lines << "}"
        lines << ""
      end

      # Main server block
      lines << "server {"

      # Listen directive
      if @ssl
        lines << "    listen #{@listen_port} ssl http2;"
        lines << "    listen [::]:#{@listen_port} ssl http2;"
      else
        lines << "    listen #{@listen_port};"
        lines << "    listen [::]:#{@listen_port};"
      end

      lines << "    server_name #{@server_name};"
      lines << ""

      # Root and index
      if @proxy_pass.blank?
        lines << "    root #{@root_path};"
        lines << "    index index.html index.htm;"
        lines << ""
      end

      # SSL configuration
      if @ssl
        lines << "    # SSL Configuration"
        lines << "    ssl_certificate #{@ssl_certificate};"
        lines << "    ssl_certificate_key #{@ssl_certificate_key};"
        lines << "    ssl_protocols TLSv1.2 TLSv1.3;"
        lines << "    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;"
        lines << "    ssl_prefer_server_ciphers off;"
        lines << "    ssl_session_cache shared:SSL:10m;"
        lines << "    ssl_session_timeout 1d;"
        lines << "    ssl_session_tickets off;"
        lines << ""
      end

      # Gzip configuration
      if @gzip
        lines << "    # Gzip Compression"
        lines << "    gzip on;"
        lines << "    gzip_vary on;"
        lines << "    gzip_proxied any;"
        lines << "    gzip_comp_level 6;"
        lines << "    gzip_min_length 256;"
        lines << "    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript image/svg+xml;"
        lines << ""
      end

      # Static asset caching
      if @cache_static
        lines << "    # Static Asset Caching"
        lines << "    location ~* \\.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {"
        lines << "        expires 30d;"
        lines << "        add_header Cache-Control \"public, immutable\";"
        lines << "        access_log off;"
        lines << "    }"
        lines << ""
      end

      # Proxy pass or try_files
      if @proxy_pass.present?
        lines << "    location / {"
        lines << "        proxy_pass #{@proxy_pass};"
        lines << "        proxy_http_version 1.1;"
        lines << "        proxy_set_header Upgrade $http_upgrade;"
        lines << "        proxy_set_header Connection 'upgrade';"
        lines << "        proxy_set_header Host $host;"
        lines << "        proxy_set_header X-Real-IP $remote_addr;"
        lines << "        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
        lines << "        proxy_set_header X-Forwarded-Proto $scheme;"
        lines << "        proxy_cache_bypass $http_upgrade;"
        lines << "    }"
      else
        lines << "    location / {"
        lines << "        try_files $uri $uri/ =404;"
        lines << "    }"
      end

      lines << "}"
      lines << ""

      lines.join("\n")
    end
  end
end
