import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "csvInput", "fileInput", "delimiter",
    "preview", "previewTable",
    "resultRows", "resultCols", "resultCells",
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

    const maxCols = Math.max(...this.rows.map(r => r.length))
    const maxPreviewRows = Math.min(this.rows.length, 20)

    let html = '<table class="min-w-full text-sm border-collapse">'
    html += '<thead><tr>'
    for (let c = 0; c < maxCols; c++) {
      html += `<th class="border border-gray-300 dark:border-gray-600 px-2 py-1 bg-gray-100 dark:bg-gray-700 text-left font-medium">${this.colLetter(c)}</th>`
    }
    html += '</tr></thead><tbody>'

    for (let r = 0; r < maxPreviewRows; r++) {
      html += '<tr>'
      for (let c = 0; c < maxCols; c++) {
        const val = (this.rows[r] && this.rows[r][c]) || ""
        html += `<td class="border border-gray-200 dark:border-gray-700 px-2 py-1 truncate max-w-[200px]">${this.escapeHtml(val)}</td>`
      }
      html += '</tr>'
    }

    if (this.rows.length > 20) {
      html += `<tr><td colspan="${maxCols}" class="border border-gray-200 dark:border-gray-700 px-2 py-1 text-center text-gray-500 italic">... and ${this.rows.length - 20} more rows</td></tr>`
    }

    html += '</tbody></table>'
    this.previewTableTarget.innerHTML = html
    this.previewTarget.classList.remove("hidden")

    this.resultRowsTarget.textContent = this.rows.length
    this.resultColsTarget.textContent = maxCols
    this.resultCellsTarget.textContent = this.rows.reduce((sum, r) => sum + r.length, 0)
    this.downloadBtnTarget.disabled = false
  }

  clearPreview() {
    this.previewTableTarget.innerHTML = '<p class="text-gray-400 text-sm">Paste CSV or upload a file to see preview</p>'
    this.resultRowsTarget.textContent = "--"
    this.resultColsTarget.textContent = "--"
    this.resultCellsTarget.textContent = "--"
    this.downloadBtnTarget.disabled = true
  }

  download() {
    if (this.rows.length === 0) return

    const xlsx = this.generateXlsx(this.rows)
    const blob = new Blob([xlsx], { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "export.xlsx"
    a.click()
    URL.revokeObjectURL(url)
  }

  generateXlsx(rows) {
    const files = {}

    files["[Content_Types].xml"] = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>'

    files["_rels/.rels"] = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>'

    files["xl/workbook.xml"] = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Sheet1" sheetId="1" r:id="rId1"/></sheets></workbook>'

    files["xl/_rels/workbook.xml.rels"] = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/></Relationships>'

    // Build worksheet XML
    let sheet = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>'

    for (let r = 0; r < rows.length; r++) {
      sheet += `<row r="${r + 1}">`
      for (let c = 0; c < rows[r].length; c++) {
        const ref = this.colLetter(c) + (r + 1)
        const val = rows[r][c]
        const num = Number(val)
        if (val !== "" && !isNaN(num) && isFinite(num)) {
          sheet += `<c r="${ref}"><v>${num}</v></c>`
        } else {
          sheet += `<c r="${ref}" t="inlineStr"><is><t>${this.escapeXml(val)}</t></is></c>`
        }
      }
      sheet += '</row>'
    }

    sheet += '</sheetData></worksheet>'
    files["xl/worksheets/sheet1.xml"] = sheet

    return this.createZipStore(files)
  }

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

  escapeXml(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&apos;")
  }

  escapeHtml(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }
}
