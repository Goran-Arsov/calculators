import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "output",
    "resultInputLength", "resultOutputLength",
    "resultInputBytes", "resultOutputBytes"
  ]

  encode() {
    const text = this.inputTarget.value
    if (!text) {
      this.clearResults()
      return
    }

    try {
      const standard = btoa(unescape(encodeURIComponent(text)))
      this.outputTarget.value = standard
      this.updateStats(text, standard)
    } catch (e) {
      this.outputTarget.value = "Error: " + e.message
      this.clearStats()
    }
  }

  decode() {
    const text = this.inputTarget.value.trim()
    if (!text) {
      this.clearResults()
      return
    }

    try {
      const decoded = decodeURIComponent(escape(atob(text)))
      this.outputTarget.value = decoded
      this.updateStats(text, decoded)
    } catch (e) {
      // Try URL-safe Base64
      try {
        const urlSafe = text.replace(/-/g, "+").replace(/_/g, "/")
        const padded = urlSafe + "=".repeat((4 - urlSafe.length % 4) % 4)
        const decoded = decodeURIComponent(escape(atob(padded)))
        this.outputTarget.value = decoded
        this.updateStats(text, decoded)
      } catch (e2) {
        this.outputTarget.value = "Error: Invalid Base64 input"
        this.clearStats()
      }
    }
  }

  updateStats(input, output) {
    this.resultInputLengthTarget.textContent = input.length.toLocaleString()
    this.resultOutputLengthTarget.textContent = output.length.toLocaleString()
    this.resultInputBytesTarget.textContent = this.formatBytes(new Blob([input]).size)
    this.resultOutputBytesTarget.textContent = this.formatBytes(new Blob([output]).size)
  }

  clearStats() {
    this.resultInputLengthTarget.textContent = "\u2014"
    this.resultOutputLengthTarget.textContent = "\u2014"
    this.resultInputBytesTarget.textContent = "\u2014"
    this.resultOutputBytesTarget.textContent = "\u2014"
  }

  clearResults() {
    this.outputTarget.value = ""
    this.clearStats()
  }

  formatBytes(bytes) {
    if (bytes === 0) return "0 B"
    if (bytes < 1024) return bytes + " B"
    return (bytes / 1024).toFixed(2) + " KB"
  }

  copy() {
    navigator.clipboard.writeText(this.outputTarget.value)
  }
}
