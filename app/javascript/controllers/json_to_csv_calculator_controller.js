import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "jsonInput", "csvOutput", "delimiter", "previewContainer",
    "resultStatus", "resultRows", "resultCols", "resultHeaders"
  ]

  convert() {
    const json = this.jsonInputTarget.value
    if (!json || !json.trim()) {
      this.clearResults()
      return
    }

    try {
      const parsed = JSON.parse(json)

      if (!Array.isArray(parsed)) {
        this.showError("JSON must be an array of objects")
        return
      }

      if (parsed.length === 0) {
        this.showError("JSON array is empty")
        return
      }

      if (!parsed.every(item => typeof item === "object" && item !== null && !Array.isArray(item))) {
        this.showError("All items must be objects")
        return
      }

      const delimiter = this.delimiterTarget.value
      const delimiters = { comma: ",", tab: "\t", semicolon: ";", pipe: "|" }
      const sep = delimiters[delimiter] || ","

      // Extract union of all keys preserving order
      const headers = []
      parsed.forEach(obj => {
        Object.keys(obj).forEach(key => {
          if (!headers.includes(key)) headers.push(key)
        })
      })

      // Build CSV
      const lines = []
      lines.push(headers.map(h => this.csvEscape(h, sep)).join(sep))

      parsed.forEach(obj => {
        const row = headers.map(h => {
          const val = obj[h]
          return this.csvEscape(val !== null && val !== undefined ? String(val) : "", sep)
        })
        lines.push(row.join(sep))
      })

      const csvText = lines.join("\n")
      this.csvOutputTarget.value = csvText

      // Stats
      this.resultStatusTarget.textContent = "Converted"
      this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400")
      this.resultStatusTarget.classList.add("text-green-600", "dark:text-green-400")
      this.resultRowsTarget.textContent = parsed.length
      this.resultColsTarget.textContent = headers.length
      const headerDisplay = headers.join(", ")
      this.resultHeadersTarget.textContent = headerDisplay.length > 40 ? headerDisplay.substring(0, 37) + "..." : headerDisplay

      // Preview table
      this.renderPreview(headers, parsed)
    } catch (e) {
      this.showError("Invalid JSON: " + e.message)
    }
  }

  csvEscape(value, sep) {
    if (value.includes(sep) || value.includes('"') || value.includes("\n")) {
      return '"' + value.replace(/"/g, '""') + '"'
    }
    return value
  }

  renderPreview(headers, data) {
    const maxRows = Math.min(data.length, 50)
    let html = '<div class="overflow-x-auto"><table class="w-full border-collapse text-sm">'
    html += '<thead><tr>'
    headers.forEach(h => {
      html += `<th class="border border-gray-300 dark:border-gray-600 px-3 py-2 bg-gray-100 dark:bg-gray-700 text-left text-gray-900 dark:text-white font-semibold whitespace-nowrap">${this.escapeHtml(h)}</th>`
    })
    html += '</tr></thead><tbody>'
    for (let i = 0; i < maxRows; i++) {
      html += '<tr>'
      headers.forEach(h => {
        const val = data[i][h]
        html += `<td class="border border-gray-300 dark:border-gray-600 px-3 py-2 text-gray-700 dark:text-gray-300 whitespace-nowrap">${this.escapeHtml(val !== null && val !== undefined ? String(val) : "")}</td>`
      })
      html += '</tr>'
    }
    html += '</tbody></table></div>'
    if (data.length > maxRows) {
      html += `<p class="text-sm text-gray-500 mt-2">Showing ${maxRows} of ${data.length} rows</p>`
    }
    this.previewContainerTarget.innerHTML = html
  }

  copyOutput() {
    const text = this.csvOutputTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      this.flashButton("[data-action*='copyOutput']", "Copied!")
    })
  }

  downloadCsv() {
    const text = this.csvOutputTarget.value
    if (!text) return
    const blob = new Blob([text], { type: "text/csv;charset=utf-8;" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "data.csv"
    a.click()
    URL.revokeObjectURL(url)
  }

  showError(message) {
    this.csvOutputTarget.value = ""
    this.previewContainerTarget.innerHTML = ""
    this.resultStatusTarget.textContent = message
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400")
    this.resultStatusTarget.classList.add("text-red-500", "dark:text-red-400")
    this.resultRowsTarget.textContent = "\u2014"
    this.resultColsTarget.textContent = "\u2014"
    this.resultHeadersTarget.textContent = "\u2014"
  }

  clearResults() {
    this.csvOutputTarget.value = ""
    this.previewContainerTarget.innerHTML = ""
    this.resultStatusTarget.textContent = "\u2014"
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultRowsTarget.textContent = "\u2014"
    this.resultColsTarget.textContent = "\u2014"
    this.resultHeadersTarget.textContent = "\u2014"
  }

  flashButton(selector, message) {
    const btn = this.element.querySelector(selector)
    if (btn) {
      const original = btn.textContent
      btn.textContent = message
      setTimeout(() => { btn.textContent = original }, 1500)
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
