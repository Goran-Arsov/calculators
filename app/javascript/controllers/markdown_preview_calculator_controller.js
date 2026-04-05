import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "output",
    "resultWordCount", "resultLineCount", "resultHeadingCount"
  ]

  calculate() {
    const text = this.inputTarget.value
    if (!text || !text.trim()) {
      this.clearResults()
      return
    }

    const html = this.markdownToHtml(text)
    this.outputTarget.innerHTML = html

    const words = text.split(/\s+/).filter(w => w.length > 0).length
    const lines = text.split("\n").length
    const headings = (text.match(/^#{1,6}\s/gm) || []).length

    this.resultWordCountTarget.textContent = words.toLocaleString()
    this.resultLineCountTarget.textContent = lines.toLocaleString()
    this.resultHeadingCountTarget.textContent = headings.toLocaleString()
  }

  markdownToHtml(text) {
    const lines = text.split("\n")
    const htmlLines = []
    let inCodeBlock = false
    let inList = false
    let listType = null

    for (const line of lines) {
      // Code blocks
      if (line.trim().startsWith("```")) {
        if (inCodeBlock) {
          htmlLines.push("</code></pre>")
          inCodeBlock = false
        } else {
          this.closeList(htmlLines, inList, listType)
          inList = false
          htmlLines.push("<pre><code>")
          inCodeBlock = true
        }
        continue
      }

      if (inCodeBlock) {
        htmlLines.push(this.escapeHtml(line))
        continue
      }

      // Blank lines
      if (!line.trim()) {
        this.closeList(htmlLines, inList, listType)
        inList = false
        continue
      }

      // Headings
      const headingMatch = line.match(/^(#{1,6})\s+(.*)/)
      if (headingMatch) {
        this.closeList(htmlLines, inList, listType)
        inList = false
        const level = headingMatch[1].length
        const content = this.inlineFormatting(headingMatch[2])
        htmlLines.push(`<h${level} class="text-${4 - Math.min(level, 3)}xl font-bold mt-4 mb-2 text-gray-900 dark:text-white">${content}</h${level}>`)
        continue
      }

      // Unordered lists
      const ulMatch = line.match(/^\s*[-*+]\s+(.*)/)
      if (ulMatch) {
        if (!inList || listType !== "ul") {
          this.closeList(htmlLines, inList, listType)
          htmlLines.push('<ul class="list-disc pl-6 my-2 space-y-1 text-gray-700 dark:text-gray-300">')
          inList = true
          listType = "ul"
        }
        htmlLines.push(`<li>${this.inlineFormatting(ulMatch[1])}</li>`)
        continue
      }

      // Ordered lists
      const olMatch = line.match(/^\s*\d+\.\s+(.*)/)
      if (olMatch) {
        if (!inList || listType !== "ol") {
          this.closeList(htmlLines, inList, listType)
          htmlLines.push('<ol class="list-decimal pl-6 my-2 space-y-1 text-gray-700 dark:text-gray-300">')
          inList = true
          listType = "ol"
        }
        htmlLines.push(`<li>${this.inlineFormatting(olMatch[1])}</li>`)
        continue
      }

      // Horizontal rule
      if (/^(\*{3,}|-{3,}|_{3,})$/.test(line.trim())) {
        this.closeList(htmlLines, inList, listType)
        inList = false
        htmlLines.push('<hr class="my-4 border-gray-300 dark:border-gray-600">')
        continue
      }

      // Blockquote
      const bqMatch = line.match(/^>\s?(.*)/)
      if (bqMatch) {
        this.closeList(htmlLines, inList, listType)
        inList = false
        htmlLines.push(`<blockquote class="border-l-4 border-gray-300 dark:border-gray-600 pl-4 my-2 text-gray-600 dark:text-gray-400 italic">${this.inlineFormatting(bqMatch[1])}</blockquote>`)
        continue
      }

      // Regular paragraph
      this.closeList(htmlLines, inList, listType)
      inList = false
      htmlLines.push(`<p class="my-2 text-gray-700 dark:text-gray-300">${this.inlineFormatting(line)}</p>`)
    }

    this.closeList(htmlLines, inList, listType)
    if (inCodeBlock) htmlLines.push("</code></pre>")

    return htmlLines.join("\n")
  }

  closeList(htmlLines, inList, listType) {
    if (inList) {
      htmlLines.push(listType === "ol" ? "</ol>" : "</ul>")
    }
  }

  inlineFormatting(text) {
    let result = this.escapeHtml(text)
    // Bold
    result = result.replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
    result = result.replace(/__(.+?)__/g, "<strong>$1</strong>")
    // Italic
    result = result.replace(/\*(.+?)\*/g, "<em>$1</em>")
    result = result.replace(/\b_(.+?)_\b/g, "<em>$1</em>")
    // Inline code
    result = result.replace(/`(.+?)`/g, '<code class="bg-gray-100 dark:bg-gray-800 px-1.5 py-0.5 rounded text-sm font-mono text-red-600 dark:text-red-400">$1</code>')
    // Links
    result = result.replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2" class="text-blue-600 dark:text-blue-400 underline" target="_blank" rel="noopener">$1</a>')
    return result
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  clearResults() {
    this.outputTarget.innerHTML = '<p class="text-gray-400 text-center py-8">Start typing markdown to see the preview</p>'
    this.resultWordCountTarget.textContent = "\u2014"
    this.resultLineCountTarget.textContent = "\u2014"
    this.resultHeadingCountTarget.textContent = "\u2014"
  }

  copy() {
    const html = this.outputTarget.innerHTML
    if (html) {
      navigator.clipboard.writeText(html)
    }
  }

  copyText() {
    const text = this.outputTarget.innerText
    if (text) {
      navigator.clipboard.writeText(text)
    }
  }
}
