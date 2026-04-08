import { Controller } from "@hotwired/stimulus"
import { PdfDocument } from "utils/pdf_generator"

export default class extends Controller {
  static targets = [
    "businessName", "businessAddress", "businessEmail", "businessPhone", "businessTaxId",
    "businessIban", "businessSwift",
    "clientName", "clientAddress", "clientEmail",
    "invoiceNumber", "invoiceDate", "dueDate", "dueDatePreset",
    "lineItems",
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
    row.className = "border border-gray-200 dark:border-gray-700 rounded-xl p-4 mb-3 bg-gray-50 dark:bg-gray-800/50"

    const labels = index === 0 ? true : false
    const ctrl = "detailed-invoice-generator-calculator"

    row.innerHTML = `
      <div class="flex items-start justify-between gap-2 mb-2">
        <div class="grid grid-cols-2 gap-2 flex-1">
          <div>
            <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Item Name</label>
            <input type="text" placeholder="Item name" class="w-full text-sm" data-field="item_name" data-action="input->${ctrl}#recalculate">
          </div>
          <div>
            <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Item Code</label>
            <input type="text" placeholder="SKU-001" class="w-full text-sm" data-field="item_code" data-action="input->${ctrl}#recalculate">
          </div>
        </div>
        <div class="pt-5">
          <button type="button" data-action="click->${ctrl}#removeLineItem" class="text-red-400 hover:text-red-600 transition-colors p-1" title="Remove">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
          </button>
        </div>
      </div>
      <div class="grid grid-cols-3 gap-2 mb-2">
        <div>
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Unit</label>
          <input type="text" placeholder="pcs" class="w-full text-sm" data-field="unit" data-action="input->${ctrl}#recalculate">
        </div>
        <div>
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Unit Price</label>
          <input type="number" placeholder="0.00" min="0" step="0.01" class="w-full text-sm" data-field="unit_price" data-action="input->${ctrl}#recalculate">
        </div>
        <div>
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Qty</label>
          <input type="number" placeholder="1" min="0" step="0.01" class="w-full text-sm" data-field="qty" data-action="input->${ctrl}#recalculate">
        </div>
      </div>
      <div class="grid grid-cols-12 gap-2 items-end">
        <div class="col-span-4">
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Discount Type</label>
          <select class="w-full text-sm" data-field="discount_type" data-action="change->${ctrl}#recalculate">
            <option value="none">No Discount</option>
            <option value="percent">Percentage (%)</option>
            <option value="flat">Flat Amount ($)</option>
          </select>
        </div>
        <div class="col-span-3">
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Discount Value</label>
          <input type="number" placeholder="0" min="0" step="0.01" class="w-full text-sm" data-field="discount_value" data-action="input->${ctrl}#recalculate">
        </div>
        <div class="col-span-2">
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Tax %</label>
          <input type="number" placeholder="0" min="0" max="100" step="0.01" class="w-full text-sm" data-field="tax" data-action="input->${ctrl}#recalculate">
        </div>
        <div class="col-span-3 text-right">
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">Total w/ Tax</label>
          <span class="inline-block py-2 text-sm font-bold text-gray-900 dark:text-white" data-field="line_total">$0.00</span>
        </div>
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
    let totalSubtotal = 0
    let totalTax = 0
    let totalDiscount = 0
    let grandTotal = 0

    rows.forEach(row => {
      const qty = parseFloat(this.fieldValue(row, "qty")) || 0
      const unitPrice = parseFloat(this.fieldValue(row, "unit_price")) || 0
      const tax = parseFloat(this.fieldValue(row, "tax")) || 0
      const discountType = this.fieldValue(row, "discount_type") || "none"
      const discountValue = parseFloat(this.fieldValue(row, "discount_value")) || 0

      const subtotal = qty * unitPrice
      const taxAmount = subtotal * tax / 100
      const priceWithTax = subtotal + taxAmount

      let discountAmount = 0
      if (discountType === "percent") discountAmount = priceWithTax * discountValue / 100
      else if (discountType === "flat") discountAmount = discountValue

      const lineTotal = priceWithTax - discountAmount

      totalSubtotal += subtotal
      totalTax += taxAmount
      totalDiscount += discountAmount
      grandTotal += lineTotal

      const totalSpan = row.querySelector('[data-field="line_total"]')
      if (totalSpan) totalSpan.textContent = this.fmt(lineTotal)

    })

    this.subtotalDisplayTarget.textContent = this.fmt(totalSubtotal)
    this.taxDisplayTarget.textContent = this.fmt(totalTax)
    this.discountDisplayTarget.textContent = this.fmt(totalDiscount)
    this.totalDisplayTarget.textContent = this.fmt(grandTotal)

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
    let totalSubtotal = 0
    let totalTax = 0
    let totalDiscount = 0
    let grandTotal = 0
    let itemsHtml = ""

    rows.forEach(row => {
      const itemName = this.fieldValue(row, "item_name") || ""
      const itemCode = this.fieldValue(row, "item_code") || ""
      const unit = this.fieldValue(row, "unit") || ""
      const qty = parseFloat(this.fieldValue(row, "qty")) || 0
      const unitPrice = parseFloat(this.fieldValue(row, "unit_price")) || 0
      const tax = parseFloat(this.fieldValue(row, "tax")) || 0
      const discountType = this.fieldValue(row, "discount_type") || "none"
      const discountValue = parseFloat(this.fieldValue(row, "discount_value")) || 0

      const subtotal = qty * unitPrice
      const taxAmount = subtotal * tax / 100
      const priceWithTax = subtotal + taxAmount
      let discountAmount = 0
      if (discountType === "percent") discountAmount = priceWithTax * discountValue / 100
      else if (discountType === "flat") discountAmount = discountValue
      const lineTotal = priceWithTax - discountAmount

      totalSubtotal += subtotal
      totalTax += taxAmount
      totalDiscount += discountAmount
      grandTotal += lineTotal

      if (itemName || qty || unitPrice) {
        const discountLabel = discountType === "none" ? "—" : (discountType === "percent" ? `${discountValue}%` : this.fmt(discountValue))
        itemsHtml += `<tr class="border-b border-gray-200 dark:border-gray-700">
          <td class="py-2 px-2 text-sm">${this.escapeHtml(itemName)}</td>
          <td class="py-2 px-2 text-sm text-gray-500">${this.escapeHtml(itemCode)}</td>
          <td class="py-2 px-2 text-sm text-center">${this.escapeHtml(unit)}</td>
          <td class="py-2 px-2 text-sm text-right">${this.fmt(unitPrice)}</td>
          <td class="py-2 px-2 text-sm text-right">${qty}</td>
          <td class="py-2 px-2 text-sm text-right">${tax}%</td>
          <td class="py-2 px-2 text-sm text-right">${this.fmt(priceWithTax)}</td>
          <td class="py-2 px-2 text-sm text-center">${discountLabel}</td>
          <td class="py-2 px-2 text-sm text-right font-medium">${this.fmt(lineTotal)}</td>
        </tr>`
      }
    })

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
        <div class="overflow-x-auto">
          <table class="w-full mb-6">
            <thead>
              <tr class="bg-gray-100 dark:bg-gray-800">
                <th class="py-2 px-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Item</th>
                <th class="py-2 px-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Code</th>
                <th class="py-2 px-2 text-center text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Unit</th>
                <th class="py-2 px-2 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Price</th>
                <th class="py-2 px-2 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Qty</th>
                <th class="py-2 px-2 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Tax</th>
                <th class="py-2 px-2 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">w/ Tax</th>
                <th class="py-2 px-2 text-center text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Disc.</th>
                <th class="py-2 px-2 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Total</th>
              </tr>
            </thead>
            <tbody>
              ${itemsHtml || '<tr><td colspan="9" class="py-4 text-center text-sm text-gray-400">No items added yet</td></tr>'}
            </tbody>
          </table>
        </div>

        <!-- Totals -->
        <div class="flex justify-end mb-8">
          <div class="w-72">
            <div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">Subtotal</span>
              <span class="font-medium text-gray-700 dark:text-gray-300">${this.fmt(totalSubtotal)}</span>
            </div>
            ${totalTax > 0 ? `<div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">Total Tax</span>
              <span class="font-medium text-gray-700 dark:text-gray-300">${this.fmt(totalTax)}</span>
            </div>` : ""}
            ${totalDiscount > 0 ? `<div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">Total Discount</span>
              <span class="font-medium text-red-500">-${this.fmt(totalDiscount)}</span>
            </div>` : ""}
            <div class="flex justify-between py-2 border-t-2 border-gray-900 dark:border-gray-200 mt-1">
              <span class="text-base font-bold text-gray-900 dark:text-white">Grand Total</span>
              <span class="text-base font-bold text-gray-900 dark:text-white">${this.fmt(grandTotal)}</span>
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

    const tableRows = [["Item", "Code", "Unit", "Price", "Qty", "Tax", "w/ Tax", "Disc.", "Total"]]
    const rows = this.lineItemsTarget.querySelectorAll("[data-line-item]")
    let totalSubtotal = 0
    let totalTax = 0
    let totalDiscount = 0
    let grandTotal = 0

    rows.forEach(row => {
      const itemName = this.fieldValue(row, "item_name") || ""
      const itemCode = this.fieldValue(row, "item_code") || ""
      const unit = this.fieldValue(row, "unit") || ""
      const qty = parseFloat(this.fieldValue(row, "qty")) || 0
      const unitPrice = parseFloat(this.fieldValue(row, "unit_price")) || 0
      const tax = parseFloat(this.fieldValue(row, "tax")) || 0
      const discountType = this.fieldValue(row, "discount_type") || "none"
      const discountValue = parseFloat(this.fieldValue(row, "discount_value")) || 0

      const subtotal = qty * unitPrice
      const taxAmount = subtotal * tax / 100
      const priceWithTax = subtotal + taxAmount
      let discountAmount = 0
      if (discountType === "percent") discountAmount = priceWithTax * discountValue / 100
      else if (discountType === "flat") discountAmount = discountValue
      const lineTotal = priceWithTax - discountAmount

      totalSubtotal += subtotal
      totalTax += taxAmount
      totalDiscount += discountAmount
      grandTotal += lineTotal

      if (itemName || qty || unitPrice) {
        const discountLabel = discountType === "none" ? "—" : (discountType === "percent" ? `${discountValue}%` : this.fmt(discountValue))
        tableRows.push([itemName, itemCode, unit, this.fmt(unitPrice), String(qty), `${tax}%`, this.fmt(priceWithTax), discountLabel, this.fmt(lineTotal)])
      }
    })

    pdf.addTable(tableRows, { hasHeader: true })
    pdf.addSpacer(5)

    pdf.addText(`Subtotal: ${this.fmt(totalSubtotal)}`, { font: "Helvetica-Bold" })
    if (totalTax > 0) pdf.addText(`Total Tax: ${this.fmt(totalTax)}`)
    if (totalDiscount > 0) pdf.addText(`Total Discount: -${this.fmt(totalDiscount)}`)
    pdf.addText(`Grand Total: ${this.fmt(grandTotal)}`, { font: "Helvetica-Bold", fontSize: 14 })

    const iban = this.businessIbanTarget.value
    const swift = this.businessSwiftTarget.value
    if (iban || swift) {
      pdf.addSpacer(10)
      pdf.addHeading("Payment Details:", 3)
      if (iban) pdf.addText(`IBAN: ${iban}`)
      if (swift) pdf.addText(`SWIFT/BIC: ${swift}`)
    }

    const notes = this.notesTarget.value
    if (notes) {
      pdf.addSpacer(10)
      pdf.addHeading("Notes:", 3)
      pdf.addParagraph(notes)
    }

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

  fieldValue(row, fieldName) {
    const el = row.querySelector(`[data-field="${fieldName}"]`)
    return el ? el.value : ""
  }

  fmt(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
