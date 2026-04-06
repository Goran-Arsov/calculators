import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "format", "output",
    "resultInputLength", "resultOutputLength"
  ]

  escape() {
    this.process("escape")
  }

  unescape() {
    this.process("unescape")
  }

  process(action) {
    const text = this.inputTarget.value
    if (!text) {
      this.clearResults()
      return
    }

    const format = this.formatTarget.value

    try {
      let result
      if (action === "escape") {
        result = this.escapeText(text, format)
      } else {
        result = this.unescapeText(text, format)
      }

      this.outputTarget.value = result
      this.resultInputLengthTarget.textContent = text.length.toLocaleString()
      this.resultOutputLengthTarget.textContent = result.length.toLocaleString()
    } catch (e) {
      this.outputTarget.value = "Error: " + e.message
      this.resultInputLengthTarget.textContent = text.length.toLocaleString()
      this.resultOutputLengthTarget.textContent = "\u2014"
    }
  }

  escapeText(text, format) {
    switch (format) {
      case "json":
        return this.escapeJson(text)
      case "url":
        return encodeURIComponent(text)
      case "html":
        return this.escapeHtml(text)
      case "backslash":
        return this.escapeBackslash(text)
      case "unicode":
        return this.escapeUnicode(text)
      default:
        return text
    }
  }

  unescapeText(text, format) {
    switch (format) {
      case "json":
        return this.unescapeJson(text)
      case "url":
        return decodeURIComponent(text)
      case "html":
        return this.unescapeHtml(text)
      case "backslash":
        return this.unescapeBackslash(text)
      case "unicode":
        return this.unescapeUnicode(text)
      default:
        return text
    }
  }

  // --- JSON ---

  escapeJson(text) {
    return text
      .replace(/\\/g, "\\\\")
      .replace(/"/g, '\\"')
      .replace(/\n/g, "\\n")
      .replace(/\r/g, "\\r")
      .replace(/\t/g, "\\t")
      .replace(/\b/g, "\\b")
      .replace(/\f/g, "\\f")
  }

  unescapeJson(text) {
    return text
      .replace(/\\n/g, "\n")
      .replace(/\\r/g, "\r")
      .replace(/\\t/g, "\t")
      .replace(/\\b/g, "\b")
      .replace(/\\f/g, "\f")
      .replace(/\\"/g, '"')
      .replace(/\\\\/g, "\\")
  }

  // --- HTML ---

  escapeHtml(text) {
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
  }

  unescapeHtml(text) {
    const textarea = document.createElement("textarea")
    textarea.innerHTML = text
    return textarea.value
  }

  // --- Backslash ---

  escapeBackslash(text) {
    return text
      .replace(/\\/g, "\\\\")
      .replace(/\n/g, "\\n")
      .replace(/\t/g, "\\t")
      .replace(/\r/g, "\\r")
      .replace(/"/g, '\\"')
  }

  unescapeBackslash(text) {
    return text
      .replace(/\\n/g, "\n")
      .replace(/\\t/g, "\t")
      .replace(/\\r/g, "\r")
      .replace(/\\"/g, '"')
      .replace(/\\\\/g, "\\")
  }

  // --- Unicode ---

  escapeUnicode(text) {
    let result = ""
    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i)
      if (code > 127) {
        result += "\\u" + code.toString(16).toUpperCase().padStart(4, "0")
      } else {
        result += text[i]
      }
    }
    return result
  }

  unescapeUnicode(text) {
    return text.replace(/\\u([0-9A-Fa-f]{4})/g, (_, hex) => {
      return String.fromCharCode(parseInt(hex, 16))
    })
  }

  clearResults() {
    this.outputTarget.value = ""
    this.resultInputLengthTarget.textContent = "\u2014"
    this.resultOutputLengthTarget.textContent = "\u2014"
  }

  copy() {
    navigator.clipboard.writeText(this.outputTarget.value)
  }
}
