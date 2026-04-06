import { Controller } from "@hotwired/stimulus"
import { PdfDocument } from "utils/pdf_generator"

export default class extends Controller {
  static targets = [
    "fileInput", "headerCheckbox",
    "preview", "previewTable",
    "resultRows", "resultCols", "resultSheetName",
    "downloadBtn"
  ]

  connect() {
    this.rows = []
    this.sheetName = "Sheet1"
  }

  async loadFile() {
    const file = this.fileInputTarget.files[0]
    if (!file) return

    try {
      const buffer = await file.arrayBuffer()
      const entries = await this.readZip(new Uint8Array(buffer))

      // Find shared strings
      const sharedStrings = []
      const ssEntry = entries.find(e => e.name === "xl/sharedStrings.xml")
      if (ssEntry) {
        const xml = new TextDecoder().decode(ssEntry.data)
        const doc = new DOMParser().parseFromString(xml, "text/xml")
        const items = doc.getElementsByTagName("si")
        for (let i = 0; i < items.length; i++) {
          const tNodes = items[i].getElementsByTagName("t")
          let text = ""
          for (let j = 0; j < tNodes.length; j++) {
            text += tNodes[j].textContent || ""
          }
          sharedStrings.push(text)
        }
      }

      // Find first worksheet name
      this.sheetName = "Sheet1"
      const wbEntry = entries.find(e => e.name === "xl/workbook.xml")
      if (wbEntry) {
        const xml = new TextDecoder().decode(wbEntry.data)
        const doc = new DOMParser().parseFromString(xml, "text/xml")
        const sheets = doc.getElementsByTagName("sheet")
        if (sheets.length > 0) {
          this.sheetName = sheets[0].getAttribute("name") || "Sheet1"
        }
      }

      const sheetEntry = entries.find(e => e.name === "xl/worksheets/sheet1.xml")
      if (!sheetEntry) {
        this.showError("Could not find worksheet in the Excel file")
        return
      }

      const sheetXml = new TextDecoder().decode(sheetEntry.data)
      const sheetDoc = new DOMParser().parseFromString(sheetXml, "text/xml")
      const xmlRows = sheetDoc.getElementsByTagName("row")

      this.rows = []
      let maxCol = 0

      for (let i = 0; i < xmlRows.length; i++) {
        const cells = xmlRows[i].getElementsByTagName("c")
        const rowData = []

        for (let j = 0; j < cells.length; j++) {
          const cell = cells[j]
          const ref = cell.getAttribute("r") || ""
          const colIdx = this.colRefToIndex(ref)
          const type = cell.getAttribute("t") || ""

          // Pad empty cells
          while (rowData.length < colIdx) rowData.push("")

          let value = ""
          const vNode = cell.getElementsByTagName("v")[0]
          const isNode = cell.getElementsByTagName("is")[0]

          if (isNode) {
            // Inline string
            const tNodes = isNode.getElementsByTagName("t")
            for (let k = 0; k < tNodes.length; k++) {
              value += tNodes[k].textContent || ""
            }
          } else if (vNode) {
            const raw = vNode.textContent || ""
            if (type === "s") {
              // Shared string reference
              value = sharedStrings[parseInt(raw)] || ""
            } else if (type === "b") {
              value = raw === "1" ? "TRUE" : "FALSE"
            } else {
              value = raw
            }
          }

          rowData[colIdx] = value
          if (colIdx + 1 > maxCol) maxCol = colIdx + 1
        }

        this.rows.push(rowData)
      }

      // Pad all rows to same length
      for (const row of this.rows) {
        while (row.length < maxCol) row.push("")
      }

      this.resultSheetNameTarget.textContent = this.sheetName
      this.resultRowsTarget.textContent = this.rows.length
      this.resultColsTarget.textContent = maxCol
      this.renderPreview(maxCol)
      this.downloadBtnTarget.disabled = false

    } catch (err) {
      this.showError("Failed to parse Excel file: " + err.message)
    }
  }

  renderPreview(maxCols) {
    const maxPreviewRows = Math.min(this.rows.length, 20)
    const hasHeader = this.headerCheckboxTarget.checked

    let html = '<table class="min-w-full text-sm border-collapse">'
    html += '<thead><tr>'
    for (let c = 0; c < maxCols; c++) {
      html += `<th class="border border-gray-300 dark:border-gray-600 px-2 py-1 bg-gray-100 dark:bg-gray-700 text-left font-medium">${this.colLetter(c)}</th>`
    }
    html += '</tr></thead><tbody>'

    for (let r = 0; r < maxPreviewRows; r++) {
      const isHeaderRow = hasHeader && r === 0
      html += '<tr>'
      for (let c = 0; c < maxCols; c++) {
        const val = (this.rows[r] && this.rows[r][c]) || ""
        if (isHeaderRow) {
          html += `<td class="border border-gray-200 dark:border-gray-700 px-2 py-1 truncate max-w-[200px] font-bold bg-blue-50 dark:bg-blue-900/30">${this.escapeHtml(val)}</td>`
        } else {
          html += `<td class="border border-gray-200 dark:border-gray-700 px-2 py-1 truncate max-w-[200px]">${this.escapeHtml(val)}</td>`
        }
      }
      html += '</tr>'
    }

    if (this.rows.length > 20) {
      html += `<tr><td colspan="${maxCols}" class="border border-gray-200 dark:border-gray-700 px-2 py-1 text-center text-gray-500 italic">... and ${this.rows.length - 20} more rows</td></tr>`
    }

    html += '</tbody></table>'
    this.previewTableTarget.innerHTML = html
    this.previewTarget.classList.remove("hidden")
  }

  refreshPreview() {
    if (this.rows.length === 0) return
    const maxCols = this.rows.length > 0 ? Math.max(...this.rows.map(r => r.length)) : 0
    this.renderPreview(maxCols)
  }

  download() {
    if (this.rows.length === 0) return

    const hasHeader = this.headerCheckboxTarget.checked
    const pdf = new PdfDocument()

    pdf.addHeading(this.sheetName, 1)
    pdf.addSpacer(10)
    pdf.addTable(this.rows, { hasHeader })

    const buffer = pdf.generate()
    const blob = new Blob([buffer], { type: "application/pdf" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = this.sheetName.replace(/[^a-zA-Z0-9_-]/g, "_") + ".pdf"
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

  colRefToIndex(ref) {
    const match = ref.match(/^([A-Z]+)/)
    if (!match) return 0
    const letters = match[1]
    let idx = 0
    for (let i = 0; i < letters.length; i++) {
      idx = idx * 26 + (letters.charCodeAt(i) - 64)
    }
    return idx - 1
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

  showError(msg) {
    this.previewTableTarget.innerHTML = `<p class="text-red-500 text-sm p-3">${this.escapeHtml(msg)}</p>`
    this.previewTarget.classList.remove("hidden")
  }

  escapeHtml(str) {
    return String(str).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }
}
