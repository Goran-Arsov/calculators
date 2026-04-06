import { Controller } from "@hotwired/stimulus"
import { PdfDocument } from "utils/pdf_generator"

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

  download() {
    const md = this.markdownInputTarget.value
    if (!md.trim()) return

    const pdf = new PdfDocument()
    this.renderMarkdownToPdf(pdf, md)
    const buffer = pdf.generate()

    const blob = new Blob([buffer], { type: "application/pdf" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "document.pdf"
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }

  // --- Markdown to PDF rendering ---

  renderMarkdownToPdf(pdf, md) {
    const lines = md.split("\n")
    let i = 0

    while (i < lines.length) {
      const line = lines[i]

      // Fenced code block
      if (line.startsWith("```")) {
        const codeLines = []
        i++
        while (i < lines.length && !lines[i].startsWith("```")) {
          codeLines.push(lines[i])
          i++
        }
        i++ // skip closing ```
        pdf.addCodeBlock(codeLines.join("\n"))
        continue
      }

      // Heading
      const headingMatch = line.match(/^(#{1,6})\s+(.+)/)
      if (headingMatch) {
        const level = headingMatch[1].length
        const text = this.stripInlineMarkdown(headingMatch[2].trim())
        pdf.addHeading(text, level)
        i++
        continue
      }

      // Horizontal rule
      if (/^(\*{3,}|-{3,}|_{3,})\s*$/.test(line)) {
        pdf.addHorizontalRule()
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
        const quoteText = this.stripInlineMarkdown(quoteLines.join(" "))
        pdf.addParagraph(quoteText, { font: "Helvetica-Bold", fontSize: 10, color: [0.4, 0.4, 0.4] })
        continue
      }

      // Unordered list
      if (/^\s*[-*+]\s+/.test(line)) {
        while (i < lines.length && /^\s*[-*+]\s+/.test(lines[i])) {
          const itemText = this.stripInlineMarkdown(lines[i].replace(/^\s*[-*+]\s+/, ""))
          pdf.addListItem(itemText)
          i++
        }
        continue
      }

      // Ordered list
      if (/^\s*\d+\.\s+/.test(line)) {
        let num = 1
        while (i < lines.length && /^\s*\d+\.\s+/.test(lines[i])) {
          const itemText = this.stripInlineMarkdown(lines[i].replace(/^\s*\d+\.\s+/, ""))
          pdf.addListItem(itemText, `${num}.`)
          num++
          i++
        }
        continue
      }

      // Empty line
      if (line.trim() === "") {
        i++
        continue
      }

      // Paragraph — collect consecutive non-special lines
      const paraLines = []
      while (
        i < lines.length &&
        lines[i].trim() !== "" &&
        !/^(#{1,6}\s|```|>\s|[-*+]\s|\d+\.\s|\*{3,}|-{3,}|_{3,})/.test(lines[i])
      ) {
        paraLines.push(lines[i])
        i++
      }
      const paraText = this.stripInlineMarkdown(paraLines.join(" "))
      pdf.addParagraph(paraText)
    }
  }

  // Strip inline markdown formatting for PDF text
  stripInlineMarkdown(text) {
    // Images
    text = text.replace(/!\[([^\]]*)\]\([^)]+\)/g, "$1")
    // Links — keep link text
    text = text.replace(/\[([^\]]+)\]\([^)]+\)/g, "$1")
    // Bold+italic
    text = text.replace(/\*{3}(.+?)\*{3}/g, "$1")
    // Bold
    text = text.replace(/\*{2}(.+?)\*{2}/g, "$1")
    text = text.replace(/_{2}(.+?)_{2}/g, "$1")
    // Italic
    text = text.replace(/\*(.+?)\*/g, "$1")
    text = text.replace(/_(.+?)_/g, "$1")
    // Inline code
    text = text.replace(/`([^`]+)`/g, "$1")
    // Strikethrough
    text = text.replace(/~~(.+?)~~/g, "$1")
    return text
  }

  // --- Markdown to HTML for live preview ---

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
