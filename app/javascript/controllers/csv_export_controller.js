import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { filename: { type: String, default: "calchammer-results.csv" } }

  export() {
    const table = this.element.closest("[data-csv-export-source]") ||
                  document.querySelector("table[data-exportable]")
    if (!table) return

    const rows = []
    table.querySelectorAll("tr").forEach(tr => {
      const cells = []
      tr.querySelectorAll("th, td").forEach(cell => {
        let text = cell.textContent.trim().replace(/"/g, '""')
        if (text.includes(",") || text.includes('"') || text.includes("\n")) {
          text = `"${text}"`
        }
        cells.push(text)
      })
      rows.push(cells.join(","))
    })

    const csv = rows.join("\n")
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" })
    const url = URL.createObjectURL(blob)
    const link = document.createElement("a")
    link.href = url
    link.download = this.filenameValue
    link.click()
    URL.revokeObjectURL(url)
  }
}
