import { Controller } from "@hotwired/stimulus"

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

  // Localized strings with English fallbacks so the JS works even when the
  // view forgets to pass the labels value.
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
      clientNameFallback:    v.clientNameFallback    || "Client Name"
    }
  }

  addLineItem() {
    const l = this.l
    const index = this.lineItemsTarget.querySelectorAll("[data-line-item]").length
    const row = document.createElement("div")
    row.setAttribute("data-line-item", "")
    row.className = "grid grid-cols-12 gap-2 items-end mb-2"
    row.innerHTML = `
      <div class="col-span-5">
        ${index === 0 ? `<label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.description)}</label>` : ""}
        <input type="text" class="w-full text-sm" data-action="input->invoice-generator-calculator#recalculate">
      </div>
      <div class="col-span-2">
        ${index === 0 ? `<label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.qty)}</label>` : ""}
        <input type="number" placeholder="1" min="0" step="0.01" class="w-full text-sm" data-action="input->invoice-generator-calculator#recalculate">
      </div>
      <div class="col-span-2">
        ${index === 0 ? `<label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.unitPrice)}</label>` : ""}
        <input type="number" placeholder="0.00" min="0" step="0.01" class="w-full text-sm" data-action="input->invoice-generator-calculator#recalculate">
      </div>
      <div class="col-span-2 text-right">
        ${index === 0 ? `<label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1">${this.escapeHtml(l.amount)}</label>` : ""}
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
        <table class="w-full mb-6">
          <thead>
            <tr class="bg-gray-100 dark:bg-gray-800">
              <th class="py-2 px-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.description)}</th>
              <th class="py-2 px-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.qty)}</th>
              <th class="py-2 px-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.unitPrice)}</th>
              <th class="py-2 px-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">${this.escapeHtml(l.amount)}</th>
            </tr>
          </thead>
          <tbody>
            ${itemsHtml || `<tr><td colspan="4" class="py-4 text-center text-sm text-gray-400">${this.escapeHtml(l.noItems)}</td></tr>`}
          </tbody>
        </table>

        <!-- Totals -->
        <div class="flex justify-end mb-8">
          <div class="w-64">
            <div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">${this.escapeHtml(l.subtotal)}</span>
              <span class="font-medium text-gray-700 dark:text-gray-300">${this.fmt(subtotal)}</span>
            </div>
            ${taxRate > 0 ? `<div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">${this.escapeHtml(l.tax)} (${taxRate}%)</span>
              <span class="font-medium text-gray-700 dark:text-gray-300">${this.fmt(taxAmount)}</span>
            </div>` : ""}
            ${discountVal > 0 ? `<div class="flex justify-between py-1.5 text-sm">
              <span class="text-gray-500 dark:text-gray-400">${this.escapeHtml(l.discount)}${discountType === "flat" ? "" : ` (${discountVal}%)`}</span>
              <span class="font-medium text-red-500">-${this.fmt(discountAmount)}</span>
            </div>` : ""}
            <div class="flex justify-between py-2 border-t-2 border-gray-900 dark:border-gray-200 mt-1">
              <span class="text-base font-bold text-gray-900 dark:text-white">${this.escapeHtml(l.total)}</span>
              <span class="text-base font-bold text-gray-900 dark:text-white">${this.fmt(total)}</span>
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
      // Rasterize the DOM preview. This side-steps the base-PDF-font limitation
      // that produced mojibake for Cyrillic / any non-WinAnsi script, because
      // the browser already renders Unicode correctly in the preview.
      const [{ default: html2canvas }, jsPdfModule] = await Promise.all([
        import("html2canvas-pro"),
        import("jspdf")
      ])
      const { jsPDF } = jsPdfModule

      const root = this.previewTarget.querySelector("[data-pdf-root]") || this.previewTarget.firstElementChild
      if (!root) return

      // Render light-mode by temporarily dropping the `dark` class from the
      // html element. The PDF should look consistent regardless of the user's
      // active theme.
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
        // Multi-page: slice the tall image vertically.
        let remainingHeight = imgHeight
        let position = 0
        while (remainingHeight > 0) {
          pdf.addImage(imgData, "JPEG", 0, position, imgWidth, imgHeight)
          remainingHeight -= pageHeight
          position -= pageHeight
          if (remainingHeight > 0) pdf.addPage()
        }
      }

      const filename = `${this.invoiceNumberTarget.value || "invoice"}.pdf`
      pdf.save(filename)
    } catch (err) {
      console.error("[invoice-generator] PDF generation failed", err)
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

  fmt(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text == null ? "" : String(text)
    return div.innerHTML
  }
}
