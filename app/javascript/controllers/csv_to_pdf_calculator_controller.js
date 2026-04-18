import { Controller } from "@hotwired/stimulus"
import { downloadHtmlAsPdf } from "utils/html_to_pdf"

export default class extends Controller {
  static targets = [
    "csvInput", "fileInput", "delimiter", "headerCheckbox",
    "preview", "previewTable",
    "resultRows", "resultCols",
    "downloadBtn"
  ]

  connect() {
    this.rows = []
  }

  loadFile() {
    const file = this.fileInputTarget.files[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = (e) => {
      this.csvInputTarget.value = e.target.result
      this.parse()
    }
    reader.readAsText(file)
  }

  parse() {
    const csv = this.csvInputTarget.value.trim()
    if (!csv) {
      this.rows = []
      this.clearPreview()
      return
    }

    const delim = this.delimiterTarget.value
    this.rows = this.parseCsv(csv, delim)
    this.renderPreview()
  }

  parseCsv(text, delimiter) {
    const rows = []
    let current = []
    let field = ""
    let inQuotes = false

    for (let i = 0; i < text.length; i++) {
      const ch = text[i]
      const next = text[i + 1]

      if (inQuotes) {
        if (ch === '"' && next === '"') {
          field += '"'
          i++
        } else if (ch === '"') {
          inQuotes = false
        } else {
          field += ch
        }
      } else {
        if (ch === '"') {
          inQuotes = true
        } else if (ch === delimiter) {
          current.push(field)
          field = ""
        } else if (ch === "\r" && next === "\n") {
          current.push(field)
          field = ""
          rows.push(current)
          current = []
          i++
        } else if (ch === "\n") {
          current.push(field)
          field = ""
          rows.push(current)
          current = []
        } else {
          field += ch
        }
      }
    }

    current.push(field)
    if (current.some(c => c !== "")) rows.push(current)

    return rows
  }

  renderPreview() {
    if (this.rows.length === 0) {
      this.clearPreview()
      return
    }

    const hasHeader = this.headerCheckboxTarget.checked
    const maxCols = Math.max(...this.rows.map(r => r.length))
    const maxPreviewRows = Math.min(this.rows.length, 20)

    let html = '<table class="min-w-full text-sm border-collapse">'

    if (hasHeader && this.rows.length > 0) {
      html += '<thead><tr>'
      for (let c = 0; c < maxCols; c++) {
        const val = (this.rows[0] && this.rows[0][c]) || ""
        html += `<th class="border border-gray-300 dark:border-gray-600 px-2 py-1 bg-gray-100 dark:bg-gray-700 text-left font-medium">${this.escapeHtml(val)}</th>`
      }
      html += '</tr></thead><tbody>'
      for (let r = 1; r < maxPreviewRows; r++) {
        html += `<tr class="${r % 2 === 0 ? 'bg-gray-50 dark:bg-gray-800/50' : ''}">`
        for (let c = 0; c < maxCols; c++) {
          const val = (this.rows[r] && this.rows[r][c]) || ""
          html += `<td class="border border-gray-200 dark:border-gray-700 px-2 py-1 truncate max-w-[200px]">${this.escapeHtml(val)}</td>`
        }
        html += '</tr>'
      }
    } else {
      html += '<thead><tr>'
      for (let c = 0; c < maxCols; c++) {
        html += `<th class="border border-gray-300 dark:border-gray-600 px-2 py-1 bg-gray-100 dark:bg-gray-700 text-left font-medium">${this.colLetter(c)}</th>`
      }
      html += '</tr></thead><tbody>'
      for (let r = 0; r < maxPreviewRows; r++) {
        html += `<tr class="${r % 2 === 1 ? 'bg-gray-50 dark:bg-gray-800/50' : ''}">`
        for (let c = 0; c < maxCols; c++) {
          const val = (this.rows[r] && this.rows[r][c]) || ""
          html += `<td class="border border-gray-200 dark:border-gray-700 px-2 py-1 truncate max-w-[200px]">${this.escapeHtml(val)}</td>`
        }
        html += '</tr>'
      }
    }

    if (this.rows.length > 20) {
      html += `<tr><td colspan="${maxCols}" class="border border-gray-200 dark:border-gray-700 px-2 py-1 text-center text-gray-500 italic">... and ${this.rows.length - 20} more rows</td></tr>`
    }

    html += '</tbody></table>'
    this.previewTableTarget.innerHTML = html
    this.previewTarget.classList.remove("hidden")

    this.resultRowsTarget.textContent = this.rows.length
    this.resultColsTarget.textContent = maxCols
    this.downloadBtnTarget.disabled = false
  }

  clearPreview() {
    this.previewTableTarget.innerHTML = '<p class="text-gray-400 text-sm">Paste CSV or upload a file to see preview</p>'
    this.resultRowsTarget.textContent = "--"
    this.resultColsTarget.textContent = "--"
    this.downloadBtnTarget.disabled = true
  }

  async download() {
    if (this.rows.length === 0) return

    const btn = this.downloadBtnTarget
    btn.disabled = true
    btn.style.opacity = "0.7"

    try {
      const hasHeader = this.headerCheckboxTarget.checked
      const maxCols = Math.max(...this.rows.map(r => r.length))

      let html = '<h1>Data Export</h1>'
      html += '<table>'

      const bodyStart = hasHeader ? 1 : 0
      if (hasHeader && this.rows[0]) {
        html += '<thead><tr>'
        for (let c = 0; c < maxCols; c++) {
          html += `<th>${this.escapeHtml(this.rows[0][c] || "")}</th>`
        }
        html += '</tr></thead>'
      }
      html += '<tbody>'
      for (let r = bodyStart; r < this.rows.length; r++) {
        html += '<tr>'
        for (let c = 0; c < maxCols; c++) {
          html += `<td>${this.escapeHtml(this.rows[r][c] || "")}</td>`
        }
        html += '</tr>'
      }
      html += '</tbody></table>'

      await downloadHtmlAsPdf(html, { filename: "data-export.pdf" })
    } catch (err) {
      console.error("[csv-to-pdf] PDF generation failed", err)
    } finally {
      btn.disabled = false
      btn.style.opacity = ""
    }
  }

  colLetter(idx) {
    let s = ""
    idx++
    while (idx > 0) {
      idx--
      s = String.fromCharCode(65 + (idx % 26)) + s
      idx = Math.floor(idx / 26)
    }
    return s
  }

  escapeHtml(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }
}
