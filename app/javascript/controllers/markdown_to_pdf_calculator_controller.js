import { Controller } from "@hotwired/stimulus"
import { downloadHtmlAsPdf } from "utils/html_to_pdf"

export default class extends Controller {
  static targets = [
    "markdownInput", "fileInput", "preview",
    "downloadBtn", "resultWords", "resultHeadings", "resultLines"
  ]

  connect() {
    this.updateStats()
  }

  loadFile() {
    const file = this.fileInputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      this.markdownInputTarget.value = e.target.result
      this.convert()
    }
    reader.readAsText(file)
  }

  convert() {
    const md = this.markdownInputTarget.value
    this.updateStats()

    if (!md.trim()) {
      this.previewTarget.innerHTML = ""
      this.downloadBtnTarget.disabled = true
      return
    }

    this.previewTarget.innerHTML = this.markdownToHtml(md)
    this.downloadBtnTarget.disabled = false
  }

  updateStats() {
    const md = this.markdownInputTarget.value
    if (!md.trim()) {
      this.resultWordsTarget.textContent = "--"
      this.resultHeadingsTarget.textContent = "--"
      this.resultLinesTarget.textContent = "--"
      return
    }

    const lines = md.split("\n")
    const words = md.split(/\s+/).filter(w => w.length > 0).length
    const headings = lines.filter(l => /^#{1,6}\s/.test(l)).length

    this.resultWordsTarget.textContent = words
    this.resultHeadingsTarget.textContent = headings
    this.resultLinesTarget.textContent = lines.length
  }

  async download() {
    const md = this.markdownInputTarget.value
    if (!md.trim()) return

    const btn = this.downloadBtnTarget
    btn.disabled = true
    btn.style.opacity = "0.7"

    try {
      const html = this.markdownToHtml(md)
      await downloadHtmlAsPdf(html, { filename: "document.pdf" })
    } catch (err) {
      console.error("[markdown-to-pdf] PDF generation failed", err)
    } finally {
      btn.disabled = false
      btn.style.opacity = ""
    }
  }

  // --- Markdown to HTML (used for live preview and PDF rasterization) ---

  markdownToHtml(md) {
    const lines = md.split("\n")
    const parts = []
    let i = 0

    while (i < lines.length) {
      const line = lines[i]

      // Fenced code block
      if (line.startsWith("```")) {
        const lang = line.slice(3).trim()
        const codeLines = []
        i++
        while (i < lines.length && !lines[i].startsWith("```")) {
          codeLines.push(this.escapeHtml(lines[i]))
          i++
        }
        i++
        const cls = lang ? ` class="language-${this.escapeHtml(lang)}"` : ""
        parts.push(`<pre><code${cls}>${codeLines.join("\n")}</code></pre>`)
        continue
      }

      // Heading
      const headingMatch = line.match(/^(#{1,6})\s+(.+)/)
      if (headingMatch) {
        const level = headingMatch[1].length
        const content = this.inlineFormat(headingMatch[2].trim())
        parts.push(`<h${level}>${content}</h${level}>`)
        i++
        continue
      }

      // Horizontal rule
      if (/^(\*{3,}|-{3,}|_{3,})\s*$/.test(line)) {
        parts.push("<hr>")
        i++
        continue
      }

      // Blockquote
      if (line.startsWith("> ")) {
        const quoteLines = []
        while (i < lines.length && lines[i].startsWith("> ")) {
          quoteLines.push(lines[i].replace(/^>\s?/, ""))
          i++
        }
        parts.push(`<blockquote><p>${this.inlineFormat(quoteLines.join(" "))}</p></blockquote>`)
        continue
      }

      // Unordered list
      if (/^\s*[-*+]\s+/.test(line)) {
        const items = []
        while (i < lines.length && /^\s*[-*+]\s+/.test(lines[i])) {
          items.push(this.inlineFormat(lines[i].replace(/^\s*[-*+]\s+/, "")))
          i++
        }
        parts.push(`<ul>${items.map(li => `<li>${li}</li>`).join("")}</ul>`)
        continue
      }

      // Ordered list
      if (/^\s*\d+\.\s+/.test(line)) {
        const items = []
        while (i < lines.length && /^\s*\d+\.\s+/.test(lines[i])) {
          items.push(this.inlineFormat(lines[i].replace(/^\s*\d+\.\s+/, "")))
          i++
        }
        parts.push(`<ol>${items.map(li => `<li>${li}</li>`).join("")}</ol>`)
        continue
      }

      // Empty line
      if (line.trim() === "") {
        i++
        continue
      }

      // Paragraph
      const paraLines = []
      while (
        i < lines.length &&
        lines[i].trim() !== "" &&
        !/^(#{1,6}\s|```|>\s|[-*+]\s|\d+\.\s|\*{3,}|-{3,}|_{3,})/.test(lines[i])
      ) {
        paraLines.push(lines[i])
        i++
      }
      parts.push(`<p>${this.inlineFormat(paraLines.join(" "))}</p>`)
    }

    return parts.join("\n")
  }

  inlineFormat(text) {
    text = this.escapeHtml(text)
    text = text.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img src="$2" alt="$1">')
    text = text.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>')
    text = text.replace(/\*{3}(.+?)\*{3}/g, "<strong><em>$1</em></strong>")
    text = text.replace(/\*{2}(.+?)\*{2}/g, "<strong>$1</strong>")
    text = text.replace(/_{2}(.+?)_{2}/g, "<strong>$1</strong>")
    text = text.replace(/\*(.+?)\*/g, "<em>$1</em>")
    text = text.replace(/_(.+?)_/g, "<em>$1</em>")
    text = text.replace(/`([^`]+)`/g, "<code>$1</code>")
    text = text.replace(/~~(.+?)~~/g, "<del>$1</del>")
    return text
  }

  escapeHtml(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }
}
