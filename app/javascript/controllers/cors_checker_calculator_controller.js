import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "testOrigin", "testMethod", "testHeaders",
    "resultError", "resultsContainer",
    "corsStatus", "corsStatusBadge",
    "headersList",
    "warningsList",
    "testResultContainer", "testResultOverall", "testResultChecks"
  ]

  static CORS_HEADER_DESCRIPTIONS = {
    "access-control-allow-origin": { name: "Access-Control-Allow-Origin", description: "Specifies which origins can access the resource" },
    "access-control-allow-methods": { name: "Access-Control-Allow-Methods", description: "Lists allowed HTTP methods for preflight requests" },
    "access-control-allow-headers": { name: "Access-Control-Allow-Headers", description: "Lists allowed request headers for preflight requests" },
    "access-control-allow-credentials": { name: "Access-Control-Allow-Credentials", description: "Whether credentials (cookies, auth) are allowed" },
    "access-control-max-age": { name: "Access-Control-Max-Age", description: "How long preflight results can be cached (seconds)" },
    "access-control-expose-headers": { name: "Access-Control-Expose-Headers", description: "Which response headers the browser can access" }
  }

  calculate() {
    const text = this.inputTarget.value.trim()
    if (!text) {
      this.clearResults()
      return
    }

    const headers = this.parseHeaders(text)
    if (headers.length === 0) {
      this.showError("No valid headers found. Use the format: Header-Name: value")
      this.hideResults()
      return
    }

    this.hideError()
    this.showResults()

    const corsHeaders = this.extractCorsHeaders(headers)
    const corsEnabled = Object.keys(corsHeaders).length > 0

    this.renderCorsStatus(corsEnabled)
    this.renderHeadersList(corsHeaders)
    this.renderWarnings(corsHeaders, headers)
    this.renderTestResult(corsHeaders)
  }

  parseHeaders(text) {
    return text.split("\n")
      .map(line => line.trim())
      .filter(line => line.length > 0)
      .filter(line => !line.match(/^HTTP\/[\d.]+\s+\d+/))
      .map(line => {
        if (line.includes(":")) {
          const colonIndex = line.indexOf(":")
          return {
            name: line.substring(0, colonIndex).trim(),
            value: line.substring(colonIndex + 1).trim()
          }
        }
        return null
      })
      .filter(h => h !== null && h.name.length > 0)
  }

  extractCorsHeaders(headers) {
    const cors = {}
    const corsKeys = Object.keys(this.constructor.CORS_HEADER_DESCRIPTIONS)
    headers.forEach(h => {
      const key = h.name.toLowerCase()
      if (corsKeys.includes(key)) {
        cors[key] = h.value
      }
    })
    return cors
  }

  renderCorsStatus(enabled) {
    if (enabled) {
      this.corsStatusTarget.textContent = "CORS is enabled"
      this.corsStatusBadgeTarget.textContent = "Enabled"
      this.corsStatusBadgeTarget.className = "px-3 py-1 rounded-full text-sm font-semibold bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400"
    } else {
      this.corsStatusTarget.textContent = "No CORS headers found"
      this.corsStatusBadgeTarget.textContent = "Not Configured"
      this.corsStatusBadgeTarget.className = "px-3 py-1 rounded-full text-sm font-semibold bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400"
    }
  }

  renderHeadersList(corsHeaders) {
    const descriptions = this.constructor.CORS_HEADER_DESCRIPTIONS
    let html = ""

    Object.keys(descriptions).forEach(key => {
      const info = descriptions[key]
      const value = corsHeaders[key]
      const found = value !== undefined

      html += `<div class="flex items-start gap-3 py-3 border-b border-gray-100 dark:border-gray-700 last:border-0">`
      if (found) {
        html += `<svg class="w-5 h-5 text-green-500 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>`
      } else {
        html += `<svg class="w-5 h-5 text-gray-300 dark:text-gray-600 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4"/></svg>`
      }
      html += `<div class="flex-1 min-w-0">`
      html += `<div class="flex items-center justify-between">`
      html += `<span class="text-sm font-semibold text-gray-900 dark:text-white">${info.name}</span>`
      if (found) {
        html += `<span class="text-xs font-semibold text-green-600 dark:text-green-400">Found</span>`
      } else {
        html += `<span class="text-xs text-gray-400 dark:text-gray-500">Missing</span>`
      }
      html += `</div>`
      html += `<p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">${info.description}</p>`
      if (found) {
        html += `<p class="text-xs font-mono text-blue-600 dark:text-blue-400 mt-1 break-all">${this.escapeHtml(value)}</p>`
      }
      html += `</div></div>`
    })

    this.headersListTarget.innerHTML = html
  }

  renderWarnings(corsHeaders, allHeaders) {
    const warnings = []
    const origin = corsHeaders["access-control-allow-origin"]
    const credentials = corsHeaders["access-control-allow-credentials"]

    if (origin === "*" && credentials && credentials.toLowerCase() === "true") {
      warnings.push("Wildcard origin (*) with credentials is not allowed by browsers and will be rejected.")
    }

    if (origin === "*") {
      warnings.push("Wildcard origin (*) allows any website to make cross-origin requests. Consider restricting to specific origins.")
    }

    if (origin && origin !== "*") {
      const varyHeader = allHeaders.find(h => h.name.toLowerCase() === "vary")
      if (!varyHeader || !varyHeader.value.toLowerCase().includes("origin")) {
        warnings.push("Missing 'Vary: Origin' header. When Access-Control-Allow-Origin is not a wildcard, the Vary header should include Origin to prevent caching issues.")
      }
    }

    const methods = corsHeaders["access-control-allow-methods"]
    if (methods && methods.includes("*")) {
      warnings.push("Wildcard methods (*) allows all HTTP methods. Consider restricting to specific methods needed.")
    }

    const headersVal = corsHeaders["access-control-allow-headers"]
    if (headersVal && headersVal.includes("*")) {
      warnings.push("Wildcard headers (*) allows all request headers. Consider restricting to specific headers needed.")
    }

    const maxAge = corsHeaders["access-control-max-age"]
    if (maxAge && parseInt(maxAge) > 86400) {
      warnings.push(`Max-age of ${maxAge} seconds exceeds 24 hours. Most browsers cap preflight caching at shorter durations.`)
    }

    if (warnings.length === 0) {
      this.warningsListTarget.innerHTML = '<p class="text-sm text-green-600 dark:text-green-400">No warnings detected.</p>'
      return
    }

    let html = ""
    warnings.forEach(w => {
      html += `<div class="flex items-start gap-2 py-2">
        <svg class="w-5 h-5 text-amber-500 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"/></svg>
        <p class="text-sm text-amber-700 dark:text-amber-400">${this.escapeHtml(w)}</p>
      </div>`
    })
    this.warningsListTarget.innerHTML = html
  }

  renderTestResult(corsHeaders) {
    const origin = this.hasTestOriginTarget ? this.testOriginTarget.value.trim() : ""
    const method = this.hasTestMethodTarget ? this.testMethodTarget.value.trim() : ""
    const headers = this.hasTestHeadersTarget ? this.testHeadersTarget.value.trim() : ""

    if (!origin && !method && !headers) {
      this.testResultContainerTarget.classList.add("hidden")
      return
    }

    this.testResultContainerTarget.classList.remove("hidden")

    const checks = []
    let overallPass = true

    if (origin) {
      const allowedOrigin = corsHeaders["access-control-allow-origin"] || ""
      const pass = allowedOrigin === "*" || allowedOrigin === origin
      if (!pass) overallPass = false
      checks.push({ check: `Origin '${origin}'`, pass, value: allowedOrigin || "(missing)" })
    }

    if (method) {
      const allowedMethods = corsHeaders["access-control-allow-methods"] || ""
      const methodList = allowedMethods.split(",").map(m => m.trim().toUpperCase())
      const pass = methodList.includes("*") || methodList.includes(method.toUpperCase())
      if (!pass) overallPass = false
      checks.push({ check: `Method '${method}'`, pass, value: allowedMethods || "(missing)" })
    }

    if (headers) {
      const allowedHeaders = corsHeaders["access-control-allow-headers"] || ""
      const allowedList = allowedHeaders.split(",").map(h => h.trim().toLowerCase())
      const requestedList = headers.split(",").map(h => h.trim().toLowerCase())
      const pass = allowedList.includes("*") || requestedList.every(rh => allowedList.includes(rh))
      if (!pass) overallPass = false
      checks.push({ check: `Headers '${headers}'`, pass, value: allowedHeaders || "(missing)" })
    }

    if (overallPass) {
      this.testResultOverallTarget.textContent = "PASS"
      this.testResultOverallTarget.className = "px-3 py-1 rounded-full text-sm font-semibold bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400"
    } else {
      this.testResultOverallTarget.textContent = "FAIL"
      this.testResultOverallTarget.className = "px-3 py-1 rounded-full text-sm font-semibold bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400"
    }

    let html = ""
    checks.forEach(c => {
      const icon = c.pass
        ? `<svg class="w-4 h-4 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>`
        : `<svg class="w-4 h-4 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>`
      html += `<div class="flex items-center gap-2 py-1.5">
        ${icon}
        <span class="text-sm text-gray-900 dark:text-white">${this.escapeHtml(c.check)}</span>
        <span class="text-xs font-mono text-gray-500 dark:text-gray-400 ml-auto">${this.escapeHtml(c.value)}</span>
      </div>`
    })
    this.testResultChecksTarget.innerHTML = html
  }

  showError(message) {
    this.resultErrorTarget.textContent = message
    this.resultErrorTarget.classList.remove("hidden")
  }

  hideError() {
    this.resultErrorTarget.textContent = ""
    this.resultErrorTarget.classList.add("hidden")
  }

  showResults() {
    this.resultsContainerTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsContainerTarget.classList.add("hidden")
  }

  clearResults() {
    this.hideError()
    this.hideResults()
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }

  copy() {
    const text = this.inputTarget.value
    navigator.clipboard.writeText(text)
  }
}
