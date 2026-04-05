import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "output",
    "resultOriginalCount", "resultUniqueCount", "resultDuplicatesRemoved"
  ]

  calculate() {
    const text = this.inputTarget.value
    if (!text || !text.trim()) {
      this.clearResults()
      return
    }

    const lines = text.split("\n")
    const uniqueLines = [...new Set(lines)]
    const duplicatesRemoved = lines.length - uniqueLines.length

    this.resultOriginalCountTarget.textContent = lines.length.toLocaleString()
    this.resultUniqueCountTarget.textContent = uniqueLines.length.toLocaleString()
    this.resultDuplicatesRemovedTarget.textContent = duplicatesRemoved.toLocaleString()
    this.outputTarget.value = uniqueLines.join("\n")
  }

  clearResults() {
    this.resultOriginalCountTarget.textContent = "\u2014"
    this.resultUniqueCountTarget.textContent = "\u2014"
    this.resultDuplicatesRemovedTarget.textContent = "\u2014"
    this.outputTarget.value = ""
  }

  copy() {
    const text = this.outputTarget.value
    if (text) {
      navigator.clipboard.writeText(text)
    }
  }
}
