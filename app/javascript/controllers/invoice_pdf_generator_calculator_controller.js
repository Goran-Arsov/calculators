import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "invoiceNumber", "date", "dueDate", "fromName", "fromAddress",
    "toName", "toAddress", "taxRate", "notes", "currency",
    "lineItems", "output", "error",
    "resultSubtotal", "resultTax", "resultTotal"
  ]

  connect() {
    this.itemCount = 1
  }

  addItem() {
    this.itemCount++
    const row = document.createElement("div")
    row.classList.add("grid", "grid-cols-12", "gap-2", "items-end")
    row.dataset.lineItem = ""
    row.innerHTML = `
      <div class="col-span-6">
        <input type="text" placeholder="Description" data-field="description" class="w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 text-sm">
      </div>
      <div class="col-span-2">
        <input type="number" placeholder="Qty" value="1" min="0.01" step="1" data-field="quantity" class="w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 text-sm">
      </div>
      <div class="col-span-3">
        <input type="number" placeholder="Price" min="0" step="0.01" data-field="unit_price" class="w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 text-sm">
      </div>
      <div class="col-span-1">
        <button type="button" data-action="click->invoice-pdf-generator-calculator#removeItem" class="w-full px-2 py-2 text-red-500 hover:text-red-700 text-sm font-bold">&times;</button>
      </div>
    `
    this.lineItemsTarget.appendChild(row)
  }

  removeItem(event) {
    const row = event.target.closest("[data-line-item]")
    if (row && this.lineItemsTarget.querySelectorAll("[data-line-item]").length > 1) {
      row.remove()
    }
  }

  generate() {
    const invoiceNumber = this.invoiceNumberTarget.value.trim()
    const date = this.dateTarget.value
    const dueDate = this.dueDateTarget.value
    const fromName = this.fromNameTarget.value.trim()
    const toName = this.toNameTarget.value.trim()

    const errors = []
    if (!invoiceNumber) errors.push("Invoice number required")
    if (!date) errors.push("Date required")
    if (!dueDate) errors.push("Due date required")
    if (!fromName) errors.push("From name required")
    if (!toName) errors.push("To name required")

    const items = this.getLineItems()
    if (items.length === 0) errors.push("At least one line item required")

    if (errors.length > 0) { this.showError(errors.join(". ")); return }
    this.hideError()

    const taxRate = parseFloat(this.taxRateTarget.value) || 0
    const currency = this.currencyTarget.value || "USD"
    const sym = { USD: "$", EUR: "\u20AC", GBP: "\u00A3", JPY: "\u00A5", CAD: "CA$", AUD: "A$" }[currency] || "$"

    const subtotal = items.reduce((sum, item) => sum + item.quantity * item.unitPrice, 0)
    const tax = subtotal * (taxRate / 100)
    const total = subtotal + tax

    this.resultSubtotalTarget.textContent = `${sym}${subtotal.toFixed(2)}`
    this.resultTaxTarget.textContent = `${sym}${tax.toFixed(2)}`
    this.resultTotalTarget.textContent = `${sym}${total.toFixed(2)}`

    // Generate text invoice
    const sep = "=".repeat(60)
    const dash = "-".repeat(60)
    const lines = []
    lines.push(sep)
    lines.push(this.center("INVOICE", 60))
    lines.push(sep)
    lines.push("")
    lines.push(`Invoice #: ${invoiceNumber}`)
    lines.push(`Date:      ${date}`)
    lines.push(`Due Date:  ${dueDate}`)
    lines.push("")
    lines.push(dash)
    lines.push("")
    lines.push("FROM:")
    lines.push(`  ${fromName}`)
    if (this.fromAddressTarget.value.trim()) lines.push(`  ${this.fromAddressTarget.value.trim()}`)
    lines.push("")
    lines.push("TO:")
    lines.push(`  ${toName}`)
    if (this.toAddressTarget.value.trim()) lines.push(`  ${this.toAddressTarget.value.trim()}`)
    lines.push("")
    lines.push(dash)
    lines.push("")
    lines.push(this.pad("Description", 30) + this.pad("Qty", 8) + this.pad("Price", 10) + this.pad("Total", 10))
    lines.push(dash)

    items.forEach(item => {
      const lineTotal = item.quantity * item.unitPrice
      lines.push(
        this.pad(item.description.substring(0, 30), 30) +
        this.pad(item.quantity.toString(), 8) +
        this.pad(`${sym}${item.unitPrice.toFixed(2)}`, 10) +
        this.pad(`${sym}${lineTotal.toFixed(2)}`, 10)
      )
    })

    lines.push(dash)
    lines.push(this.pad("", 40) + this.pad("Subtotal:", 10) + `${sym}${subtotal.toFixed(2)}`)
    if (taxRate > 0) lines.push(this.pad("", 40) + this.pad(`Tax (${taxRate}%):`, 10) + `${sym}${tax.toFixed(2)}`)
    lines.push(this.pad("", 40) + this.pad("TOTAL:", 10) + `${sym}${total.toFixed(2)}`)
    lines.push(sep)

    const notes = this.notesTarget.value.trim()
    if (notes) { lines.push(""); lines.push("Notes:"); lines.push(notes) }

    lines.push("")
    lines.push(this.center("Thank you for your business!", 60))
    lines.push(sep)

    this.outputTarget.value = lines.join("\n")
  }

  getLineItems() {
    const rows = this.lineItemsTarget.querySelectorAll("[data-line-item]")
    const items = []
    rows.forEach(row => {
      const desc = row.querySelector("[data-field='description']")?.value?.trim() || ""
      const qty = parseFloat(row.querySelector("[data-field='quantity']")?.value) || 0
      const price = parseFloat(row.querySelector("[data-field='unit_price']")?.value) || 0
      if (desc && qty > 0 && price > 0) items.push({ description: desc, quantity: qty, unitPrice: price })
    })
    return items
  }

  pad(str, len) { return str.padEnd(len) }
  center(str, width) { const pad = Math.max(0, Math.floor((width - str.length) / 2)); return " ".repeat(pad) + str }

  showError(msg) { this.errorTarget.textContent = msg; this.errorTarget.classList.remove("hidden") }
  hideError() { this.errorTarget.classList.add("hidden") }

  copy() {
    const text = this.outputTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) { const o = btn.textContent; btn.textContent = "Copied!"; setTimeout(() => { btn.textContent = o }, 1500) }
    })
  }

  download() {
    const text = this.outputTarget.value
    if (!text) return
    const blob = new Blob([text], { type: "text/plain" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `invoice-${this.invoiceNumberTarget.value.trim() || "001"}.txt`
    a.click()
    URL.revokeObjectURL(url)
  }
}
