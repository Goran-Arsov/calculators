import { Controller } from "@hotwired/stimulus"

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

      // Find word/document.xml (DOCX main content file)
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

    const odt = this.generateOdt(this.paragraphs)
    const blob = new Blob([odt], { type: "application/vnd.oasis.opendocument.text" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "document.odt"
    a.click()
    URL.revokeObjectURL(url)
  }

  generateOdt(paragraphs) {
    const files = {}

    // mimetype must be the first entry and uncompressed
    files["mimetype"] = "application/vnd.oasis.opendocument.text"

    files["META-INF/manifest.xml"] = '<?xml version="1.0" encoding="UTF-8"?>\n<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.2"><manifest:file-entry manifest:media-type="application/vnd.oasis.opendocument.text" manifest:full-path="/"/><manifest:file-entry manifest:media-type="text/xml" manifest:full-path="content.xml"/><manifest:file-entry manifest:media-type="text/xml" manifest:full-path="styles.xml"/></manifest:manifest>'

    files["styles.xml"] = '<?xml version="1.0" encoding="UTF-8"?>\n<office:document-styles xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" office:version="1.2"><office:styles><style:style style:name="Standard" style:family="paragraph"><style:text-properties fo:font-size="12pt"/></style:style><style:style style:name="Heading1" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="24pt" fo:font-weight="bold"/></style:style><style:style style:name="Heading2" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="18pt" fo:font-weight="bold"/></style:style><style:style style:name="Heading3" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="14pt" fo:font-weight="bold"/></style:style><style:style style:name="Heading4" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="12pt" fo:font-weight="bold"/></style:style><style:style style:name="Heading5" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="11pt" fo:font-weight="bold"/></style:style><style:style style:name="Heading6" style:family="paragraph" style:parent-style-name="Standard"><style:text-properties fo:font-size="10pt" fo:font-weight="bold"/></style:style><style:style style:name="Bold" style:family="text"><style:text-properties fo:font-weight="bold"/></style:style></office:styles></office:document-styles>'

    // Build content.xml
    let contentXml = '<?xml version="1.0" encoding="UTF-8"?>\n<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" office:version="1.2">'
    contentXml += '<office:automatic-styles>'
    contentXml += '<style:style style:name="Heading1" style:family="paragraph"><style:text-properties fo:font-size="24pt" fo:font-weight="bold"/></style:style>'
    contentXml += '<style:style style:name="Heading2" style:family="paragraph"><style:text-properties fo:font-size="18pt" fo:font-weight="bold"/></style:style>'
    contentXml += '<style:style style:name="Heading3" style:family="paragraph"><style:text-properties fo:font-size="14pt" fo:font-weight="bold"/></style:style>'
    contentXml += '<style:style style:name="Heading4" style:family="paragraph"><style:text-properties fo:font-size="12pt" fo:font-weight="bold"/></style:style>'
    contentXml += '<style:style style:name="Heading5" style:family="paragraph"><style:text-properties fo:font-size="11pt" fo:font-weight="bold"/></style:style>'
    contentXml += '<style:style style:name="Heading6" style:family="paragraph"><style:text-properties fo:font-size="10pt" fo:font-weight="bold"/></style:style>'
    contentXml += '<style:style style:name="BoldText" style:family="text"><style:text-properties fo:font-weight="bold"/></style:style>'
    contentXml += '</office:automatic-styles>'
    contentXml += '<office:body><office:text>'

    for (const p of paragraphs) {
      if (p.style === "heading" && p.headingLevel >= 1 && p.headingLevel <= 6) {
        contentXml += `<text:h text:style-name="Heading${p.headingLevel}" text:outline-level="${p.headingLevel}">${this.escapeXml(p.text)}</text:h>`
      } else if (p.bold) {
        contentXml += `<text:p text:style-name="Standard"><text:span text:style-name="BoldText">${this.escapeXml(p.text)}</text:span></text:p>`
      } else {
        contentXml += `<text:p text:style-name="Standard">${this.escapeXml(p.text)}</text:p>`
      }
    }

    contentXml += '</office:text></office:body></office:document-content>'
    files["content.xml"] = contentXml

    return this.createZipStore(files)
  }

  // --- ZIP creation (same approach as csv_to_excel_calculator_controller) ---

  createZipStore(files) {
    const entries = []
    const encoder = new TextEncoder()

    for (const [name, content] of Object.entries(files)) {
      const data = encoder.encode(content)
      const nameBytes = encoder.encode(name)
      entries.push({ name: nameBytes, data })
    }

    // Calculate total size
    let totalSize = 0
    for (const e of entries) {
      totalSize += 30 + e.name.length + e.data.length // local header + data
      totalSize += 46 + e.name.length                  // central dir entry
    }
    totalSize += 22 // end of central dir

    const buf = new ArrayBuffer(totalSize)
    const view = new DataView(buf)
    const uint8 = new Uint8Array(buf)
    let offset = 0
    const centralEntries = []

    // Write local file headers and data
    for (const e of entries) {
      centralEntries.push({ offset, name: e.name, size: e.data.length })

      // Local file header
      view.setUint32(offset, 0x04034b50, true); offset += 4
      view.setUint16(offset, 20, true); offset += 2      // version needed
      view.setUint16(offset, 0, true); offset += 2       // flags
      view.setUint16(offset, 0, true); offset += 2       // compression (STORE)
      view.setUint16(offset, 0, true); offset += 2       // mod time
      view.setUint16(offset, 0, true); offset += 2       // mod date
      view.setUint32(offset, this.crc32(e.data), true); offset += 4
      view.setUint32(offset, e.data.length, true); offset += 4  // compressed
      view.setUint32(offset, e.data.length, true); offset += 4  // uncompressed
      view.setUint16(offset, e.name.length, true); offset += 2
      view.setUint16(offset, 0, true); offset += 2       // extra field len

      uint8.set(e.name, offset); offset += e.name.length
      uint8.set(e.data, offset); offset += e.data.length
    }

    // Write central directory
    const centralStart = offset
    for (const ce of centralEntries) {
      view.setUint32(offset, 0x02014b50, true); offset += 4
      view.setUint16(offset, 20, true); offset += 2      // version made by
      view.setUint16(offset, 20, true); offset += 2      // version needed
      view.setUint16(offset, 0, true); offset += 2       // flags
      view.setUint16(offset, 0, true); offset += 2       // compression
      view.setUint16(offset, 0, true); offset += 2       // mod time
      view.setUint16(offset, 0, true); offset += 2       // mod date
      view.setUint32(offset, this.crc32(ce.name.length === 0 ? new Uint8Array(0) : uint8.slice(ce.offset + 30 + ce.name.length, ce.offset + 30 + ce.name.length + ce.size)), true); offset += 4
      view.setUint32(offset, ce.size, true); offset += 4
      view.setUint32(offset, ce.size, true); offset += 4
      view.setUint16(offset, ce.name.length, true); offset += 2
      view.setUint16(offset, 0, true); offset += 2       // extra field len
      view.setUint16(offset, 0, true); offset += 2       // comment len
      view.setUint16(offset, 0, true); offset += 2       // disk number
      view.setUint16(offset, 0, true); offset += 2       // internal attrs
      view.setUint32(offset, 0, true); offset += 4       // external attrs
      view.setUint32(offset, ce.offset, true); offset += 4
      uint8.set(ce.name, offset); offset += ce.name.length
    }

    const centralSize = offset - centralStart

    // End of central directory
    view.setUint32(offset, 0x06054b50, true); offset += 4
    view.setUint16(offset, 0, true); offset += 2          // disk number
    view.setUint16(offset, 0, true); offset += 2          // central dir disk
    view.setUint16(offset, centralEntries.length, true); offset += 2
    view.setUint16(offset, centralEntries.length, true); offset += 2
    view.setUint32(offset, centralSize, true); offset += 4
    view.setUint32(offset, centralStart, true); offset += 4
    view.setUint16(offset, 0, true); offset += 2          // comment len

    return buf
  }

  crc32(data) {
    if (!this._crcTable) {
      this._crcTable = new Uint32Array(256)
      for (let i = 0; i < 256; i++) {
        let c = i
        for (let j = 0; j < 8; j++) {
          c = (c & 1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1)
        }
        this._crcTable[i] = c
      }
    }
    let crc = 0xFFFFFFFF
    for (let i = 0; i < data.length; i++) {
      crc = this._crcTable[(crc ^ data[i]) & 0xFF] ^ (crc >>> 8)
    }
    return (crc ^ 0xFFFFFFFF) >>> 0
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

  escapeXml(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&apos;")
  }

  escapeHtml(str) {
    return String(str).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }
}
