import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "output",
    "resultOriginalSize", "resultProcessedSize", "resultSavings",
    "resultRuleCount", "resultSelectorCount"
  ]

  beautify() {
    this.process("beautify")
  }

  minify() {
    this.process("minify")
  }

  process(action) {
    const code = this.inputTarget.value
    if (!code || !code.trim()) {
      this.clearResults()
      return
    }

    try {
      const result = action === "minify" ? this.minifyCss(code) : this.beautifyCss(code)
      const originalSize = new Blob([code]).size
      const processedSize = new Blob([result]).size
      const savings = originalSize > 0 ? ((originalSize - processedSize) / originalSize * 100).toFixed(2) : "0.00"

      this.outputTarget.value = result
      this.resultOriginalSizeTarget.textContent = this.formatBytes(originalSize)
      this.resultProcessedSizeTarget.textContent = this.formatBytes(processedSize)
      this.resultSavingsTarget.textContent = savings + "%"
      this.resultRuleCountTarget.textContent = this.countRules(code).toLocaleString()
      this.resultSelectorCountTarget.textContent = this.countSelectors(code).toLocaleString()

      if (parseFloat(savings) > 0) {
        this.resultSavingsTarget.classList.remove("text-red-500", "dark:text-red-400")
        this.resultSavingsTarget.classList.add("text-green-600", "dark:text-green-400")
      } else if (parseFloat(savings) < 0) {
        this.resultSavingsTarget.classList.remove("text-green-600", "dark:text-green-400")
        this.resultSavingsTarget.classList.add("text-red-500", "dark:text-red-400")
      } else {
        this.resultSavingsTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
      }
    } catch (e) {
      this.outputTarget.value = "Error: " + e.message
      this.clearStats()
    }
  }

  minifyCss(code) {
    let result = code
    result = result.replace(/\/\*.*?\*\//gs, "")
    result = result.replace(/\s+/g, " ")
    result = result.replace(/\s*([{}:;,])\s*/g, "$1")
    result = result.replace(/;(?=\})/g, "")
    return result.trim()
  }

  beautifyCss(code) {
    let result = code
    result = result.replace(/\/\*.*?\*\//gs, "")
    result = result.replace(/\s+/g, " ")
    result = result.trim()

    result = result.replace(/\s*\{\s*/g, " {\n")
    result = result.replace(/\s*\}\s*/g, "\n}\n")
    result = result.replace(/\s*;\s*/g, ";\n")

    let output = ""
    let indent = 0

    for (const line of result.split("\n")) {
      const stripped = line.trim()
      if (!stripped) continue

      if (stripped.startsWith("}")) {
        indent--
        if (indent < 0) indent = 0
      }
      output += "  ".repeat(indent) + stripped + "\n"
      if (stripped.endsWith("{")) {
        indent++
      }
    }

    return output.trimEnd()
  }

  countRules(css) {
    const clean = css.replace(/\/\*.*?\*\//gs, "")
    const matches = clean.match(/\{/g)
    return matches ? matches.length : 0
  }

  countSelectors(css) {
    const clean = css.replace(/\/\*.*?\*\//gs, "")
    const matches = clean.match(/[^{}]+(?=\s*\{)/g)
    return matches ? matches.length : 0
  }

  clearStats() {
    this.resultOriginalSizeTarget.textContent = "\u2014"
    this.resultProcessedSizeTarget.textContent = "\u2014"
    this.resultSavingsTarget.textContent = "\u2014"
    this.resultSavingsTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultRuleCountTarget.textContent = "\u2014"
    this.resultSelectorCountTarget.textContent = "\u2014"
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
