import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "forceHttps", "wwwRedirect", "nonWwwRedirect", "gzip", "caching",
    "securityHeaders", "errorPages", "disableDirectoryListing",
    "hotlinkProtection", "hotlinkDomain", "protectSensitiveFiles",
    "output", "resultSectionCount", "resultLineCount"
  ]

  generate() {
    const sections = []

    if (this.forceHttpsTarget.checked) sections.push(this.forceHttpsSnippet())
    if (this.wwwRedirectTarget.checked) sections.push(this.wwwRedirectSnippet())
    if (this.nonWwwRedirectTarget.checked) sections.push(this.nonWwwRedirectSnippet())
    if (this.gzipTarget.checked) sections.push(this.gzipSnippet())
    if (this.cachingTarget.checked) sections.push(this.cachingSnippet())
    if (this.securityHeadersTarget.checked) sections.push(this.securityHeadersSnippet())
    if (this.errorPagesTarget.checked) sections.push(this.errorPagesSnippet())
    if (this.disableDirectoryListingTarget.checked) sections.push(this.directoryListingSnippet())
    if (this.hotlinkProtectionTarget.checked) sections.push(this.hotlinkSnippet())
    if (this.protectSensitiveFilesTarget.checked) sections.push(this.fileProtectionSnippet())

    const output = sections.length > 0 ? sections.join("\n\n") + "\n" : "# No options selected.\n"
    this.outputTarget.value = output
    this.resultSectionCountTarget.textContent = sections.length
    this.resultLineCountTarget.textContent = output.split("\n").length
  }

  forceHttpsSnippet() {
    return `# Force HTTPS\nRewriteEngine On\nRewriteCond %{HTTPS} off\nRewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]`
  }

  wwwRedirectSnippet() {
    return `# Redirect non-www to www\nRewriteEngine On\nRewriteCond %{HTTP_HOST} !^www\\. [NC]\nRewriteRule ^(.*)$ https://www.%{HTTP_HOST}%{REQUEST_URI} [L,R=301]`
  }

  nonWwwRedirectSnippet() {
    return `# Redirect www to non-www\nRewriteEngine On\nRewriteCond %{HTTP_HOST} ^www\\.(.*)$ [NC]\nRewriteRule ^(.*)$ https://%1%{REQUEST_URI} [L,R=301]`
  }

  gzipSnippet() {
    return `# Enable Gzip Compression\n<IfModule mod_deflate.c>\n  AddOutputFilterByType DEFLATE text/html\n  AddOutputFilterByType DEFLATE text/css\n  AddOutputFilterByType DEFLATE text/javascript\n  AddOutputFilterByType DEFLATE application/javascript\n  AddOutputFilterByType DEFLATE application/json\n  AddOutputFilterByType DEFLATE application/xml\n  AddOutputFilterByType DEFLATE image/svg+xml\n</IfModule>`
  }

  cachingSnippet() {
    return `# Browser Caching\n<IfModule mod_expires.c>\n  ExpiresActive On\n  ExpiresByType text/css "access plus 1 month"\n  ExpiresByType application/javascript "access plus 1 month"\n  ExpiresByType image/png "access plus 1 year"\n  ExpiresByType image/jpg "access plus 1 year"\n  ExpiresByType image/jpeg "access plus 1 year"\n  ExpiresByType image/gif "access plus 1 year"\n  ExpiresByType image/webp "access plus 1 year"\n  ExpiresByType font/woff2 "access plus 1 year"\n</IfModule>`
  }

  securityHeadersSnippet() {
    return `# Security Headers\n<IfModule mod_headers.c>\n  Header set X-Content-Type-Options "nosniff"\n  Header set X-Frame-Options "SAMEORIGIN"\n  Header set X-XSS-Protection "1; mode=block"\n  Header set Referrer-Policy "strict-origin-when-cross-origin"\n  Header set Permissions-Policy "geolocation=(), microphone=(), camera=()"\n</IfModule>`
  }

  errorPagesSnippet() {
    return `# Custom Error Pages\nErrorDocument 400 /errors/400.html\nErrorDocument 401 /errors/401.html\nErrorDocument 403 /errors/403.html\nErrorDocument 404 /errors/404.html\nErrorDocument 500 /errors/500.html`
  }

  directoryListingSnippet() {
    return `# Disable Directory Listing\nOptions -Indexes`
  }

  hotlinkSnippet() {
    const domain = this.hotlinkDomainTarget.value.trim() || "example.com"
    return `# Hotlink Protection\nRewriteEngine On\nRewriteCond %{HTTP_REFERER} !^$\nRewriteCond %{HTTP_REFERER} !^https?://(www\\.)?${domain.replace(/\./g, "\\.")} [NC]\nRewriteRule \\.(jpg|jpeg|png|gif|webp|svg)$ - [F,NC,L]`
  }

  fileProtectionSnippet() {
    return `# Protect Sensitive Files\n<FilesMatch "^\\.(htaccess|htpasswd|env|git|gitignore)">\n  Order Allow,Deny\n  Deny from all\n</FilesMatch>\n\n<FilesMatch "\\.(bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist)$">\n  Order Allow,Deny\n  Deny from all\n</FilesMatch>`
  }

  copy() {
    navigator.clipboard.writeText(this.outputTarget.value)
  }
}
