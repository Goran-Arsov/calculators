import { Controller } from "@hotwired/stimulus"
import { PdfDocument } from "utils/pdf_generator"

export default class extends Controller {
  static targets = [
    "fileInput",
    "preview", "previewContent",
    "resultParagraphs", "resultWords",
    "downloadBtn"
  ]

  connect() {
    this.paragraphs = []
  }

  async loadFile() {
    const file = this.fileInputTarget.files[0]
    if (!file) return

    try {
      const buffer = await file.arrayBuffer()
      const entries = await this.readZip(new Uint8Array(buffer))

      // Find word/document.xml
      const docEntry = entries.find(e => e.name === "word/document.xml")
      if (!docEntry) {
        this.showError("Could not find document.xml in the DOCX file")
        return
      }

      const xml = new TextDecoder().decode(docEntry.data)
      const doc = new DOMParser().parseFromString(xml, "text/xml")

      // Extract paragraphs from w:body
      const body = doc.getElementsByTagName("w:body")[0]
      if (!body) {
        this.showError("Could not find document body in the DOCX file")
        return
      }

      this.paragraphs = []
      const pNodes = body.getElementsByTagName("w:p")

      for (let i = 0; i < pNodes.length; i++) {
        const pNode = pNodes[i]

        // Check paragraph style for headings
        let style = "normal"
        let headingLevel = 0
        const pPr = pNode.getElementsByTagName("w:pPr")[0]
        if (pPr) {
          const pStyle = pPr.getElementsByTagName("w:pStyle")[0]
          if (pStyle) {
            const val = pStyle.getAttribute("w:val") || ""
            const headingMatch = val.match(/^Heading(\d)$/i)
            if (headingMatch) {
              style = "heading"
              headingLevel = parseInt(headingMatch[1]) || 1
            }
          }
        }

        // Extract runs
        const runs = pNode.getElementsByTagName("w:r")
        let fullText = ""
        let hasBold = false

        for (let j = 0; j < runs.length; j++) {
          const run = runs[j]

          // Check run properties for bold
          const rPr = run.getElementsByTagName("w:rPr")[0]
          if (rPr) {
            const boldNode = rPr.getElementsByTagName("w:b")[0]
            if (boldNode) {
              // w:b with no val attribute or val="true"/"1" means bold
              const bVal = boldNode.getAttribute("w:val")
              if (bVal === null || bVal === "true" || bVal === "1") {
                hasBold = true
              }
            }
          }

          // Get text from w:t nodes
          const tNodes = run.getElementsByTagName("w:t")
          for (let k = 0; k < tNodes.length; k++) {
            fullText += tNodes[k].textContent || ""
          }
        }

        if (fullText.length > 0 || style === "heading") {
          this.paragraphs.push({
            text: fullText,
            style: style,
            headingLevel: headingLevel,
            bold: hasBold
          })
        }
      }

      this.updateStats()
      this.renderPreview()
      this.downloadBtnTarget.disabled = false

    } catch (err) {
      this.showError("Failed to parse DOCX file: " + err.message)
    }
  }

  updateStats() {
    this.resultParagraphsTarget.textContent = this.paragraphs.length
    const wordCount = this.paragraphs.reduce((sum, p) => {
      return sum + p.text.split(/\s+/).filter(w => w.length > 0).length
    }, 0)
    this.resultWordsTarget.textContent = wordCount
  }

  renderPreview() {
    let html = ""
    const maxPreview = Math.min(this.paragraphs.length, 50)

    for (let i = 0; i < maxPreview; i++) {
      const p = this.paragraphs[i]
      const escaped = this.escapeHtml(p.text)

      if (p.style === "heading") {
        const tag = `h${Math.min(p.headingLevel, 6)}`
        html += `<${tag} class="font-bold text-gray-900 dark:text-white mt-3 mb-1">${escaped}</${tag}>`
      } else if (p.bold) {
        html += `<p class="font-bold mb-1">${escaped}</p>`
      } else {
        html += `<p class="mb-1">${escaped}</p>`
      }
    }

    if (this.paragraphs.length > 50) {
      html += `<p class="text-gray-500 italic mt-2">... and ${this.paragraphs.length - 50} more paragraphs</p>`
    }

    this.previewContentTarget.innerHTML = html
    this.previewTarget.classList.remove("hidden")
  }

  download() {
    if (this.paragraphs.length === 0) return

    const pdf = new PdfDocument()

    for (const p of this.paragraphs) {
      if (p.style === "heading") {
        pdf.addHeading(p.text, p.headingLevel || 1)
      } else if (p.bold) {
        pdf.addText(p.text, { font: "Helvetica-Bold", fontSize: 11 })
        pdf.addSpacer(4)
      } else {
        pdf.addParagraph(p.text)
      }
    }

    const buffer = pdf.generate()
    const blob = new Blob([buffer], { type: "application/pdf" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "document.pdf"
    a.click()
    URL.revokeObjectURL(url)
  }

  // --- ZIP reading (same approach as excel_to_csv_calculator_controller) ---

  async readZip(data) {
    const entries = []
    const view = new DataView(data.buffer, data.byteOffset, data.byteLength)

    // Find end of central directory
    let eocdOffset = -1
    for (let i = data.length - 22; i >= 0; i--) {
      if (view.getUint32(i, true) === 0x06054b50) {
        eocdOffset = i
        break
      }
    }

    if (eocdOffset === -1) throw new Error("Invalid ZIP file")

    const cdOffset = view.getUint32(eocdOffset + 16, true)
    const cdCount = view.getUint16(eocdOffset + 10, true)

    let pos = cdOffset
    for (let i = 0; i < cdCount; i++) {
      if (view.getUint32(pos, true) !== 0x02014b50) break

      const compression = view.getUint16(pos + 10, true)
      const compressedSize = view.getUint32(pos + 20, true)
      const uncompressedSize = view.getUint32(pos + 24, true)
      const nameLen = view.getUint16(pos + 28, true)
      const extraLen = view.getUint16(pos + 30, true)
      const commentLen = view.getUint16(pos + 32, true)
      const localOffset = view.getUint32(pos + 42, true)
      const name = new TextDecoder().decode(data.subarray(pos + 46, pos + 46 + nameLen))

      // Read local file header to get actual data offset
      const localNameLen = view.getUint16(localOffset + 26, true)
      const localExtraLen = view.getUint16(localOffset + 28, true)
      const dataStart = localOffset + 30 + localNameLen + localExtraLen
      const rawData = data.subarray(dataStart, dataStart + compressedSize)

      let fileData
      if (compression === 0) {
        fileData = rawData
      } else if (compression === 8) {
        // DEFLATE — use DecompressionStream
        fileData = await this.inflate(rawData)
      } else {
        pos += 46 + nameLen + extraLen + commentLen
        continue
      }

      entries.push({ name, data: fileData })
      pos += 46 + nameLen + extraLen + commentLen
    }

    return entries
  }

  async inflate(data) {
    const ds = new DecompressionStream("deflate-raw")
    const writer = ds.writable.getWriter()
    const reader = ds.readable.getReader()

    writer.write(data)
    writer.close()

    const chunks = []
    let totalLen = 0
    while (true) {
      const { done, value } = await reader.read()
      if (done) break
      chunks.push(value)
      totalLen += value.length
    }

    const result = new Uint8Array(totalLen)
    let offset = 0
    for (const chunk of chunks) {
      result.set(chunk, offset)
      offset += chunk.length
    }
    return result
  }

  showError(msg) {
    this.previewContentTarget.innerHTML = `<p class="text-red-500 text-sm">${this.escapeHtml(msg)}</p>`
    this.previewTarget.classList.remove("hidden")
  }

  escapeHtml(str) {
    return String(str).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }
}
