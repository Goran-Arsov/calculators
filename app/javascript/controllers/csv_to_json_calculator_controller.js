import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "csvInput", "jsonOutput", "hasHeaders", "delimiter",
    "resultStatus", "resultRows", "resultColumns", "resultHeaders"
  ]

  convert() {
    const csv = this.csvInputTarget.value
    if (!csv || !csv.trim()) {
      this.clearResults()
      return
    }

    const hasHeaders = this.hasHeadersTarget.checked
    const delimiter = this.delimiterTarget.value

    try {
      const rows = this.parseCsv(csv, delimiter)

      if (rows.length === 0) {
        this.showError("CSV contains no data")
        return
      }

      let result
      let rowCount
      let colCount
      let headerNames

      if (hasHeaders) {
        const headers = rows[0]
        const dataRows = rows.slice(1)
        if (dataRows.length === 0) {
          this.showError("CSV has headers but no data rows")
          return
        }
        result = dataRows.map(row => {
          const obj = {}
          headers.forEach((h, i) => { obj[h] = row[i] !== undefined ? row[i] : null })
          return obj
        })
        rowCount = dataRows.length
        colCount = headers.length
        headerNames = headers.join(", ")
      } else {
        result = rows
        rowCount = rows.length
        colCount = rows[0] ? rows[0].length : 0
        headerNames = "None"
      }

      const json = JSON.stringify(result, null, 2)
      this.jsonOutputTarget.value = json

      this.resultStatusTarget.textContent = "Valid"
      this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400")
      this.resultStatusTarget.classList.add("text-green-600", "dark:text-green-400")
      this.resultRowsTarget.textContent = rowCount
      this.resultColumnsTarget.textContent = colCount
      this.resultHeadersTarget.textContent = headerNames.length > 40 ? headerNames.substring(0, 37) + "..." : headerNames
    } catch (e) {
      this.showError("Parse error: " + e.message)
    }
  }

  parseCsv(text, delimiterName) {
    const delimiters = { comma: ",", tab: "\t", semicolon: ";", pipe: "|" }
    const sep = delimiters[delimiterName] || ","
    const rows = []
    let currentRow = []
    let currentField = ""
    let inQuotes = false

    for (let i = 0; i < text.length; i++) {
      const ch = text[i]
      const next = text[i + 1]

      if (inQuotes) {
        if (ch === '"' && next === '"') {
          currentField += '"'
          i++
        } else if (ch === '"') {
          inQuotes = false
        } else {
          currentField += ch
        }
      } else {
        if (ch === '"') {
          inQuotes = true
        } else if (ch === sep) {
          currentRow.push(currentField)
          currentField = ""
        } else if (ch === "\r" && next === "\n") {
          currentRow.push(currentField)
          currentField = ""
          rows.push(currentRow)
          currentRow = []
          i++
        } else if (ch === "\n") {
          currentRow.push(currentField)
          currentField = ""
          rows.push(currentRow)
          currentRow = []
        } else {
          currentField += ch
        }
      }
    }

    // Push the last field and row
    currentRow.push(currentField)
    if (currentRow.length > 1 || currentRow[0] !== "") {
      rows.push(currentRow)
    }

    return rows
  }

  showError(message) {
    this.jsonOutputTarget.value = ""
    this.resultStatusTarget.textContent = message
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400")
    this.resultStatusTarget.classList.add("text-red-500", "dark:text-red-400")
    this.resultRowsTarget.textContent = "\u2014"
    this.resultColumnsTarget.textContent = "\u2014"
    this.resultHeadersTarget.textContent = "\u2014"
  }

  clearResults() {
    this.jsonOutputTarget.value = ""
    this.resultStatusTarget.textContent = "\u2014"
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultRowsTarget.textContent = "\u2014"
    this.resultColumnsTarget.textContent = "\u2014"
    this.resultHeadersTarget.textContent = "\u2014"
  }

  copyOutput() {
    navigator.clipboard.writeText(this.jsonOutputTarget.value)
  }
}
