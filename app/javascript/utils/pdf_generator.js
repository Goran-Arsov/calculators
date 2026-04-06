// Minimal PDF generator using standard PDF fonts (no embedding required).
// Produces valid PDF 1.4 files that open in any PDF reader.

const FONTS = {
  "Helvetica":      { name: "Helvetica",      widthFactor: 0.52 },
  "Helvetica-Bold": { name: "Helvetica-Bold", widthFactor: 0.56 },
  "Courier":        { name: "Courier",        widthFactor: 0.6  }
}

export class PdfDocument {
  constructor(options = {}) {
    this.pageWidth = options.pageWidth || 595.28
    this.pageHeight = options.pageHeight || 841.89
    this.margin = options.margin || 50
    this.fontSize = options.fontSize || 11
    this.lineHeight = options.lineHeight || 1.4

    this.objects = []
    this.pages = []
    this.currentPage = null
    this.currentY = 0
    this.contentWidth = this.pageWidth - 2 * this.margin

    this._addNewPage()
  }

  // --- Public API ---

  addText(text, options = {}) {
    const font = options.font || "Helvetica"
    const size = options.fontSize || this.fontSize
    const leading = size * this.lineHeight
    const color = options.color || [0, 0, 0]

    const lines = this._wrapText(text, font, size)

    for (const line of lines) {
      if (this.currentY - leading < this.margin) this._addNewPage()
      this.currentY -= leading
      this.currentPage.content.push(
        `BT`,
        `/${this._fontKey(font)} ${size} Tf`,
        `${color[0]} ${color[1]} ${color[2]} rg`,
        `${this.margin} ${this.currentY} Td`,
        `(${this._escape(line)}) Tj`,
        `ET`
      )
    }
  }

  addHeading(text, level = 1) {
    const sizes = { 1: 22, 2: 18, 3: 15, 4: 13, 5: 12, 6: 11 }
    const size = sizes[level] || 14

    if (this.currentY < this.pageHeight - this.margin - 10) {
      this.currentY -= size * 0.5
    }

    this.addText(text, { font: "Helvetica-Bold", fontSize: size })
    this.currentY -= size * 0.3
  }

  addParagraph(text, options = {}) {
    this.addText(text, options)
    this.currentY -= this.fontSize * 0.4
  }

  addCodeBlock(text) {
    const lines = text.split("\n")
    const size = 9
    const leading = size * 1.3
    const blockHeight = lines.length * leading + 12
    const bgPad = 6

    if (this.currentY - blockHeight < this.margin) this._addNewPage()

    const bgTop = this.currentY - bgPad / 2 + leading * 0.3
    const bgBottom = bgTop - blockHeight
    this.currentPage.content.push(
      `0.94 0.94 0.94 rg`,
      `${this.margin - bgPad} ${bgBottom} ${this.contentWidth + bgPad * 2} ${blockHeight + bgPad} re f`,
      `0 0 0 rg`
    )

    for (const line of lines) {
      if (this.currentY - leading < this.margin) this._addNewPage()
      this.currentY -= leading
      this.currentPage.content.push(
        `BT`,
        `/F3 ${size} Tf`,
        `${this.margin} ${this.currentY} Td`,
        `(${this._escape(line)}) Tj`,
        `ET`
      )
    }
    this.currentY -= 8
  }

  addListItem(text, bullet = "\u2022") {
    const leading = this.fontSize * this.lineHeight
    if (this.currentY - leading < this.margin) this._addNewPage()

    const indent = 15
    this.currentY -= leading
    this.currentPage.content.push(
      `BT`,
      `/F1 ${this.fontSize} Tf`,
      `0 0 0 rg`,
      `${this.margin} ${this.currentY} Td`,
      `(${this._escape(bullet)}) Tj`,
      `ET`
    )

    const lines = this._wrapText(text, "Helvetica", this.fontSize, this.contentWidth - indent)
    const firstLine = lines.shift()
    if (firstLine) {
      this.currentPage.content.push(
        `BT`,
        `/F1 ${this.fontSize} Tf`,
        `${this.margin + indent} ${this.currentY} Td`,
        `(${this._escape(firstLine)}) Tj`,
        `ET`
      )
    }
    for (const line of lines) {
      this.currentY -= leading
      if (this.currentY < this.margin) this._addNewPage()
      this.currentPage.content.push(
        `BT`,
        `/F1 ${this.fontSize} Tf`,
        `${this.margin + indent} ${this.currentY} Td`,
        `(${this._escape(line)}) Tj`,
        `ET`
      )
    }
  }

  addTable(rows, options = {}) {
    if (rows.length === 0) return

    const hasHeader = options.hasHeader !== false
    const fontSize = options.fontSize || 9
    const cellPadding = 5
    const rowHeight = fontSize * 1.6 + cellPadding * 2
    const colCount = Math.max(...rows.map(r => r.length))
    const colWidth = this.contentWidth / colCount

    for (let r = 0; r < rows.length; r++) {
      if (this.currentY - rowHeight < this.margin) this._addNewPage()

      const isHeader = hasHeader && r === 0
      const y = this.currentY - rowHeight

      // Row background
      if (isHeader) {
        this.currentPage.content.push(`0.2 0.4 0.7 rg`, `${this.margin} ${y} ${this.contentWidth} ${rowHeight} re f`, `1 1 1 rg`)
      } else if (r % 2 === 0) {
        this.currentPage.content.push(`0.95 0.95 0.95 rg`, `${this.margin} ${y} ${this.contentWidth} ${rowHeight} re f`, `0 0 0 rg`)
      }

      // Cell borders
      this.currentPage.content.push(`0.8 0.8 0.8 RG`, `0.5 w`)
      this.currentPage.content.push(`${this.margin} ${y} ${this.contentWidth} ${rowHeight} re S`)

      // Cell text
      const row = rows[r] || []
      for (let c = 0; c < colCount; c++) {
        const x = this.margin + c * colWidth + cellPadding
        const textY = y + cellPadding + fontSize * 0.3
        const cellText = String(row[c] || "").substring(0, Math.floor(colWidth / (fontSize * 0.5)))
        const font = isHeader ? "F2" : "F1"
        const color = isHeader ? "1 1 1 rg" : "0 0 0 rg"

        // Vertical separator
        if (c > 0) {
          this.currentPage.content.push(
            `${this.margin + c * colWidth} ${y} m ${this.margin + c * colWidth} ${y + rowHeight} l S`
          )
        }

        this.currentPage.content.push(
          `BT`, `/${font} ${fontSize} Tf`, color,
          `${x} ${textY} Td`,
          `(${this._escape(cellText)}) Tj`,
          `ET`
        )
      }

      this.currentPage.content.push(`0 0 0 rg`, `0 0 0 RG`)
      this.currentY = y
    }
    this.currentY -= 10
  }

  addHorizontalRule() {
    this.currentY -= 10
    if (this.currentY < this.margin) this._addNewPage()
    this.currentPage.content.push(
      `0.7 0.7 0.7 RG`, `0.5 w`,
      `${this.margin} ${this.currentY} m ${this.margin + this.contentWidth} ${this.currentY} l S`,
      `0 0 0 RG`
    )
    this.currentY -= 10
  }

  addPageBreak() {
    this._addNewPage()
  }

  addSpacer(points = 10) {
    this.currentY -= points
    if (this.currentY < this.margin) this._addNewPage()
  }

  generate() {
    const objOffsets = []
    let body = ""
    let objNum = 1

    // Font objects
    const fontObjs = {}
    const fontNames = ["Helvetica", "Helvetica-Bold", "Courier"]
    const fontKeys = ["F1", "F2", "F3"]
    for (let i = 0; i < fontNames.length; i++) {
      objOffsets.push(body.length)
      body += `${objNum} 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /${fontNames[i]} /Encoding /WinAnsiEncoding >>\nendobj\n`
      fontObjs[fontKeys[i]] = objNum
      objNum++
    }

    // Pages and content streams
    const pageRefs = []
    for (const page of this.pages) {
      // Content stream
      const stream = page.content.join("\n")
      const streamBytes = new TextEncoder().encode(stream)
      objOffsets.push(body.length)
      const contentObjNum = objNum++
      body += `${contentObjNum} 0 obj\n<< /Length ${streamBytes.length} >>\nstream\n${stream}\nendstream\nendobj\n`

      // Page object
      objOffsets.push(body.length)
      const pageObjNum = objNum++
      pageRefs.push(pageObjNum)
      body += `${pageObjNum} 0 obj\n<< /Type /Page /Parent 0 0 R /MediaBox [0 0 ${this.pageWidth} ${this.pageHeight}] /Contents ${contentObjNum} 0 R /Resources << /Font << /F1 ${fontObjs.F1} 0 R /F2 ${fontObjs.F2} 0 R /F3 ${fontObjs.F3} 0 R >> >> >>\nendobj\n`
    }

    // Pages object
    objOffsets.push(body.length)
    const pagesObjNum = objNum++
    body += `${pagesObjNum} 0 obj\n<< /Type /Pages /Kids [${pageRefs.map(r => `${r} 0 R`).join(" ")}] /Count ${pageRefs.length} >>\nendobj\n`

    // Fix parent references
    for (const pr of pageRefs) {
      body = body.replace(new RegExp(`(${pr} 0 obj\\n<< /Type /Page /Parent )0 0 R`), `$1${pagesObjNum} 0 R`)
    }

    // Catalog
    objOffsets.push(body.length)
    const catalogObjNum = objNum++
    body += `${catalogObjNum} 0 obj\n<< /Type /Catalog /Pages ${pagesObjNum} 0 R >>\nendobj\n`

    // Build full PDF
    const header = "%PDF-1.4\n%\xE2\xE3\xCF\xD3\n"
    const fullBody = header + body
    const xrefOffset = fullBody.length

    let xref = `xref\n0 ${objNum}\n0000000000 65535 f \n`
    for (const off of objOffsets) {
      xref += `${String(off + header.length).padStart(10, "0")} 00000 n \n`
    }

    const trailer = `trailer\n<< /Size ${objNum} /Root ${catalogObjNum} 0 R >>\nstartxref\n${xrefOffset}\n%%EOF`

    const pdfString = fullBody + xref + trailer
    const encoder = new TextEncoder()
    return encoder.encode(pdfString).buffer
  }

  // --- Private ---

  _addNewPage() {
    this.currentPage = { content: [] }
    this.pages.push(this.currentPage)
    this.currentY = this.pageHeight - this.margin
  }

  _fontKey(fontName) {
    if (fontName === "Helvetica-Bold") return "F2"
    if (fontName === "Courier") return "F3"
    return "F1"
  }

  _wrapText(text, font, fontSize, maxWidth) {
    maxWidth = maxWidth || this.contentWidth
    const charWidth = (FONTS[font] || FONTS["Helvetica"]).widthFactor * fontSize
    const maxChars = Math.floor(maxWidth / charWidth)
    const lines = []

    for (const paragraph of text.split("\n")) {
      if (paragraph === "") {
        lines.push("")
        continue
      }
      const words = paragraph.split(/\s+/)
      let currentLine = ""

      for (const word of words) {
        const testLine = currentLine ? currentLine + " " + word : word
        if (testLine.length > maxChars && currentLine) {
          lines.push(currentLine)
          currentLine = word
        } else {
          currentLine = testLine
        }
      }
      if (currentLine) lines.push(currentLine)
    }

    return lines
  }

  _escape(text) {
    return text
      .replace(/\\/g, "\\\\")
      .replace(/\(/g, "\\(")
      .replace(/\)/g, "\\)")
  }
}
