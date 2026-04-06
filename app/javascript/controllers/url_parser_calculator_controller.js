import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "resultScheme", "resultUserinfo", "resultHost", "resultPort",
    "resultPath", "resultQuery", "resultFragment",
    "resultQueryParams", "resultError",
    "resultsContainer"
  ]

  calculate() {
    const url = this.inputTarget.value.trim()
    if (!url) {
      this.clearResults()
      return
    }

    try {
      const parsed = new URL(url)
      this.hideError()
      this.showResults()

      this.resultSchemeTarget.textContent = parsed.protocol.replace(":", "")
      this.resultUserinfoTarget.textContent = this.formatUserinfo(parsed)
      this.resultHostTarget.textContent = parsed.hostname || "\u2014"
      this.resultPortTarget.textContent = parsed.port || this.defaultPort(parsed.protocol) || "\u2014"
      this.resultPathTarget.textContent = parsed.pathname || "/"
      this.resultQueryTarget.textContent = parsed.search ? parsed.search.substring(1) : "\u2014"
      this.resultFragmentTarget.textContent = parsed.hash ? parsed.hash.substring(1) : "\u2014"

      this.renderQueryParams(parsed.searchParams)
    } catch (e) {
      this.showError("Invalid URL. Include a scheme (e.g. https://)")
      this.hideResults()
    }
  }

  formatUserinfo(parsed) {
    if (parsed.username && parsed.password) {
      return `${parsed.username}:${parsed.password}`
    } else if (parsed.username) {
      return parsed.username
    }
    return "\u2014"
  }

  defaultPort(protocol) {
    const defaults = {
      "http:": "80",
      "https:": "443",
      "ftp:": "21",
      "ssh:": "22"
    }
    return defaults[protocol] || null
  }

  renderQueryParams(searchParams) {
    const entries = Array.from(searchParams.entries())
    if (entries.length === 0) {
      this.resultQueryParamsTarget.innerHTML = '<tr><td colspan="2" class="px-3 py-2 text-sm text-gray-500 dark:text-gray-400">No query parameters</td></tr>'
      return
    }

    let html = ""
    entries.forEach(([key, value]) => {
      const safeKey = this.escapeHtml(key)
      const safeValue = this.escapeHtml(value)
      html += `<tr class="border-b border-gray-100 dark:border-gray-700 last:border-0">
        <td class="px-3 py-2 text-sm font-mono font-semibold text-blue-600 dark:text-blue-400">${safeKey}</td>
        <td class="px-3 py-2 text-sm font-mono text-gray-900 dark:text-white break-all">${safeValue}</td>
      </tr>`
    })
    this.resultQueryParamsTarget.innerHTML = html
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
    this.resultSchemeTarget.textContent = "\u2014"
    this.resultUserinfoTarget.textContent = "\u2014"
    this.resultHostTarget.textContent = "\u2014"
    this.resultPortTarget.textContent = "\u2014"
    this.resultPathTarget.textContent = "/"
    this.resultQueryTarget.textContent = "\u2014"
    this.resultFragmentTarget.textContent = "\u2014"
    this.resultQueryParamsTarget.innerHTML = ""
  }

  copy() {
    const parts = [
      `Scheme: ${this.resultSchemeTarget.textContent}`,
      `Host: ${this.resultHostTarget.textContent}`,
      `Port: ${this.resultPortTarget.textContent}`,
      `Path: ${this.resultPathTarget.textContent}`,
      `Query: ${this.resultQueryTarget.textContent}`,
      `Fragment: ${this.resultFragmentTarget.textContent}`
    ]
    navigator.clipboard.writeText(parts.join("\n"))
  }
}
