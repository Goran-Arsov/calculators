import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "output",
    "resultOriginalSize", "resultProcessedSize", "resultSavings",
    "resultLineCount", "resultFunctionCount"
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
      const result = action === "minify" ? this.minifyJs(code) : this.beautifyJs(code)
      const originalSize = new Blob([code]).size
      const processedSize = new Blob([result]).size
      const savings = originalSize > 0 ? ((originalSize - processedSize) / originalSize * 100).toFixed(2) : "0.00"

      this.outputTarget.value = result
      this.resultOriginalSizeTarget.textContent = this.formatBytes(originalSize)
      this.resultProcessedSizeTarget.textContent = this.formatBytes(processedSize)
      this.resultSavingsTarget.textContent = savings + "%"
      this.resultLineCountTarget.textContent = result.split("\n").length.toLocaleString()
      this.resultFunctionCountTarget.textContent = this.countFunctions(code).toLocaleString()

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

  minifyJs(code) {
    let result = this.removeComments(code)
    result = result.replace(/\s+/g, " ")
    result = result.replace(/\s*([{}();,=+\-*\/<>!&|:?])\s*/g, "$1")
    return result.trim()
  }

  beautifyJs(code) {
    let result = this.removeComments(code)
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

  removeComments(code) {
    // Remove multi-line comments
    code = code.replace(/\/\*.*?\*\//gs, "")

    // Remove single-line comments, preserving strings
    return code.split("\n").map(line => {
      let inString = false
      let stringChar = null

      for (let i = 0; i < line.length; i++) {
        const char = line[i]

        if (inString) {
          if (char === "\\") {
            i++
            continue
          }
          if (char === stringChar) {
            inString = false
          }
        } else if (char === '"' || char === "'" || char === '`') {
          inString = true
          stringChar = char
        } else if (char === "/" && line[i + 1] === "/") {
          return line.substring(0, i)
        }
      }

      return line
    }).join("\n")
  }

  countFunctions(code) {
    const clean = this.removeComments(code)
    const declarations = (clean.match(/\bfunction\b/g) || []).length
    const arrows = (clean.match(/=>/g) || []).length
    return declarations + arrows
  }

  clearStats() {
    this.resultOriginalSizeTarget.textContent = "\u2014"
    this.resultProcessedSizeTarget.textContent = "\u2014"
    this.resultSavingsTarget.textContent = "\u2014"
    this.resultSavingsTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultLineCountTarget.textContent = "\u2014"
    this.resultFunctionCountTarget.textContent = "\u2014"
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
