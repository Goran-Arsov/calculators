import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "businessName", "businessAddress", "businessEmail", "businessPhone", "businessTaxId",
    "businessIban", "businessSwift",
    "clientName", "clientAddress", "clientEmail",
    "invoiceNumber", "invoiceDate", "dueDate", "dueDatePreset",
    "currency",
    "lineItems",
    "notes", "terms",
    "preview",
    "subtotalDisplay", "taxDisplay", "discountDisplay", "totalDisplay"
  ]

  static values = {
    labels: { type: Object, default: {} }
  }

  connect() {
    const today = new Date()
    const dateStr = today.toISOString().split("T")[0]
    this.invoiceDateTarget.value = dateStr

    const ymd = dateStr.replace(/-/g, "")
    this.invoiceNumberTarget.value = `INV-${ymd}-001`

    this.addLineItem()
    this.updatePreview()
  }

  get l() {
    const v = this.labelsValue || {}
    return {
      invoiceHeading:        v.invoiceHeading        || "INVOICE",
      billTo:                v.billTo                || "Bill To",
      description:           v.description           || "Description",
      qty:                   v.qty                   || "Qty",
      unitPrice:             v.unitPrice             || "Unit Price",
      amount:                v.amount                || "Amount",
      subtotal:              v.subtotal              || "Subtotal",
      tax:                   v.tax                   || "Tax",
      discount:              v.discount              || "Discount",
      total:                 v.total                 || "Total",
      notes:                 v.notes                 || "Notes",
      terms:                 v.terms                 || "Terms & Conditions",
      paymentDetails:        v.paymentDetails        || "Payment Details",
      iban:                  v.iban                  || "IBAN",
      swift:                 v.swift                 || "SWIFT/BIC",
      taxId:                 v.taxId                 || "Tax ID",
      date:                  v.date                  || "Date",
      dueDate:               v.dueDate               || "Due Date",
      invoiceNumber:         v.invoiceNumber         || "Invoice #",
      noItems:               v.noItems               || "No items added yet",
      businessNameFallback:  v.businessNameFallback  || "Your Business Name",
      clientNameFallback:    v.clientNameFallback    || "Client Name",
      item:                  v.item                  || "Item",
      code:                  v.code                  || "Code",
      measure:               v.measure               || "Measure",
      price:                 v.price                 || "Price",
      withTax:               v.withTax               || "w/ Tax",
      discountShort:         v.discountShort         || "Disc.",
      grandTotal:            v.grandTotal            || "Grand Total",
      totalTax:              v.totalTax              || "Total Tax",
      totalDiscount:         v.totalDiscount         || "Total Discount"
    }
  }

  addLineItem() {
    const l = this.l
    const index = this.lineItemsTarget.querySelectorAll("[data-line-item]").length
    const row = document.createElement("div")
    row.setAttribute("data-line-item", "")
    row.className = "border border-gray-200 dark:border-gray-700 rounded-xl p-4 mb-3 bg-gray-50 dark:bg-gray-800/50"

    const ctrl = "detailed-invoice-generator-calculator"

    row.innerHTML = `
      <div class="flex items-start justify-between gap-2 mb-2">
        <div class="grid grid-cols-2 gap-2 flex-1">
          <div>
            <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.item)}</label>
            <input type="text" class="w-full text-sm" data-field="item_name" data-action="input->${ctrl}#recalculate">
          </div>
          <div>
            <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.code)}</label>
            <input type="text" placeholder="SKU-001" class="w-full text-sm placeholder-gray-200" data-field="item_code" data-action="input->${ctrl}#recalculate">
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
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.measure)}</label>
          <input type="text" placeholder="pcs, kg,..." class="w-full text-sm placeholder-gray-200" data-field="unit" data-action="input->${ctrl}#recalculate">
        </div>
        <div>
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.unitPrice)}</label>
          <input type="number" placeholder="0.00" min="0" step="0.01" class="w-full text-sm placeholder-gray-200" data-field="unit_price" data-action="input->${ctrl}#recalculate">
        </div>
        <div>
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.qty)}</label>
          <input type="number" placeholder="1" min="0" step="0.01" class="w-full text-sm placeholder-gray-200" data-field="qty" data-action="input->${ctrl}#recalculate">
        </div>
      </div>
      <div class="grid grid-cols-12 gap-2 items-end">
        <div class="col-span-4">
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.discount)}</label>
          <select class="w-full text-sm" data-field="discount_type" data-action="change->${ctrl}#recalculate">
            <option value="none">—</option>
            <option value="percent">%</option>
            <option value="flat">$</option>
          </select>
        </div>
        <div class="col-span-3">
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.discount)} ${this.escapeHtml(l.amount)}</label>
          <input type="number" placeholder="0" min="0" step="0.01" class="w-full text-sm placeholder-gray-200" data-field="discount_value" data-action="input->${ctrl}#recalculate">
        </div>
        <div class="col-span-2">
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.tax)} %</label>
          <input type="number" placeholder="0" min="0" max="100" step="0.01" class="w-full text-sm placeholder-gray-200" data-field="tax" data-action="input->${ctrl}#recalculate">
        </div>
        <div class="col-span-3 text-right">
          <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.total)}</label>
          <span class="inline-block py-2 text-sm font-bold text-gray-900 dark:text-white" data-field="line_total">0.00</span>
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
    const l = this.l
    const businessName = this.businessNameTarget.value || l.businessNameFallback
    const businessAddress = this.businessAddressTarget.value || ""
    const businessEmail = this.businessEmailTarget.value || ""
    const businessPhone = this.businessPhoneTarget.value || ""
    const businessTaxId = this.businessTaxIdTarget.value || ""
    const businessIban = this.businessIbanTarget.value || ""
    const businessSwift = this.businessSwiftTarget.value || ""

    const clientName = this.clientNameTarget.value || l.clientNameFallback
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
      <div class="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-xl p-8 shadow-sm print:shadow-none print:border-0" data-pdf-root>
        <!-- Header -->
        <div class="flex justify-between items-start mb-8">
          <div>
            <h3 class="text-xl font-bold text-gray-900 dark:text-white">${this.escapeHtml(businessName)}</h3>
            ${businessAddress ? `<p class="text-sm text-gray-500 dark:text-gray-400 whitespace-pre-line">${this.escapeHtml(businessAddress)}</p>` : ""}
            ${businessEmail ? `<p class="text-sm text-gray-500 dark:text-gray-400">${this.escapeHtml(businessEmail)}</p>` : ""}
            ${businessPhone ? `<p class="text-sm text-gray-500 dark:text-gray-400">${this.escapeHtml(businessPhone)}</p>` : ""}
            ${businessTaxId ? `<p class="text-sm text-gray-500 dark:text-gray-400">${this.escapeHtml(l.taxId)}: ${this.escapeHtml(businessTaxId)}</p>` : ""}
          </div>
          <div class="text-right">
            <h2 class="text-3xl font-extrabold text-blue-600 dark:text-blue-400 tracking-tight">${this.escapeHtml(l.invoiceHeading)}</h2>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">${this.escapeHtml(invoiceNumber)}</p>
          </div>
        </div>

        <!-- Client & Dates -->
        <div class="grid grid-cols-2 gap-8 mb-8">
          <div>
            <p class="text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-1">${this.escapeHtml(l.billTo)}</p>
            <p class="text-sm font-semibold text-gray-900 dark:text-white">${this.escapeHtml(clientName)}</p>
            ${clientAddress ? `<p class="text-sm text-gray-500 dark:text-gray-400 whitespace-pre-line">${this.escapeHtml(clientAddress)}</p>` : ""}
            ${clientEmail ? `<p class="text-sm text-gray-500 dark:text-gray-400">${this.escapeHtml(clientEmail)}</p>` : ""}
          </div>
          <div class="text-right">
            <div class="space-y-1">
              <p class="text-sm text-gray-500 dark:text-gray-400"><span class="font-semibold">${this.escapeHtml(l.date)}:</span> ${formatDate(invoiceDate)}</p>
              ${dueDate ? `<p class="text-sm text-gray-500 dark:text-gray-400"><span class="font-semibold">${this.escapeHtml(l.dueDate)}:</span> ${formatDate(dueDate)}</p>` : ""}
            </div>
          </div>
        </div>

        <!-- Line Items -->
        <div class="overflow-x-auto">
          <table class="w-full mb-6">
            <thead>
              <tr class="bg-gray-100 dark:bg-gray-800">
                <th class="py-2 px-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.item)}</th>
                <th class="py-2 px-2 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.code)}</th>
                <th class="py-2 px-2 text-center text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.measure)}</th>
                <th class="py-2 px-2 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.price)}</th>
                <th class="py-2 px-2 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.qty)}</th>
                <th class="py-2 px-2 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.tax)}</th>
                <th class="py-2 px-2 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.withTax)}</th>
                <th class="py-2 px-2 text-center text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.discountShort)}</th>
                <th class="py-2 px-2 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.total)}</th>
              </tr>
            </thead>
            <tbody>
              ${itemsHtml || `<tr><td colspan="9" class="py-4 text-center text-sm text-gray-400">${this.escapeHtml(l.noItems)}</td></tr>`}
            </tbody>
          </table>
        </div>

        <!-- Totals -->
        <div class="flex justify-end mb-8">
          <div class="w-72">
            <div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">${this.escapeHtml(l.subtotal)}</span>
              <span class="font-medium text-gray-700 dark:text-gray-300">${this.fmt(totalSubtotal)}</span>
            </div>
            ${totalTax > 0 ? `<div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">${this.escapeHtml(l.totalTax)}</span>
              <span class="font-medium text-gray-700 dark:text-gray-300">${this.fmt(totalTax)}</span>
            </div>` : ""}
            ${totalDiscount > 0 ? `<div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">${this.escapeHtml(l.totalDiscount)}</span>
              <span class="font-medium text-red-500">-${this.fmt(totalDiscount)}</span>
            </div>` : ""}
            <div class="flex justify-between py-2 border-t-2 border-gray-900 dark:border-gray-200 mt-1">
              <span class="text-base font-bold text-gray-900 dark:text-white">${this.escapeHtml(l.grandTotal)}</span>
              <span class="text-base font-bold text-gray-900 dark:text-white">${this.fmt(grandTotal)}</span>
            </div>
          </div>
        </div>

        <!-- Payment Details -->
        ${(businessIban || businessSwift) ? `
        <div class="mb-6 p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
          <p class="text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider mb-2">${this.escapeHtml(l.paymentDetails)}</p>
          ${businessIban ? `<p class="text-sm text-gray-700 dark:text-gray-300"><span class="font-semibold">${this.escapeHtml(l.iban)}:</span> ${this.escapeHtml(businessIban)}</p>` : ""}
          ${businessSwift ? `<p class="text-sm text-gray-700 dark:text-gray-300"><span class="font-semibold">${this.escapeHtml(l.swift)}:</span> ${this.escapeHtml(businessSwift)}</p>` : ""}
        </div>` : ""}

        <!-- Notes & Terms -->
        ${notes ? `
        <div class="mb-4">
          <p class="text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider mb-1">${this.escapeHtml(l.notes)}</p>
          <p class="text-sm text-gray-500 dark:text-gray-400 whitespace-pre-line">${this.escapeHtml(notes)}</p>
        </div>` : ""}
        ${terms ? `
        <div class="mb-4">
          <p class="text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase tracking-wider mb-1">${this.escapeHtml(l.terms)}</p>
          <p class="text-sm text-gray-500 dark:text-gray-400 whitespace-pre-line">${this.escapeHtml(terms)}</p>
        </div>` : ""}
      </div>
    `
  }

  async downloadPdf(event) {
    if (event) event.preventDefault()
    const trigger = event?.currentTarget
    const originalLabel = trigger?.innerHTML
    if (trigger) {
      trigger.disabled = true
      trigger.style.opacity = "0.7"
    }

    try {
      const [{ default: html2canvas }, jsPdfModule] = await Promise.all([
        import("html2canvas-pro"),
        import("jspdf")
      ])
      const { jsPDF } = jsPdfModule

      const root = this.previewTarget.querySelector("[data-pdf-root]") || this.previewTarget.firstElementChild
      if (!root) return

      const html = document.documentElement
      const wasDark = html.classList.contains("dark")
      if (wasDark) html.classList.remove("dark")

      let canvas
      try {
        canvas = await html2canvas(root, {
          scale: 2,
          backgroundColor: "#ffffff",
          useCORS: true,
          logging: false
        })
      } finally {
        if (wasDark) html.classList.add("dark")
      }

      const imgData = canvas.toDataURL("image/jpeg", 0.92)

      const pdf = new jsPDF({ orientation: "portrait", unit: "pt", format: "a4" })
      const pageWidth = pdf.internal.pageSize.getWidth()
      const pageHeight = pdf.internal.pageSize.getHeight()

      const imgWidth = pageWidth
      const imgHeight = (canvas.height * imgWidth) / canvas.width

      if (imgHeight <= pageHeight) {
        pdf.addImage(imgData, "JPEG", 0, 0, imgWidth, imgHeight)
      } else {
        let remainingHeight = imgHeight
        let position = 0
        while (remainingHeight > 0) {
          pdf.addImage(imgData, "JPEG", 0, position, imgWidth, imgHeight)
          remainingHeight -= pageHeight
          position -= pageHeight
          if (remainingHeight > 0) pdf.addPage()
        }
      }

      pdf.save(`${this.invoiceNumberTarget.value || "invoice"}.pdf`)
    } catch (err) {
      console.error("[detailed-invoice-generator] PDF generation failed", err)
    } finally {
      if (trigger) {
        trigger.disabled = false
        trigger.style.opacity = ""
        if (originalLabel) trigger.innerHTML = originalLabel
      }
    }
  }

  printInvoice() {
    window.print()
  }

  // --- Helpers ---

  fieldValue(row, fieldName) {
    const el = row.querySelector(`[data-field="${fieldName}"]`)
    return el ? el.value : ""
  }

  // Plain number formatting with an optional textual currency suffix.
  // The currency is whatever the user typed (e.g. "USD", "€", "MKD", "ден.") —
  // no Intl.NumberFormat currency style, so we avoid the hardcoded "$" that
  // would otherwise appear when no valid ISO code is supplied.
  fmt(value) {
    const n = new Intl.NumberFormat("en-US", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(value)
    const cur = this.hasCurrencyTarget ? (this.currencyTarget.value || "").trim() : ""
    return cur ? `${n} ${cur}` : n
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text == null ? "" : String(text)
    return div.innerHTML
  }
}
