import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["markdownInput", "htmlOutput", "htmlPreview", "resultInputLen", "resultOutputLen"]

  convert() {
    const md = this.markdownInputTarget.value
    if (!md.trim()) {
      this.htmlOutputTarget.value = ""
      this.htmlPreviewTarget.innerHTML = ""
      this.resultInputLenTarget.textContent = "--"
      this.resultOutputLenTarget.textContent = "--"
      return
    }

    const html = this.markdownToHtml(md)
    this.htmlOutputTarget.value = html
    this.htmlPreviewTarget.innerHTML = html
    this.resultInputLenTarget.textContent = md.length
    this.resultOutputLenTarget.textContent = html.length
  }

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
        i++ // skip closing
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

      // Table
      if (line.includes("|") && i + 1 < lines.length && /^\s*\|?\s*-+/.test(lines[i + 1])) {
        const tableRows = []
        while (i < lines.length && lines[i].includes("|")) {
          tableRows.push(lines[i])
          i++
        }
        parts.push(this.parseTable(tableRows))
        continue
      }

      // Empty line
      if (line.trim() === "") {
        i++
        continue
      }

      // Paragraph
      const paraLines = []
      while (i < lines.length && lines[i].trim() !== "" && !/^(#{1,6}\s|```|>\s|[-*+]\s|\d+\.\s|\*{3,}|-{3,}|_{3,})/.test(lines[i])) {
        paraLines.push(lines[i])
        i++
      }
      parts.push(`<p>${this.inlineFormat(paraLines.join(" "))}</p>`)
    }

    return parts.join("\n")
  }

  parseTable(rows) {
    if (rows.length < 2) return ""

    const parseRow = (row) => row.split("|").map(c => c.trim()).filter((_, idx, arr) => idx > 0 && idx < arr.length)

    const headers = parseRow(rows[0])
    // rows[1] is separator, skip
    const body = rows.slice(2).map(r => parseRow(r))

    let html = "<table><thead><tr>"
    headers.forEach(h => { html += `<th>${this.inlineFormat(h)}</th>` })
    html += "</tr></thead><tbody>"
    body.forEach(row => {
      html += "<tr>"
      row.forEach(cell => { html += `<td>${this.inlineFormat(cell)}</td>` })
      html += "</tr>"
    })
    html += "</tbody></table>"
    return html
  }

  inlineFormat(text) {
    text = this.escapeHtml(text)
    // Images before links
    text = text.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img src="$2" alt="$1">')
    // Links
    text = text.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>')
    // Bold+italic
    text = text.replace(/\*{3}(.+?)\*{3}/g, "<strong><em>$1</em></strong>")
    // Bold
    text = text.replace(/\*{2}(.+?)\*{2}/g, "<strong>$1</strong>")
    text = text.replace(/_{2}(.+?)_{2}/g, "<strong>$1</strong>")
    // Italic
    text = text.replace(/\*(.+?)\*/g, "<em>$1</em>")
    text = text.replace(/_(.+?)_/g, "<em>$1</em>")
    // Inline code
    text = text.replace(/`([^`]+)`/g, "<code>$1</code>")
    // Strikethrough
    text = text.replace(/~~(.+?)~~/g, "<del>$1</del>")
    return text
  }

  escapeHtml(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }

  copyHtml() {
    const text = this.htmlOutputTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      this.flashButton("copyHtml")
    })
  }

  flashButton(action) {
    const btn = this.element.querySelector(`[data-action*="${action}"]`)
    if (btn) {
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 1500)
    }
  }
}
