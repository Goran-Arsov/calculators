import { Controller } from "@hotwired/stimulus"
import { PdfDocument } from "utils/pdf_generator"

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

  download() {
    const text = this.textInputTarget.value
    if (!text.trim()) return

    const fontSize = parseInt(this.fontSizeTarget.value, 10) || 11
    const pageSize = this.pageSizeTarget.value

    const options = { fontSize }
    if (pageSize === "letter") {
      options.pageWidth = 612
      options.pageHeight = 792
    }

    const pdf = new PdfDocument(options)

    const paragraphs = text.split(/\n\n+/)
    paragraphs.forEach((para, i) => {
      if (i > 0) pdf.addSpacer(6)
      const lines = para.split("\n")
      lines.forEach(line => {
        if (line.trim() === "") {
          pdf.addSpacer(fontSize * 0.5)
        } else {
          pdf.addParagraph(line)
        }
      })
    })

    const buffer = pdf.generate()
    const blob = new Blob([buffer], { type: "application/pdf" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "document.pdf"
    a.click()
    URL.revokeObjectURL(url)
  }
}
