import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "rowCount", "colCount", "tableContainer", "markdownOutput", "previewContainer",
    "resultRows", "resultCols", "resultStatus"
  ]

  generateGrid() {
    const rows = parseInt(this.rowCountTarget.value) || 3
    const cols = parseInt(this.colCountTarget.value) || 3

    if (rows < 1 || rows > 20 || cols < 1 || cols > 20) {
      this.showError("Rows and columns must be between 1 and 20")
      return
    }

    let html = '<table class="w-full border-collapse">'
    for (let r = 0; r < rows; r++) {
      html += "<tr>"
      for (let c = 0; c < cols; c++) {
        const placeholder = r === 0 ? `Header ${c + 1}` : ""
        const bgClass = r === 0 ? "bg-blue-50 dark:bg-blue-900/20 font-semibold" : "bg-white dark:bg-gray-800"
        html += `<td class="border border-gray-300 dark:border-gray-600 p-0">
          <input type="text" data-row="${r}" data-col="${c}"
            class="w-full px-2 py-1.5 text-sm ${bgClass} text-gray-900 dark:text-white focus:outline-none focus:ring-1 focus:ring-blue-500 border-0"
            placeholder="${placeholder}" data-action="paste->markdown-table-generator-calculator#onPaste">
        </td>`
      }
      html += "</tr>"
    }
    html += "</table>"

    this.tableContainerTarget.innerHTML = html
    this.markdownOutputTarget.value = ""
    this.previewContainerTarget.innerHTML = '<p class="text-gray-400 text-center py-4">Click "Generate Markdown" to see output</p>'
    this.resultRowsTarget.textContent = rows
    this.resultColsTarget.textContent = cols
    this.resultStatusTarget.textContent = "Grid ready"
    this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400")
    this.resultStatusTarget.classList.add("text-blue-600", "dark:text-blue-400")
  }

  generateMarkdown() {
    const inputs = this.tableContainerTarget.querySelectorAll("input[data-row]")
    if (inputs.length === 0) {
      this.showError("Generate a grid first")
      return
    }

    const rows = parseInt(this.rowCountTarget.value) || 3
    const cols = parseInt(this.colCountTarget.value) || 3

    // Gather cell data
    const cells = []
    for (let r = 0; r < rows; r++) {
      cells[r] = []
      for (let c = 0; c < cols; c++) {
        const input = this.tableContainerTarget.querySelector(`input[data-row="${r}"][data-col="${c}"]`)
        cells[r][c] = input ? input.value : ""
      }
    }

    // Determine column widths
    const colWidths = new Array(cols).fill(3)
    for (let r = 0; r < rows; r++) {
      for (let c = 0; c < cols; c++) {
        colWidths[c] = Math.max(colWidths[c], (cells[r][c] || "").length)
      }
    }

    // Build markdown
    const lines = []

    // Header row
    const headerCells = []
    for (let c = 0; c < cols; c++) {
      headerCells.push((cells[0][c] || "").padEnd(colWidths[c]))
    }
    lines.push("| " + headerCells.join(" | ") + " |")

    // Separator
    const sepCells = colWidths.map(w => "-".repeat(w))
    lines.push("| " + sepCells.join(" | ") + " |")

    // Data rows
    for (let r = 1; r < rows; r++) {
      const rowCells = []
      for (let c = 0; c < cols; c++) {
        rowCells.push((cells[r][c] || "").padEnd(colWidths[c]))
      }
      lines.push("| " + rowCells.join(" | ") + " |")
    }

    const markdown = lines.join("\n")
    this.markdownOutputTarget.value = markdown

    // Preview
    this.renderPreview(cells, rows, cols)

    this.resultStatusTarget.textContent = "Generated"
    this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400", "text-blue-600", "dark:text-blue-400")
    this.resultStatusTarget.classList.add("text-green-600", "dark:text-green-400")
  }

  renderPreview(cells, rows, cols) {
    let html = '<table class="w-full border-collapse text-sm">'
    // Header
    html += '<thead><tr>'
    for (let c = 0; c < cols; c++) {
      html += `<th class="border border-gray-300 dark:border-gray-600 px-3 py-2 bg-gray-100 dark:bg-gray-700 text-left text-gray-900 dark:text-white font-semibold">${this.escapeHtml(cells[0][c] || "")}</th>`
    }
    html += '</tr></thead><tbody>'
    for (let r = 1; r < rows; r++) {
      html += '<tr>'
      for (let c = 0; c < cols; c++) {
        html += `<td class="border border-gray-300 dark:border-gray-600 px-3 py-2 text-gray-700 dark:text-gray-300">${this.escapeHtml(cells[r][c] || "")}</td>`
      }
      html += '</tr>'
    }
    html += '</tbody></table>'
    this.previewContainerTarget.innerHTML = html
  }

  onPaste(event) {
    const clipboardData = event.clipboardData || window.clipboardData
    const pastedText = clipboardData.getData("text")

    // Check if it looks like tab-separated data (spreadsheet paste)
    if (pastedText.includes("\t")) {
      event.preventDefault()
      const target = event.target
      const startRow = parseInt(target.dataset.row)
      const startCol = parseInt(target.dataset.col)
      const rows = pastedText.split("\n").filter(r => r.length > 0)

      rows.forEach((row, rIdx) => {
        const cells = row.split("\t")
        cells.forEach((cell, cIdx) => {
          const r = startRow + rIdx
          const c = startCol + cIdx
          const input = this.tableContainerTarget.querySelector(`input[data-row="${r}"][data-col="${c}"]`)
          if (input) {
            input.value = cell.trim()
          }
        })
      })
    }
  }

  copyMarkdown() {
    const text = this.markdownOutputTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copyMarkdown']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }

  showError(message) {
    this.resultStatusTarget.textContent = message
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-blue-600", "dark:text-blue-400")
    this.resultStatusTarget.classList.add("text-red-500", "dark:text-red-400")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
