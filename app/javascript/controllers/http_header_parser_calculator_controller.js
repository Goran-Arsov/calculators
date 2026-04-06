import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "resultHeaders", "resultCount", "resultError",
    "resultsContainer",
    "securityPresent", "securityMissing", "securityScore", "securityGrade"
  ]

  static SECURITY_HEADERS = [
    { key: "content-security-policy", name: "Content-Security-Policy", description: "Prevents XSS and code injection" },
    { key: "strict-transport-security", name: "Strict-Transport-Security", description: "Forces HTTPS connections" },
    { key: "x-frame-options", name: "X-Frame-Options", description: "Prevents clickjacking" },
    { key: "x-content-type-options", name: "X-Content-Type-Options", description: "Prevents MIME sniffing" },
    { key: "x-xss-protection", name: "X-XSS-Protection", description: "Legacy XSS filter" },
    { key: "referrer-policy", name: "Referrer-Policy", description: "Controls referrer information" },
    { key: "permissions-policy", name: "Permissions-Policy", description: "Controls browser features" },
    { key: "x-permitted-cross-domain-policies", name: "X-Permitted-Cross-Domain-Policies", description: "Controls cross-domain access" },
    { key: "cross-origin-opener-policy", name: "Cross-Origin-Opener-Policy", description: "Isolates browsing context" },
    { key: "cross-origin-resource-policy", name: "Cross-Origin-Resource-Policy", description: "Controls resource loading" }
  ]

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

    this.resultCountTarget.textContent = headers.length
    this.renderHeaders(headers)
    this.analyzeSecurityHeaders(headers)
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
        return { name: line, value: "", malformed: true }
      })
      .filter(h => h.name.length > 0)
  }

  renderHeaders(headers) {
    let html = ""
    headers.forEach(h => {
      const safeN = this.escapeHtml(h.name)
      const safeV = this.escapeHtml(h.value)
      const cls = h.malformed ? "bg-red-50 dark:bg-red-900/20" : ""
      html += `<tr class="border-b border-gray-100 dark:border-gray-700 last:border-0 ${cls}">
        <td class="px-3 py-2 text-sm font-mono font-semibold text-blue-600 dark:text-blue-400 whitespace-nowrap">${safeN}</td>
        <td class="px-3 py-2 text-sm font-mono text-gray-900 dark:text-white break-all">${safeV}${h.malformed ? ' <span class="text-red-500 text-xs">(malformed)</span>' : ""}</td>
      </tr>`
    })
    this.resultHeadersTarget.innerHTML = html
  }

  analyzeSecurityHeaders(headers) {
    const headerNames = headers.map(h => h.name.toLowerCase())
    const secHeaders = this.constructor.SECURITY_HEADERS

    let presentHtml = ""
    let missingHtml = ""
    let presentCount = 0

    secHeaders.forEach(sh => {
      const found = headerNames.includes(sh.key)
      if (found) {
        presentCount++
        const header = headers.find(h => h.name.toLowerCase() === sh.key)
        const safeValue = this.escapeHtml(header ? header.value : "")
        presentHtml += `<div class="flex items-start gap-2 py-2">
          <svg class="w-5 h-5 text-green-500 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
          <div>
            <span class="text-sm font-semibold text-gray-900 dark:text-white">${sh.name}</span>
            <p class="text-xs text-gray-500 dark:text-gray-400">${sh.description}</p>
            <p class="text-xs font-mono text-green-600 dark:text-green-400 mt-0.5 break-all">${safeValue}</p>
          </div>
        </div>`
      } else {
        missingHtml += `<div class="flex items-start gap-2 py-2">
          <svg class="w-5 h-5 text-red-500 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
          <div>
            <span class="text-sm font-semibold text-gray-900 dark:text-white">${sh.name}</span>
            <p class="text-xs text-gray-500 dark:text-gray-400">${sh.description}</p>
          </div>
        </div>`
      }
    })

    this.securityPresentTarget.innerHTML = presentHtml || '<p class="text-sm text-gray-500">No security headers found</p>'
    this.securityMissingTarget.innerHTML = missingHtml || '<p class="text-sm text-green-600">All security headers present!</p>'

    const score = Math.round((presentCount / secHeaders.length) * 100)
    this.securityScoreTarget.textContent = `${score}%`
    const grade = this.gradeFromScore(score)
    this.securityGradeTarget.textContent = grade
    this.securityGradeTarget.className = `text-2xl font-extrabold ${this.gradeColor(grade)}`
  }

  gradeFromScore(score) {
    if (score >= 90) return "A"
    if (score >= 70) return "B"
    if (score >= 50) return "C"
    if (score >= 30) return "D"
    return "F"
  }

  gradeColor(grade) {
    const colors = {
      "A": "text-green-600 dark:text-green-400",
      "B": "text-blue-600 dark:text-blue-400",
      "C": "text-yellow-600 dark:text-yellow-400",
      "D": "text-orange-600 dark:text-orange-400",
      "F": "text-red-600 dark:text-red-400"
    }
    return colors[grade] || "text-gray-600"
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
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
    this.resultHeadersTarget.innerHTML = ""
    this.resultCountTarget.textContent = "\u2014"
    this.securityPresentTarget.innerHTML = ""
    this.securityMissingTarget.innerHTML = ""
    this.securityScoreTarget.textContent = "\u2014"
    this.securityGradeTarget.textContent = "\u2014"
  }

  copy() {
    const text = this.inputTarget.value
    navigator.clipboard.writeText(text)
  }
}
