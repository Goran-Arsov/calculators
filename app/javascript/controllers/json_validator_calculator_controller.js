import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "outputFormatted",
    "resultStatus", "resultKeyCount", "resultDepth", "resultType", "resultSize"
  ]

  validate() {
    const text = this.inputTarget.value
    if (!text || !text.trim()) {
      this.clearResults()
      return
    }

    try {
      const parsed = JSON.parse(text)
      const formatted = JSON.stringify(parsed, null, 2)
      const keyCount = this.countKeys(parsed)
      const depth = this.nestingDepth(parsed)
      const type = Array.isArray(parsed) ? "Array" : (typeof parsed === "object" && parsed !== null ? "Object" : typeof parsed)

      this.resultStatusTarget.textContent = "Valid JSON"
      this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400")
      this.resultStatusTarget.classList.add("text-green-600", "dark:text-green-400")
      this.resultKeyCountTarget.textContent = keyCount.toLocaleString()
      this.resultDepthTarget.textContent = depth
      this.resultTypeTarget.textContent = type
      this.resultSizeTarget.textContent = this.formatBytes(new Blob([text]).size)
      this.outputFormattedTarget.value = formatted
    } catch (e) {
      this.resultStatusTarget.textContent = "Invalid: " + e.message
      this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400")
      this.resultStatusTarget.classList.add("text-red-500", "dark:text-red-400")
      this.resultKeyCountTarget.textContent = "\u2014"
      this.resultDepthTarget.textContent = "\u2014"
      this.resultTypeTarget.textContent = "\u2014"
      this.resultSizeTarget.textContent = "\u2014"
      this.outputFormattedTarget.value = ""
    }
  }

  countKeys(obj) {
    if (Array.isArray(obj)) return obj.reduce((sum, v) => sum + this.countKeys(v), 0)
    if (obj && typeof obj === "object") return Object.keys(obj).length + Object.values(obj).reduce((sum, v) => sum + this.countKeys(v), 0)
    return 0
  }

  nestingDepth(obj, current = 1) {
    if (Array.isArray(obj)) {
      if (obj.length === 0) return current
      return Math.max(current, ...obj.map(v => this.nestingDepth(v, current + 1)))
    }
    if (obj && typeof obj === "object") {
      const vals = Object.values(obj)
      if (vals.length === 0) return current
      return Math.max(current, ...vals.map(v => this.nestingDepth(v, current + 1)))
    }
    return current
  }

  formatBytes(bytes) {
    if (bytes === 0) return "0 B"
    if (bytes < 1024) return bytes + " B"
    return (bytes / 1024).toFixed(2) + " KB"
  }

  clearResults() {
    this.resultStatusTarget.textContent = "\u2014"
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultKeyCountTarget.textContent = "\u2014"
    this.resultDepthTarget.textContent = "\u2014"
    this.resultTypeTarget.textContent = "\u2014"
    this.resultSizeTarget.textContent = "\u2014"
    this.outputFormattedTarget.value = ""
  }

  copy() {
    navigator.clipboard.writeText(this.outputFormattedTarget.value)
  }
}
