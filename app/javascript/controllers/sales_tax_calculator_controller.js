import { Controller } from "@hotwired/stimulus"
import { formatCurrency, formatPercent } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "subtotal", "taxRate",
    "taxAmount", "total"
  ]

  connect() {
    prefillFromUrl(this, { subtotal: "subtotal", taxRate: "taxRate" })
    this.calculate()
  }

  calculate() {
    const subtotal = parseFloat(this.subtotalTarget.value) || 0
    const taxRate = parseFloat(this.taxRateTarget.value) / 100 || 0

    if (subtotal <= 0) {
      this.clearResults()
      return
    }

    const taxAmount = subtotal * taxRate
    const total = subtotal + taxAmount

    this.taxAmountTarget.textContent = formatCurrency(taxAmount)
    this.totalTarget.textContent = formatCurrency(total)
  }

  clearResults() {
    this.taxAmountTarget.textContent = "$0.00"
    this.totalTarget.textContent = "$0.00"
  }

  copy(event) {
    const text = `Subtotal: ${formatCurrency(parseFloat(this.subtotalTarget.value) || 0)}\nTax Amount: ${this.taxAmountTarget.textContent}\nTotal: ${this.totalTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
