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

      // Find content.xml (ODT main content file)
      const contentEntry = entries.find(e => e.name === "content.xml")
      if (!contentEntry) {
        this.showError("Could not find content.xml in the ODT file")
        return
      }

      const xml = new TextDecoder().decode(contentEntry.data)
      const doc = new DOMParser().parseFromString(xml, "text/xml")

      this.paragraphs = this.extractParagraphs(doc)
      this.updateStats()
      this.renderPreview()
      this.downloadBtnTarget.disabled = false

    } catch (err) {
      this.showError("Failed to parse ODT file: " + err.message)
    }
  }

  extractParagraphs(doc) {
    const paragraphs = []
    const ns = "urn:oasis:names:tc:opendocument:xmlns:text:1.0"

    // Get the body element -- text content lives under office:body > office:text
    const bodyNodes = doc.getElementsByTagNameNS("urn:oasis:names:tc:opendocument:xmlns:office:1.0", "text")
    if (bodyNodes.length === 0) {
      // Fallback: try to find text:p and text:h anywhere
      return this.extractFromRoot(doc, ns)
    }

    const body = bodyNodes[0]
    return this.extractFromNode(body, ns)
  }

  extractFromRoot(doc, ns) {
    const paragraphs = []

    // Extract headings
    const headings = doc.getElementsByTagNameNS(ns, "h")
    for (let i = 0; i < headings.length; i++) {
      const h = headings[i]
      const level = parseInt(h.getAttributeNS(ns, "outline-level") || h.getAttribute("text:outline-level") || "1")
      const text = this.getTextContent(h)
      if (text.length > 0) {
        paragraphs.push({ text, style: "heading", headingLevel: level })
      }
    }

    // Extract paragraphs
    const pNodes = doc.getElementsByTagNameNS(ns, "p")
    for (let i = 0; i < pNodes.length; i++) {
      const text = this.getTextContent(pNodes[i])
      if (text.length > 0) {
        paragraphs.push({ text, style: "normal", headingLevel: 0 })
      }
    }

    return paragraphs
  }

  extractFromNode(body, ns) {
    const paragraphs = []
    const children = body.childNodes

    for (let i = 0; i < children.length; i++) {
      const node = children[i]
      if (node.nodeType !== 1) continue // Skip non-element nodes

      const localName = node.localName
      const nodeNs = node.namespaceURI

      if (nodeNs === ns && localName === "h") {
        const level = parseInt(node.getAttributeNS(ns, "outline-level") || node.getAttribute("text:outline-level") || "1")
        const text = this.getTextContent(node)
        if (text.length > 0) {
          paragraphs.push({ text, style: "heading", headingLevel: level })
        }
      } else if (nodeNs === ns && localName === "p") {
        const text = this.getTextContent(node)
        if (text.length > 0) {
          paragraphs.push({ text, style: "normal", headingLevel: 0 })
        }
      } else if (nodeNs === ns && localName === "list") {
        this.extractListItems(node, ns, paragraphs)
      } else if (nodeNs === ns && localName === "section") {
        // Recurse into sections
        const sectionParas = this.extractFromNode(node, ns)
        paragraphs.push(...sectionParas)
      }
    }

    return paragraphs
  }

  extractListItems(listNode, ns, paragraphs) {
    const items = listNode.getElementsByTagNameNS(ns, "list-item")
    for (let i = 0; i < items.length; i++) {
      const pNodes = items[i].getElementsByTagNameNS(ns, "p")
      for (let j = 0; j < pNodes.length; j++) {
        const text = this.getTextContent(pNodes[j])
        if (text.length > 0) {
          paragraphs.push({ text: "\u2022 " + text, style: "normal", headingLevel: 0 })
        }
      }
    }
  }

  getTextContent(node) {
    let text = ""
    for (let i = 0; i < node.childNodes.length; i++) {
      const child = node.childNodes[i]
      if (child.nodeType === 3) {
        text += child.textContent
      } else if (child.nodeType === 1) {
        text += this.getTextContent(child)
      }
    }
    return text
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
        // DEFLATE -- use DecompressionStream
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
