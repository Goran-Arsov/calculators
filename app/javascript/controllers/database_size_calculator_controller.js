import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "numRows", "columnsContainer",
    "resultBytesPerRow", "resultRawSize", "resultWithIndex", "resultFormattedRaw",
    "resultFormattedIndex", "resultColumnCount",
    "resultsContainer"
  ]

  static values = {
    columnCount: { type: Number, default: 3 }
  }

  connect() {
    this.renderColumns()
  }

  addColumn() {
    this.columnCountValue++
    this.renderColumns()
    this.calculate()
  }

  removeColumn(event) {
    if (this.columnCountValue <= 1) return
    const row = event.target.closest("[data-column-row]")
    if (row) {
      row.remove()
      this.columnCountValue = this.columnsContainerTarget.querySelectorAll("[data-column-row]").length
      this.calculate()
    }
  }

  renderColumns() {
    const existing = this.columnsContainerTarget.querySelectorAll("[data-column-row]")
    const currentCount = existing.length

    for (let i = currentCount; i < this.columnCountValue; i++) {
      this.columnsContainerTarget.insertAdjacentHTML("beforeend", this.columnRowHTML(i))
    }
  }

  columnRowHTML(index) {
    return `
      <div data-column-row class="flex items-center gap-2 mb-2">
        <select data-col-type
          data-action="change->database-size-calculator#onTypeChange input->database-size-calculator#calculate"
          class="flex-1 rounded-xl border-[1.5px] border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white p-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
          <option value="integer">integer (4B)</option>
          <option value="bigint">bigint (8B)</option>
          <option value="boolean">boolean (1B)</option>
          <option value="timestamp">timestamp (8B)</option>
          <option value="float">float (8B)</option>
          <option value="uuid">uuid (16B)</option>
          <option value="varchar">varchar (variable)</option>
          <option value="text">text (variable)</option>
        </select>
        <input type="number" data-col-avg-bytes value=""
          placeholder="Avg bytes" min="1"
          data-action="input->database-size-calculator#calculate"
          class="w-24 rounded-xl border-[1.5px] border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white p-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 hidden">
        <button type="button" data-action="click->database-size-calculator#removeColumn"
          class="p-2 text-red-500 hover:text-red-700 dark:text-red-400 dark:hover:text-red-300 transition-colors"
          title="Remove column">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
        </button>
      </div>
    `
  }

  onTypeChange(event) {
    const row = event.target.closest("[data-column-row]")
    const avgBytesInput = row.querySelector("[data-col-avg-bytes]")
    const type = event.target.value

    if (type === "varchar" || type === "text") {
      avgBytesInput.classList.remove("hidden")
      if (!avgBytesInput.value) avgBytesInput.value = type === "varchar" ? "50" : "200"
    } else {
      avgBytesInput.classList.add("hidden")
      avgBytesInput.value = ""
    }
    this.calculate()
  }

  calculate() {
    const numRows = parseInt(this.numRowsTarget.value) || 0
    if (numRows <= 0) {
      this.clearResults()
      return
    }

    const columnRows = this.columnsContainerTarget.querySelectorAll("[data-column-row]")
    if (columnRows.length === 0) {
      this.clearResults()
      return
    }

    const FIXED_BYTES = {
      "integer": 4, "bigint": 8, "boolean": 1,
      "timestamp": 8, "float": 8, "uuid": 16
    }
    const VARIABLE_TYPES = ["varchar", "text"]
    const PG_OVERHEAD = 23
    const INDEX_FACTOR = 1.3

    let bytesPerRow = 0
    let valid = true

    columnRows.forEach(row => {
      const type = row.querySelector("[data-col-type]").value
      if (FIXED_BYTES[type] !== undefined) {
        bytesPerRow += FIXED_BYTES[type]
      } else if (VARIABLE_TYPES.includes(type)) {
        const avgBytes = parseInt(row.querySelector("[data-col-avg-bytes]").value) || 0
        if (avgBytes <= 0) { valid = false; return }
        bytesPerRow += avgBytes
      }
    })

    if (!valid) {
      this.clearResults()
      return
    }

    const rawRowBytes = bytesPerRow + PG_OVERHEAD
    const rawTableSize = rawRowBytes * numRows
    const withIndexSize = Math.round(rawTableSize * INDEX_FACTOR)

    this.resultsContainerTarget.classList.remove("hidden")
    this.resultBytesPerRowTarget.textContent = bytesPerRow.toLocaleString() + " B"
    this.resultRawSizeTarget.textContent = rawTableSize.toLocaleString() + " B"
    this.resultWithIndexTarget.textContent = withIndexSize.toLocaleString() + " B"
    this.resultFormattedRawTarget.textContent = this.formatBytes(rawTableSize)
    this.resultFormattedIndexTarget.textContent = this.formatBytes(withIndexSize)
    this.resultColumnCountTarget.textContent = columnRows.length
  }

  formatBytes(bytes) {
    if (bytes >= 1073741824) {
      return (bytes / 1073741824).toFixed(2) + " GB"
    } else if (bytes >= 1048576) {
      return (bytes / 1048576).toFixed(2) + " MB"
    } else if (bytes >= 1024) {
      return (bytes / 1024).toFixed(2) + " KB"
    } else {
      return bytes + " B"
    }
  }

  clearResults() {
    this.resultsContainerTarget.classList.add("hidden")
    this.resultBytesPerRowTarget.textContent = "\u2014"
    this.resultRawSizeTarget.textContent = "\u2014"
    this.resultWithIndexTarget.textContent = "\u2014"
    this.resultFormattedRawTarget.textContent = "\u2014"
    this.resultFormattedIndexTarget.textContent = "\u2014"
    this.resultColumnCountTarget.textContent = "\u2014"
  }
}
