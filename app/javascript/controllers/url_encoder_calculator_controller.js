import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "outputComponent", "outputFull",
    "resultInputLength", "resultOutputLength",
    "resultInputBytes", "resultOutputBytes"
  ]

  encode() {
    const text = this.inputTarget.value
    if (!text) {
      this.clearResults()
      return
    }

    const component = encodeURIComponent(text)
    const full = encodeURI(text)

    this.outputComponentTarget.value = component
    this.outputFullTarget.value = full
    this.updateStats(text, component)
  }

  decode() {
    const text = this.inputTarget.value
    if (!text) {
      this.clearResults()
      return
    }

    try {
      const decoded = decodeURIComponent(text)
      this.outputComponentTarget.value = decoded
      this.outputFullTarget.value = decoded
      this.updateStats(text, decoded)
    } catch (e) {
      try {
        const decoded = decodeURI(text)
        this.outputComponentTarget.value = decoded
        this.outputFullTarget.value = decoded
        this.updateStats(text, decoded)
      } catch (e2) {
        this.outputComponentTarget.value = "Error: Invalid URL-encoded input"
        this.outputFullTarget.value = ""
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
    this.outputComponentTarget.value = ""
    this.outputFullTarget.value = ""
    this.clearStats()
  }

  formatBytes(bytes) {
    if (bytes === 0) return "0 B"
    if (bytes < 1024) return bytes + " B"
    return (bytes / 1024).toFixed(2) + " KB"
  }

  copyComponent() {
    navigator.clipboard.writeText(this.outputComponentTarget.value)
  }

  copyFull() {
    navigator.clipboard.writeText(this.outputFullTarget.value)
  }
}
