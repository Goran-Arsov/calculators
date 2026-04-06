import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "pattern", "testText", "flagCaseInsensitive", "flagMultiline",
    "output", "resultMatchCount", "resultMatchList", "resultError",
    "resultsContainer"
  ]

  static COMMON_PATTERNS = {
    email: "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}",
    url: "https?://[^\\s/$.?#].[^\\s]*",
    phone: "\\+?[\\d\\s\\-().]{7,15}",
    ip_address: "\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b",
    date: "\\d{4}[-/]\\d{2}[-/]\\d{2}"
  }

  calculate() {
    const pattern = this.patternTarget.value
    const testText = this.testTextTarget.value

    if (!pattern || !testText) {
      this.clearResults()
      return
    }

    let flags = "g"
    if (this.hasFlagCaseInsensitiveTarget && this.flagCaseInsensitiveTarget.checked) flags += "i"
    if (this.hasFlagMultilineTarget && this.flagMultilineTarget.checked) flags += "m"

    let regex
    try {
      regex = new RegExp(pattern, flags)
      this.hideError()
    } catch (e) {
      this.showError("Invalid regex: " + e.message)
      this.resultMatchCountTarget.textContent = "0"
      this.outputTarget.innerHTML = this.escapeHtml(testText)
      this.resultMatchListTarget.innerHTML = ""
      this.showResults()
      return
    }

    const matches = []
    let match
    while ((match = regex.exec(testText)) !== null) {
      matches.push({
        text: match[0],
        start: match.index,
        end: match.index + match[0].length,
        groups: match.slice(1)
      })
      if (!regex.global) break
      if (match[0].length === 0) regex.lastIndex++
    }

    this.showResults()
    this.resultMatchCountTarget.textContent = matches.length
    this.outputTarget.innerHTML = this.highlightMatches(testText, matches)
    this.renderMatchList(matches)
  }

  insertPattern(event) {
    const key = event.currentTarget.dataset.pattern
    const patterns = this.constructor.COMMON_PATTERNS
    if (patterns[key]) {
      this.patternTarget.value = patterns[key]
      this.calculate()
    }
  }

  highlightMatches(text, matches) {
    if (matches.length === 0) return this.escapeHtml(text)

    let result = ""
    let lastIndex = 0
    matches.forEach(m => {
      result += this.escapeHtml(text.substring(lastIndex, m.start))
      result += `<mark class="bg-yellow-200 dark:bg-yellow-700 text-gray-900 dark:text-white px-0.5 rounded">${this.escapeHtml(m.text)}</mark>`
      lastIndex = m.end
    })
    result += this.escapeHtml(text.substring(lastIndex))
    return result
  }

  renderMatchList(matches) {
    if (matches.length === 0) {
      this.resultMatchListTarget.innerHTML = '<p class="text-sm text-gray-500 dark:text-gray-400">No matches found</p>'
      return
    }

    let html = '<div class="space-y-2">'
    matches.forEach((m, i) => {
      html += `<div class="bg-white dark:bg-gray-700 rounded-lg p-3 border border-gray-100 dark:border-gray-600">`
      html += `<div class="flex items-center justify-between mb-1">`
      html += `<span class="text-xs font-semibold text-gray-500 dark:text-gray-400">Match ${i + 1}</span>`
      html += `<span class="text-xs text-gray-400 dark:text-gray-500">Position ${m.start}&ndash;${m.end}</span>`
      html += `</div>`
      html += `<span class="font-mono text-sm text-gray-900 dark:text-white bg-yellow-100 dark:bg-yellow-900/30 px-1.5 py-0.5 rounded">${this.escapeHtml(m.text)}</span>`
      if (m.groups.length > 0) {
        html += '<div class="mt-2 flex flex-wrap gap-1">'
        m.groups.forEach((g, j) => {
          html += `<span class="inline-block bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 px-2 py-0.5 rounded text-xs font-mono">Group ${j + 1}: ${this.escapeHtml(g || "")}</span>`
        })
        html += '</div>'
      }
      html += `</div>`
    })
    html += '</div>'
    this.resultMatchListTarget.innerHTML = html
  }

  showError(message) {
    if (this.hasResultErrorTarget) {
      this.resultErrorTarget.textContent = message
      this.resultErrorTarget.classList.remove("hidden")
    }
  }

  hideError() {
    if (this.hasResultErrorTarget) {
      this.resultErrorTarget.textContent = ""
      this.resultErrorTarget.classList.add("hidden")
    }
  }

  showResults() {
    if (this.hasResultsContainerTarget) {
      this.resultsContainerTarget.classList.remove("hidden")
    }
  }

  hideResults() {
    if (this.hasResultsContainerTarget) {
      this.resultsContainerTarget.classList.add("hidden")
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  clearResults() {
    this.resultMatchCountTarget.textContent = "\u2014"
    this.outputTarget.innerHTML = '<span class="text-gray-400">Matches will be highlighted here</span>'
    this.resultMatchListTarget.innerHTML = ""
    this.hideError()
    this.hideResults()
  }

  copy() {
    const pattern = this.patternTarget.value
    if (pattern) {
      navigator.clipboard.writeText(pattern)
    }
  }
}
