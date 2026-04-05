import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "pattern", "testString", "flagGlobal", "flagCaseInsensitive", "flagMultiline",
    "output", "resultMatchCount", "resultCaptures", "resultError"
  ]

  calculate() {
    const pattern = this.patternTarget.value
    const testString = this.testStringTarget.value

    if (!pattern || !testString) {
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
      this.outputTarget.innerHTML = this.escapeHtml(testString)
      this.resultCapturesTarget.innerHTML = ""
      return
    }

    const matches = []
    let match
    while ((match = regex.exec(testString)) !== null) {
      matches.push({
        match: match[0],
        index: match.index,
        length: match[0].length,
        captures: match.slice(1)
      })
      if (!regex.global) break
      if (match[0].length === 0) regex.lastIndex++
    }

    this.resultMatchCountTarget.textContent = matches.length

    // Highlight matches in test string
    this.outputTarget.innerHTML = this.highlightMatches(testString, matches)

    // Show capture groups
    if (matches.some(m => m.captures.length > 0)) {
      let captureHtml = '<div class="space-y-2">'
      matches.forEach((m, i) => {
        if (m.captures.length > 0) {
          captureHtml += `<div class="text-sm"><span class="font-semibold text-gray-700 dark:text-gray-300">Match ${i + 1}:</span> `
          m.captures.forEach((c, j) => {
            captureHtml += `<span class="inline-block bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 px-2 py-0.5 rounded text-xs font-mono mr-1">Group ${j + 1}: ${this.escapeHtml(c || "")}</span>`
          })
          captureHtml += "</div>"
        }
      })
      captureHtml += "</div>"
      this.resultCapturesTarget.innerHTML = captureHtml
    } else {
      this.resultCapturesTarget.innerHTML = ""
    }
  }

  highlightMatches(text, matches) {
    if (matches.length === 0) return this.escapeHtml(text)

    let result = ""
    let lastIndex = 0
    matches.forEach(m => {
      result += this.escapeHtml(text.substring(lastIndex, m.index))
      result += `<mark class="bg-yellow-200 dark:bg-yellow-700 text-gray-900 dark:text-white px-0.5 rounded">${this.escapeHtml(m.match)}</mark>`
      lastIndex = m.index + m.length
    })
    result += this.escapeHtml(text.substring(lastIndex))
    return result
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

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  clearResults() {
    this.resultMatchCountTarget.textContent = "\u2014"
    this.outputTarget.innerHTML = '<span class="text-gray-400">Matches will be highlighted here</span>'
    this.resultCapturesTarget.innerHTML = ""
    this.hideError()
  }

  copy() {
    const text = this.outputTarget.innerText
    if (text) {
      navigator.clipboard.writeText(text)
    }
  }
}
