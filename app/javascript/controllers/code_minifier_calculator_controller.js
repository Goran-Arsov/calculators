import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "language", "output",
    "resultOriginalSize", "resultProcessedSize", "resultSavings"
  ]

  minify() {
    this.process("minify")
  }

  beautify() {
    this.process("beautify")
  }

  process(action) {
    const code = this.inputTarget.value
    if (!code || !code.trim()) {
      this.clearResults()
      return
    }

    const language = this.languageTarget.value

    try {
      let result
      if (language === "json") {
        result = action === "minify" ? this.minifyJson(code) : this.beautifyJson(code)
      } else if (language === "css") {
        result = action === "minify" ? this.minifyCss(code) : this.beautifyCss(code)
      } else if (language === "html") {
        result = action === "minify" ? this.minifyHtml(code) : this.beautifyHtml(code)
      } else if (language === "javascript") {
        result = action === "minify" ? this.minifyJavascript(code) : this.beautifyJavascript(code)
      }

      const originalSize = new Blob([code]).size
      const processedSize = new Blob([result]).size
      const savings = originalSize > 0 ? ((originalSize - processedSize) / originalSize * 100).toFixed(2) : "0.00"

      this.outputTarget.value = result
      this.resultOriginalSizeTarget.textContent = this.formatBytes(originalSize)
      this.resultProcessedSizeTarget.textContent = this.formatBytes(processedSize)
      this.resultSavingsTarget.textContent = savings + "%"

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
      this.resultOriginalSizeTarget.textContent = "\u2014"
      this.resultProcessedSizeTarget.textContent = "\u2014"
      this.resultSavingsTarget.textContent = "\u2014"
    }
  }

  // --- JSON ---

  minifyJson(code) {
    return JSON.stringify(JSON.parse(code))
  }

  beautifyJson(code) {
    return JSON.stringify(JSON.parse(code), null, 2)
  }

  // --- CSS ---

  minifyCss(code) {
    let result = code
    result = result.replace(/\/\*[\s\S]*?\*\//g, "")  // remove block comments
    result = result.replace(/\s+/g, " ")                // collapse whitespace
    result = result.replace(/\s*([{}:;,])\s*/g, "$1")   // remove spaces around syntax
    result = result.replace(/;(?=\})/g, "")             // remove trailing ; before }
    return result.trim()
  }

  beautifyCss(code) {
    let result = code
    result = result.replace(/\/\*[\s\S]*?\*\//g, "")
    result = result.replace(/\s+/g, " ")
    result = result.trim()

    result = result.replace(/\s*\{\s*/g, " {\n")
    result = result.replace(/\s*\}\s*/g, "\n}\n")
    result = result.replace(/\s*;\s*/g, ";\n")

    let output = ""
    let indent = 0

    result.split("\n").forEach(line => {
      const stripped = line.trim()
      if (!stripped) return

      if (stripped.startsWith("}")) {
        indent--
        if (indent < 0) indent = 0
      }
      output += "  ".repeat(indent) + stripped + "\n"
      if (stripped.endsWith("{")) {
        indent++
      }
    })

    return output.trim()
  }

  // --- HTML ---

  minifyHtml(code) {
    let result = code
    result = result.replace(/<!--[\s\S]*?-->/g, "")    // remove comments
    result = result.replace(/>\s+</g, "><")             // collapse whitespace between tags
    result = result.replace(/\s+/g, " ")                // collapse remaining whitespace
    return result.trim()
  }

  beautifyHtml(code) {
    let result = code
    result = result.replace(/<!--[\s\S]*?-->/g, "")
    result = result.replace(/>\s+</g, "><")
    result = result.replace(/\s+/g, " ")
    result = result.trim()

    const tokens = result.match(/<[^>]+>|[^<]+/g) || []
    const voidElements = ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"]

    let output = ""
    let indent = 0

    tokens.forEach(token => {
      const trimmed = token.trim()
      if (!trimmed) return

      if (trimmed.startsWith("</")) {
        indent--
        if (indent < 0) indent = 0
        output += "  ".repeat(indent) + trimmed + "\n"
      } else if (trimmed.startsWith("<")) {
        const tagMatch = trimmed.match(/<(\w+)/)
        const tagName = tagMatch ? tagMatch[1].toLowerCase() : ""
        const isVoid = voidElements.includes(tagName)
        const isSelfClosing = trimmed.endsWith("/>")

        output += "  ".repeat(indent) + trimmed + "\n"
        if (!isVoid && !isSelfClosing && !trimmed.startsWith("<!")) {
          indent++
        }
      } else {
        output += "  ".repeat(indent) + trimmed + "\n"
      }
    })

    return output.trim()
  }

  // --- JavaScript ---

  minifyJavascript(code) {
    let result = code
    result = result.replace(/\/\*[\s\S]*?\*\//g, "")  // remove multi-line comments
    result = this.removeSingleLineComments(result)
    result = result.replace(/\s+/g, " ")
    result = result.replace(/\s*([{}();,=+\-*\/<>!&|:?])\s*/g, "$1")
    return result.trim()
  }

  beautifyJavascript(code) {
    let result = code
    result = result.replace(/\/\*[\s\S]*?\*\//g, "")
    result = this.removeSingleLineComments(result)
    result = result.replace(/\s+/g, " ")
    result = result.trim()

    result = result.replace(/\s*\{\s*/g, " {\n")
    result = result.replace(/\s*\}\s*/g, "\n}\n")
    result = result.replace(/\s*;\s*/g, ";\n")

    let output = ""
    let indent = 0

    result.split("\n").forEach(line => {
      const stripped = line.trim()
      if (!stripped) return

      if (stripped.startsWith("}")) {
        indent--
        if (indent < 0) indent = 0
      }
      output += "  ".repeat(indent) + stripped + "\n"
      if (stripped.endsWith("{")) {
        indent++
      }
    })

    return output.trim()
  }

  removeSingleLineComments(code) {
    return code.split("\n").map(line => {
      let inString = false
      let stringChar = null

      for (let i = 0; i < line.length; i++) {
        const char = line[i]

        if (inString) {
          if (char === "\\" ) {
            i++
            continue
          }
          if (char === stringChar) {
            inString = false
          }
        } else if (char === '"' || char === "'") {
          inString = true
          stringChar = char
        } else if (char === "/" && line[i + 1] === "/") {
          return line.substring(0, i)
        }
      }

      return line
    }).join("\n")
  }

  formatBytes(bytes) {
    if (bytes === 0) return "0 B"
    if (bytes < 1024) return bytes + " B"
    return (bytes / 1024).toFixed(2) + " KB"
  }

  clearResults() {
    this.outputTarget.value = ""
    this.resultOriginalSizeTarget.textContent = "\u2014"
    this.resultProcessedSizeTarget.textContent = "\u2014"
    this.resultSavingsTarget.textContent = "\u2014"
    this.resultSavingsTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
  }

  copy() {
    navigator.clipboard.writeText(this.outputTarget.value)
  }
}
