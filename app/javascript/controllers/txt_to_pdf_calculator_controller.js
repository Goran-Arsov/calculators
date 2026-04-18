import { Controller } from "@hotwired/stimulus"
import { downloadHtmlAsPdf, escapeHtml } from "utils/html_to_pdf"

export default class extends Controller {
  static targets = [
    "textInput", "fileInput", "fontSize", "fontSizeValue", "pageSize",
    "resultLines", "resultWords", "resultChars",
    "downloadBtn"
  ]

  connect() {
    this.text = ""
  }

  loadFile() {
    const file = this.fileInputTarget.files[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = (e) => {
      this.textInputTarget.value = e.target.result
      this.updateStats()
    }
    reader.readAsText(file)
  }

  updateStats() {
    this.text = this.textInputTarget.value
    if (!this.text.trim()) {
      this.resultLinesTarget.textContent = "--"
      this.resultWordsTarget.textContent = "--"
      this.resultCharsTarget.textContent = "--"
      this.downloadBtnTarget.disabled = true
      return
    }

    const lines = this.text.split("\n")
    const words = this.text.split(/\s+/).filter(w => w.length > 0)

    this.resultLinesTarget.textContent = lines.length
    this.resultWordsTarget.textContent = words.length
    this.resultCharsTarget.textContent = this.text.length
    this.downloadBtnTarget.disabled = false
  }

  updateFontSize() {
    this.fontSizeValueTarget.textContent = this.fontSizeTarget.value + "pt"
  }

  async download() {
    const text = this.textInputTarget.value
    if (!text.trim()) return

    const btn = this.downloadBtnTarget
    btn.disabled = true
    btn.style.opacity = "0.7"

    try {
      const fontSize = parseInt(this.fontSizeTarget.value, 10) || 11
      const pageFormat = this.pageSizeTarget.value === "letter" ? "letter" : "a4"

      const paragraphs = text.split(/\n\n+/).map((para, i, arr) => {
        const isLast = i === arr.length - 1
        const mb = isLast ? 0 : fontSize * 0.5
        return `<p style="margin:0 0 ${mb}pt;white-space:pre-wrap;">${escapeHtml(para)}</p>`
      }).join("")

      await downloadHtmlAsPdf(paragraphs, { filename: "document.pdf", fontSize, pageFormat })
    } catch (err) {
      console.error("[txt-to-pdf] PDF generation failed", err)
    } finally {
      btn.disabled = false
      btn.style.opacity = ""
    }
  }
}
