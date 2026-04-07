import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "output",
    "resultJsonSize", "resultYamlSize", "resultKeyCount", "resultRootType"
  ]

  convert() {
    const text = this.inputTarget.value
    if (!text || !text.trim()) {
      this.clearResults()
      return
    }

    try {
      const parsed = JSON.parse(text)
      const yaml = this.toYaml(parsed, 0)

      this.outputTarget.value = yaml
      this.resultJsonSizeTarget.textContent = this.formatBytes(new Blob([text]).size)
      this.resultYamlSizeTarget.textContent = this.formatBytes(new Blob([yaml]).size)
      this.resultKeyCountTarget.textContent = this.countKeys(parsed).toLocaleString()
      this.resultRootTypeTarget.textContent = Array.isArray(parsed) ? "Array" : "Object"
    } catch (e) {
      this.outputTarget.value = "Error: " + e.message
      this.clearStats()
    }
  }

  toYaml(value, indent) {
    const prefix = "  ".repeat(indent)

    if (value === null) return "null"
    if (value === undefined) return "null"
    if (typeof value === "boolean") return value.toString()
    if (typeof value === "number") return value.toString()
    if (typeof value === "string") {
      if (value.includes("\n")) return "|\n" + value.split("\n").map(l => prefix + "  " + l).join("\n")
      if (value.match(/[:#{}[\],&*?|<>=!%@`]/)) return `"${value.replace(/\\/g, "\\\\").replace(/"/g, '\\"')}"`
      if (value === "") return '""'
      return value
    }

    if (Array.isArray(value)) {
      if (value.length === 0) return "[]"
      return value.map(item => {
        const yamlItem = this.toYaml(item, indent + 1)
        if (typeof item === "object" && item !== null) {
          return prefix + "- " + yamlItem.trimStart()
        }
        return prefix + "- " + yamlItem
      }).join("\n")
    }

    if (typeof value === "object") {
      const keys = Object.keys(value)
      if (keys.length === 0) return "{}"
      return keys.map(key => {
        const val = value[key]
        const yamlVal = this.toYaml(val, indent + 1)
        if (typeof val === "object" && val !== null && !Array.isArray(val) && Object.keys(val).length > 0) {
          return prefix + key + ":\n" + yamlVal
        }
        if (Array.isArray(val) && val.length > 0) {
          return prefix + key + ":\n" + yamlVal
        }
        return prefix + key + ": " + yamlVal
      }).join("\n")
    }

    return String(value)
  }

  countKeys(obj) {
    if (Array.isArray(obj)) return obj.reduce((sum, v) => sum + this.countKeys(v), 0)
    if (obj && typeof obj === "object") return Object.keys(obj).length + Object.values(obj).reduce((sum, v) => sum + this.countKeys(v), 0)
    return 0
  }

  formatBytes(bytes) {
    if (bytes === 0) return "0 B"
    if (bytes < 1024) return bytes + " B"
    return (bytes / 1024).toFixed(2) + " KB"
  }

  clearStats() {
    this.resultJsonSizeTarget.textContent = "\u2014"
    this.resultYamlSizeTarget.textContent = "\u2014"
    this.resultKeyCountTarget.textContent = "\u2014"
    this.resultRootTypeTarget.textContent = "\u2014"
  }

  clearResults() {
    this.outputTarget.value = ""
    this.clearStats()
  }

  copy() {
    navigator.clipboard.writeText(this.outputTarget.value)
  }
}
