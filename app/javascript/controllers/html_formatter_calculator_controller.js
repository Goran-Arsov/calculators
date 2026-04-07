import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "output",
    "resultOriginalSize", "resultProcessedSize", "resultSavings",
    "resultTagCount"
  ]

  static VOID_ELEMENTS = ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"]

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
      const result = action === "minify" ? this.minifyHtml(code) : this.beautifyHtml(code)
      const originalSize = new Blob([code]).size
      const processedSize = new Blob([result]).size
      const savings = originalSize > 0 ? ((originalSize - processedSize) / originalSize * 100).toFixed(2) : "0.00"

      this.outputTarget.value = result
      this.resultOriginalSizeTarget.textContent = this.formatBytes(originalSize)
      this.resultProcessedSizeTarget.textContent = this.formatBytes(processedSize)
      this.resultSavingsTarget.textContent = savings + "%"
      this.resultTagCountTarget.textContent = this.countTags(code).toLocaleString()

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

  minifyHtml(code) {
    let result = code
    result = result.replace(/<!--.*?-->/gs, "")
    result = result.replace(/>\s+</g, "><")
    result = result.replace(/\s+/g, " ")
    return result.trim()
  }

  beautifyHtml(code) {
    let result = code
    result = result.replace(/<!--.*?-->/gs, "")
    result = result.replace(/>\s+</g, "><")
    result = result.replace(/\s+/g, " ")
    result = result.trim()

    const tokens = result.match(/(<[^>]+>|[^<]+)/g) || []
    const cleaned = tokens.map(t => t.trim()).filter(t => t.length > 0)

    let output = ""
    let indent = 0
    const voidElements = this.constructor.VOID_ELEMENTS

    for (const token of cleaned) {
      if (token.startsWith("</")) {
        indent--
        if (indent < 0) indent = 0
        output += "  ".repeat(indent) + token + "\n"
      } else if (token.startsWith("<")) {
        const match = token.match(/<(\w+)/)
        const tagName = match ? match[1].toLowerCase() : ""
        const isVoid = voidElements.includes(tagName)
        const isSelfClosing = token.endsWith("/>")

        output += "  ".repeat(indent) + token + "\n"
        if (!isVoid && !isSelfClosing && !token.startsWith("<!")) {
          indent++
        }
      } else {
        output += "  ".repeat(indent) + token + "\n"
      }
    }

    return output.trimEnd()
  }

  countTags(html) {
    const matches = html.match(/<[a-zA-Z][^>]*>/g)
    return matches ? matches.length : 0
  }

  clearStats() {
    this.resultOriginalSizeTarget.textContent = "\u2014"
    this.resultProcessedSizeTarget.textContent = "\u2014"
    this.resultSavingsTarget.textContent = "\u2014"
    this.resultSavingsTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultTagCountTarget.textContent = "\u2014"
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
