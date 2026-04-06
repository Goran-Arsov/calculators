import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "serverName", "listenPort", "rootPath",
    "sslCheckbox", "sslFields", "sslCertificate", "sslCertificateKey",
    "proxyCheckbox", "proxyFields", "proxyPass",
    "gzipCheckbox", "cacheStaticCheckbox", "redirectHttpCheckbox",
    "output", "error", "lineCount"
  ]

  connect() {
    this.toggleSsl()
    this.toggleProxy()
  }

  toggleSsl() {
    const show = this.sslCheckboxTarget.checked
    this.sslFieldsTarget.classList.toggle("hidden", !show)
  }

  toggleProxy() {
    const show = this.proxyCheckboxTarget.checked
    this.proxyFieldsTarget.classList.toggle("hidden", !show)
  }

  generate() {
    const serverName = this.serverNameTarget.value.trim()
    const listenPort = parseInt(this.listenPortTarget.value) || 80
    const rootPath = this.rootPathTarget.value.trim()
    const ssl = this.sslCheckboxTarget.checked
    const sslCert = this.sslCertificateTarget.value.trim()
    const sslKey = this.sslCertificateKeyTarget.value.trim()
    const proxyEnabled = this.proxyCheckboxTarget.checked
    const proxyPass = this.proxyPassTarget.value.trim()
    const gzip = this.gzipCheckboxTarget.checked
    const cacheStatic = this.cacheStaticCheckboxTarget.checked
    const redirectHttp = this.redirectHttpCheckboxTarget.checked

    // Validation
    const errors = []
    if (!serverName) errors.push("Server name is required")
    if (!/^[a-zA-Z0-9.\-_*]+$/.test(serverName) && serverName) errors.push("Server name contains invalid characters")
    if (listenPort < 1 || listenPort > 65535) errors.push("Port must be between 1 and 65535")
    if (ssl && !sslCert) errors.push("SSL certificate path is required")
    if (ssl && !sslKey) errors.push("SSL certificate key path is required")
    if (proxyEnabled && proxyPass && !/^https?:\/\//.test(proxyPass)) errors.push("Proxy URL must start with http:// or https://")

    if (errors.length > 0) {
      this.errorTarget.textContent = errors.join(". ")
      this.errorTarget.classList.remove("hidden")
      this.outputTarget.value = ""
      this.lineCountTarget.textContent = ""
      return
    }

    this.errorTarget.classList.add("hidden")

    const lines = []

    // HTTP to HTTPS redirect
    if (redirectHttp && ssl) {
      lines.push("server {")
      lines.push("    listen 80;")
      lines.push("    listen [::]:80;")
      lines.push(`    server_name ${serverName};`)
      lines.push("")
      lines.push("    return 301 https://$host$request_uri;")
      lines.push("}")
      lines.push("")
    }

    // Main server block
    lines.push("server {")

    if (ssl) {
      lines.push(`    listen ${listenPort} ssl http2;`)
      lines.push(`    listen [::]:${listenPort} ssl http2;`)
    } else {
      lines.push(`    listen ${listenPort};`)
      lines.push(`    listen [::]:${listenPort};`)
    }

    lines.push(`    server_name ${serverName};`)
    lines.push("")

    // Root and index (skip if reverse proxy)
    if (!proxyEnabled || !proxyPass) {
      lines.push(`    root ${rootPath || "/var/www/html"};`)
      lines.push("    index index.html index.htm;")
      lines.push("")
    }

    // SSL
    if (ssl) {
      lines.push("    # SSL Configuration")
      lines.push(`    ssl_certificate ${sslCert};`)
      lines.push(`    ssl_certificate_key ${sslKey};`)
      lines.push("    ssl_protocols TLSv1.2 TLSv1.3;")
      lines.push("    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;")
      lines.push("    ssl_prefer_server_ciphers off;")
      lines.push("    ssl_session_cache shared:SSL:10m;")
      lines.push("    ssl_session_timeout 1d;")
      lines.push("    ssl_session_tickets off;")
      lines.push("")
    }

    // Gzip
    if (gzip) {
      lines.push("    # Gzip Compression")
      lines.push("    gzip on;")
      lines.push("    gzip_vary on;")
      lines.push("    gzip_proxied any;")
      lines.push("    gzip_comp_level 6;")
      lines.push("    gzip_min_length 256;")
      lines.push('    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript image/svg+xml;')
      lines.push("")
    }

    // Static caching
    if (cacheStatic) {
      lines.push("    # Static Asset Caching")
      lines.push("    location ~* \\.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {")
      lines.push("        expires 30d;")
      lines.push('        add_header Cache-Control "public, immutable";')
      lines.push("        access_log off;")
      lines.push("    }")
      lines.push("")
    }

    // Proxy or try_files
    if (proxyEnabled && proxyPass) {
      lines.push("    location / {")
      lines.push(`        proxy_pass ${proxyPass};`)
      lines.push("        proxy_http_version 1.1;")
      lines.push("        proxy_set_header Upgrade $http_upgrade;")
      lines.push("        proxy_set_header Connection 'upgrade';")
      lines.push("        proxy_set_header Host $host;")
      lines.push("        proxy_set_header X-Real-IP $remote_addr;")
      lines.push("        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;")
      lines.push("        proxy_set_header X-Forwarded-Proto $scheme;")
      lines.push("        proxy_cache_bypass $http_upgrade;")
      lines.push("    }")
    } else {
      lines.push("    location / {")
      lines.push("        try_files $uri $uri/ =404;")
      lines.push("    }")
    }

    lines.push("}")

    const config = lines.join("\n")
    this.outputTarget.value = config
    this.lineCountTarget.textContent = `${config.split("\n").length} lines`
  }

  copy() {
    const text = this.outputTarget.value
    if (!text) return

    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }
}
