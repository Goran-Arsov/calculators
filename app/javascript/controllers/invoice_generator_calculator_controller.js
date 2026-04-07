import { Controller } from "@hotwired/stimulus"
import { PdfDocument } from "utils/pdf_generator"

export default class extends Controller {
  static targets = [
    "businessName", "businessAddress", "businessEmail", "businessPhone", "businessTaxId",
    "businessIban", "businessSwift",
    "clientName", "clientAddress", "clientEmail",
    "invoiceNumber", "invoiceDate", "dueDate", "dueDatePreset",
    "lineItems",
    "taxRate", "discountValue", "discountType",
    "notes", "terms",
    "preview",
    "subtotalDisplay", "taxDisplay", "discountDisplay", "totalDisplay"
  ]

  connect() {
    const today = new Date()
    const dateStr = today.toISOString().split("T")[0]
    this.invoiceDateTarget.value = dateStr

    const ymd = dateStr.replace(/-/g, "")
    this.invoiceNumberTarget.value = `INV-${ymd}-001`

    this.addLineItem()
    this.updatePreview()
  }

  addLineItem() {
    const index = this.lineItemsTarget.querySelectorAll("[data-line-item]").length
    const row = document.createElement("div")
    row.setAttribute("data-line-item", "")
    row.className = "grid grid-cols-12 gap-2 items-end mb-2"
    row.innerHTML = `
      <div class="col-span-5">
        ${index === 0 ? '<label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Description</label>' : ""}
        <input type="text" placeholder="Item description" class="w-full text-sm" data-action="input->invoice-generator-calculator#recalculate">
      </div>
      <div class="col-span-2">
        ${index === 0 ? '<label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Qty</label>' : ""}
        <input type="number" placeholder="1" min="0" step="0.01" class="w-full text-sm" data-action="input->invoice-generator-calculator#recalculate">
      </div>
      <div class="col-span-2">
        ${index === 0 ? '<label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Unit Price</label>' : ""}
        <input type="number" placeholder="0.00" min="0" step="0.01" class="w-full text-sm" data-action="input->invoice-generator-calculator#recalculate">
      </div>
      <div class="col-span-2 text-right">
        ${index === 0 ? '<label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Amount</label>' : ""}
        <span class="inline-block py-2 text-sm font-medium text-gray-700 dark:text-gray-300">$0.00</span>
      </div>
      <div class="col-span-1 text-center">
        ${index === 0 ? '<label class="block text-xs text-transparent mb-1">X</label>' : ""}
        <button type="button" data-action="click->invoice-generator-calculator#removeLineItem" class="text-red-400 hover:text-red-600 transition-colors p-1" title="Remove">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
        </button>
      </div>
    `
    this.lineItemsTarget.appendChild(row)
  }

  removeLineItem(event) {
    const row = event.target.closest("[data-line-item]")
    if (this.lineItemsTarget.querySelectorAll("[data-line-item]").length > 1) {
      row.remove()
      this.recalculate()
    }
  }

  applyDueDatePreset() {
    const preset = this.dueDatePresetTarget.value
    if (!preset || !this.invoiceDateTarget.value) return

    const base = new Date(this.invoiceDateTarget.value + "T00:00:00")
    let days = 0
    if (preset === "receipt") days = 0
    else if (preset === "15") days = 15
    else if (preset === "30") days = 30
    else if (preset === "60") days = 60
    else return

    base.setDate(base.getDate() + days)
    this.dueDateTarget.value = base.toISOString().split("T")[0]
    this.updatePreview()
  }

  recalculate() {
    const rows = this.lineItemsTarget.querySelectorAll("[data-line-item]")
    let subtotal = 0

    rows.forEach(row => {
      const inputs = row.querySelectorAll("input")
      const qty = parseFloat(inputs[1]?.value) || 0
      const price = parseFloat(inputs[2]?.value) || 0
      const amount = qty * price
      subtotal += amount
      const amountSpan = row.querySelector("span")
      if (amountSpan) amountSpan.textContent = this.fmt(amount)
    })

    const taxRate = parseFloat(this.taxRateTarget.value) || 0
    const discountVal = parseFloat(this.discountValueTarget.value) || 0
    const discountType = this.discountTypeTarget.value

    const taxAmount = subtotal * taxRate / 100
    const discountAmount = discountType === "flat" ? discountVal : subtotal * discountVal / 100
    const total = subtotal + taxAmount - discountAmount

    this.subtotalDisplayTarget.textContent = this.fmt(subtotal)
    this.taxDisplayTarget.textContent = this.fmt(taxAmount)
    this.discountDisplayTarget.textContent = this.fmt(discountAmount)
    this.totalDisplayTarget.textContent = this.fmt(total)

    this.updatePreview()
  }

  updatePreview() {
    const businessName = this.businessNameTarget.value || "Your Business Name"
    const businessAddress = this.businessAddressTarget.value || ""
    const businessEmail = this.businessEmailTarget.value || ""
    const businessPhone = this.businessPhoneTarget.value || ""
    const businessTaxId = this.businessTaxIdTarget.value || ""
    const businessIban = this.businessIbanTarget.value || ""
    const businessSwift = this.businessSwiftTarget.value || ""

    const clientName = this.clientNameTarget.value || "Client Name"
    const clientAddress = this.clientAddressTarget.value || ""
    const clientEmail = this.clientEmailTarget.value || ""

    const invoiceNumber = this.invoiceNumberTarget.value || ""
    const invoiceDate = this.invoiceDateTarget.value || ""
    const dueDate = this.dueDateTarget.value || ""
    const notes = this.notesTarget.value || ""
    const terms = this.termsTarget.value || ""

    const rows = this.lineItemsTarget.querySelectorAll("[data-line-item]")
    let subtotal = 0
    let itemsHtml = ""

    rows.forEach(row => {
      const inputs = row.querySelectorAll("input")
      const desc = inputs[0]?.value || ""
      const qty = parseFloat(inputs[1]?.value) || 0
      const price = parseFloat(inputs[2]?.value) || 0
      const amount = qty * price
      subtotal += amount
      if (desc || qty || price) {
        itemsHtml += `<tr class="border-b border-gray-200 dark:border-gray-700">
          <td class="py-2 px-3 text-sm">${this.escapeHtml(desc)}</td>
          <td class="py-2 px-3 text-sm text-right">${qty}</td>
          <td class="py-2 px-3 text-sm text-right">${this.fmt(price)}</td>
          <td class="py-2 px-3 text-sm text-right font-medium">${this.fmt(amount)}</td>
        </tr>`
      }
    })

    const taxRate = parseFloat(this.taxRateTarget.value) || 0
    const discountVal = parseFloat(this.discountValueTarget.value) || 0
    const discountType = this.discountTypeTarget.value
    const taxAmount = subtotal * taxRate / 100
    const discountAmount = discountType === "flat" ? discountVal : subtotal * discountVal / 100
    const total = subtotal + taxAmount - discountAmount

    const formatDate = (d) => {
      if (!d) return ""
      const parts = d.split("-")
      if (parts.length !== 3) return d
      return `${parts[1]}/${parts[2]}/${parts[0]}`
    }

    this.previewTarget.innerHTML = `
      <div class="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-xl p-8 shadow-sm print:shadow-none print:border-0">
        <!-- Header -->
        <div class="flex justify-between items-start mb-8">
          <div>
            <h3 class="text-xl font-bold text-gray-900 dark:text-white">${this.escapeHtml(businessName)}</h3>
            ${businessAddress ? `<p class="text-sm text-gray-500 dark:text-gray-400 whitespace-pre-line">${this.escapeHtml(businessAddress)}</p>` : ""}
            ${businessEmail ? `<p class="text-sm text-gray-500 dark:text-gray-400">${this.escapeHtml(businessEmail)}</p>` : ""}
            ${businessPhone ? `<p class="text-sm text-gray-500 dark:text-gray-400">${this.escapeHtml(businessPhone)}</p>` : ""}
            ${businessTaxId ? `<p class="text-sm text-gray-500 dark:text-gray-400">Tax ID: ${this.escapeHtml(businessTaxId)}</p>` : ""}
          </div>
          <div class="text-right">
            <h2 class="text-3xl font-extrabold text-blue-600 dark:text-blue-400 tracking-tight">INVOICE</h2>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">${this.escapeHtml(invoiceNumber)}</p>
          </div>
        </div>

        <!-- Client & Dates -->
        <div class="grid grid-cols-2 gap-8 mb-8">
          <div>
            <p class="text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-1">Bill To</p>
            <p class="text-sm font-semibold text-gray-900 dark:text-white">${this.escapeHtml(clientName)}</p>
            ${clientAddress ? `<p class="text-sm text-gray-500 dark:text-gray-400 whitespace-pre-line">${this.escapeHtml(clientAddress)}</p>` : ""}
            ${clientEmail ? `<p class="text-sm text-gray-500 dark:text-gray-400">${this.escapeHtml(clientEmail)}</p>` : ""}
          </div>
          <div class="text-right">
            <div class="space-y-1">
              <p class="text-sm text-gray-500 dark:text-gray-400"><span class="font-semibold">Date:</span> ${formatDate(invoiceDate)}</p>
              ${dueDate ? `<p class="text-sm text-gray-500 dark:text-gray-400"><span class="font-semibold">Due Date:</span> ${formatDate(dueDate)}</p>` : ""}
            </div>
          </div>
        </div>

        <!-- Line Items -->
        <table class="w-full mb-6">
          <thead>
            <tr class="bg-gray-100 dark:bg-gray-800">
              <th class="py-2 px-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Description</th>
              <th class="py-2 px-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Qty</th>
              <th class="py-2 px-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Unit Price</th>
              <th class="py-2 px-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Amount</th>
            </tr>
          </thead>
          <tbody>
            ${itemsHtml || '<tr><td colspan="4" class="py-4 text-center text-sm text-gray-400">No items added yet</td></tr>'}
          </tbody>
        </table>

        <!-- Totals -->
        <div class="flex justify-end mb-8">
          <div class="w-64">
            <div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">Subtotal</span>
              <span class="font-medium text-gray-700 dark:text-gray-300">${this.fmt(subtotal)}</span>
            </div>
            ${taxRate > 0 ? `<div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">Tax (${taxRate}%)</span>
              <span class="font-medium text-gray-700 dark:text-gray-300">${this.fmt(taxAmount)}</span>
            </div>` : ""}
            ${discountVal > 0 ? `<div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">Discount${discountType === "flat" ? "" : ` (${discountVal}%)`}</span>
              <span class="font-medium text-red-500">-${this.fmt(discountAmount)}</span>
            </div>` : ""}
            <div class="flex justify-between py-2 border-t-2 border-gray-900 dark:border-gray-200 mt-1">
              <span class="text-base font-bold text-gray-900 dark:text-white">Total</span>
              <span class="text-base font-bold text-gray-900 dark:text-white">${this.fmt(total)}</span>
            </div>
          </div>
        </div>

        <!-- Payment Details -->
        ${(businessIban || businessSwift) ? `
        <div class="mb-6 p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
          <p class="text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider mb-2">Payment Details</p>
          ${businessIban ? `<p class="text-sm text-gray-700 dark:text-gray-300"><span class="font-semibold">IBAN:</span> ${this.escapeHtml(businessIban)}</p>` : ""}
          ${businessSwift ? `<p class="text-sm text-gray-700 dark:text-gray-300"><span class="font-semibold">SWIFT/BIC:</span> ${this.escapeHtml(businessSwift)}</p>` : ""}
        </div>` : ""}

        <!-- Notes & Terms -->
        ${notes ? `
        <div class="mb-4">
          <p class="text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider mb-1">Notes</p>
          <p class="text-sm text-gray-500 dark:text-gray-400 whitespace-pre-line">${this.escapeHtml(notes)}</p>
        </div>` : ""}
        ${terms ? `
        <div class="mb-4">
          <p class="text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider mb-1">Terms & Conditions</p>
          <p class="text-sm text-gray-500 dark:text-gray-400 whitespace-pre-line">${this.escapeHtml(terms)}</p>
        </div>` : ""}
      </div>
    `
  }

  downloadPdf() {
    const pdf = new PdfDocument()

    // Business info
    const businessName = this.businessNameTarget.value || "Your Business Name"
    pdf.addHeading(businessName, 1)

    const businessAddress = this.businessAddressTarget.value
    const businessEmail = this.businessEmailTarget.value
    const businessPhone = this.businessPhoneTarget.value
    const businessTaxId = this.businessTaxIdTarget.value

    if (businessAddress) pdf.addText(businessAddress)
    if (businessEmail) pdf.addText(businessEmail)
    if (businessPhone) pdf.addText(businessPhone)
    if (businessTaxId) pdf.addText(`Tax ID: ${businessTaxId}`)

    pdf.addSpacer(10)
    pdf.addHeading("INVOICE", 2)
    pdf.addText(`Invoice #: ${this.invoiceNumberTarget.value || ""}`)
    pdf.addText(`Date: ${this.invoiceDateTarget.value || ""}`)
    if (this.dueDateTarget.value) pdf.addText(`Due Date: ${this.dueDateTarget.value}`)

    pdf.addSpacer(10)
    pdf.addHeading("Bill To:", 3)
    pdf.addText(this.clientNameTarget.value || "Client Name")
    if (this.clientAddressTarget.value) pdf.addText(this.clientAddressTarget.value)
    if (this.clientEmailTarget.value) pdf.addText(this.clientEmailTarget.value)

    pdf.addSpacer(10)

    // Line items table
    const tableRows = [["Description", "Qty", "Unit Price", "Amount"]]
    const rows = this.lineItemsTarget.querySelectorAll("[data-line-item]")
    let subtotal = 0

    rows.forEach(row => {
      const inputs = row.querySelectorAll("input")
      const desc = inputs[0]?.value || ""
      const qty = parseFloat(inputs[1]?.value) || 0
      const price = parseFloat(inputs[2]?.value) || 0
      const amount = qty * price
      subtotal += amount
      if (desc || qty || price) {
        tableRows.push([desc, String(qty), this.fmt(price), this.fmt(amount)])
      }
    })

    pdf.addTable(tableRows, { hasHeader: true })
    pdf.addSpacer(5)

    const taxRate = parseFloat(this.taxRateTarget.value) || 0
    const discountVal = parseFloat(this.discountValueTarget.value) || 0
    const discountType = this.discountTypeTarget.value
    const taxAmount = subtotal * taxRate / 100
    const discountAmount = discountType === "flat" ? discountVal : subtotal * discountVal / 100
    const total = subtotal + taxAmount - discountAmount

    pdf.addText(`Subtotal: ${this.fmt(subtotal)}`, { font: "Helvetica-Bold" })
    if (taxRate > 0) pdf.addText(`Tax (${taxRate}%): ${this.fmt(taxAmount)}`)
    if (discountVal > 0) pdf.addText(`Discount: -${this.fmt(discountAmount)}`)
    pdf.addText(`Total: ${this.fmt(total)}`, { font: "Helvetica-Bold", fontSize: 14 })

    // Payment details
    const iban = this.businessIbanTarget.value
    const swift = this.businessSwiftTarget.value
    if (iban || swift) {
      pdf.addSpacer(10)
      pdf.addHeading("Payment Details:", 3)
      if (iban) pdf.addText(`IBAN: ${iban}`)
      if (swift) pdf.addText(`SWIFT/BIC: ${swift}`)
    }

    // Notes
    const notes = this.notesTarget.value
    if (notes) {
      pdf.addSpacer(10)
      pdf.addHeading("Notes:", 3)
      pdf.addParagraph(notes)
    }

    // Terms
    const terms = this.termsTarget.value
    if (terms) {
      pdf.addSpacer(10)
      pdf.addHeading("Terms & Conditions:", 3)
      pdf.addParagraph(terms)
    }

    const buffer = pdf.generate()
    const blob = new Blob([buffer], { type: "application/pdf" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `${this.invoiceNumberTarget.value || "invoice"}.pdf`
    a.click()
    URL.revokeObjectURL(url)
  }

  printInvoice() {
    window.print()
  }

  // --- Helpers ---

  fmt(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
