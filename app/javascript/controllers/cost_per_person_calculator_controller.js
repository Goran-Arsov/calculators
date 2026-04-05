import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalCost", "people", "tipPercent", "taxPercent",
    "resultCostPerPerson", "resultGrandTotal", "resultTaxAmount",
    "resultTipAmount", "resultTipPerPerson", "resultTaxPerPerson",
    "resultBasePerPerson"
  ]

  calculate() {
    const totalCost = parseFloat(this.totalCostTarget.value) || 0
    const people = parseInt(this.peopleTarget.value) || 1
    const tipPct = parseFloat(this.tipPercentTarget.value) || 0
    const taxPct = parseFloat(this.taxPercentTarget.value) || 0

    if (totalCost <= 0 || people < 1) {
      this.clearResults()
      return
    }

    const taxAmount = totalCost * (taxPct / 100)
    const tipAmount = totalCost * (tipPct / 100)
    const grandTotal = totalCost + taxAmount + tipAmount
    const costPerPerson = grandTotal / people
    const tipPerPerson = tipAmount / people
    const taxPerPerson = taxAmount / people
    const basePerPerson = totalCost / people

    this.resultCostPerPersonTarget.textContent = this.formatCurrency(costPerPerson)
    this.resultGrandTotalTarget.textContent = this.formatCurrency(grandTotal)
    this.resultTaxAmountTarget.textContent = this.formatCurrency(taxAmount)
    this.resultTipAmountTarget.textContent = this.formatCurrency(tipAmount)
    this.resultTipPerPersonTarget.textContent = this.formatCurrency(tipPerPerson)
    this.resultTaxPerPersonTarget.textContent = this.formatCurrency(taxPerPerson)
    this.resultBasePerPersonTarget.textContent = this.formatCurrency(basePerPerson)
  }

  clearResults() {
    const targets = [
      "resultCostPerPerson", "resultGrandTotal", "resultTaxAmount",
      "resultTipAmount", "resultTipPerPerson", "resultTaxPerPerson",
      "resultBasePerPerson"
    ]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "\u2014"
      }
    })
  }

  copy() {
    const text = [
      `Cost Per Person: ${this.resultCostPerPersonTarget.textContent}`,
      `Grand Total: ${this.resultGrandTotalTarget.textContent}`,
      `Tax Amount: ${this.resultTaxAmountTarget.textContent}`,
      `Tip Amount: ${this.resultTipAmountTarget.textContent}`,
      `Tip Per Person: ${this.resultTipPerPersonTarget.textContent}`,
      `Tax Per Person: ${this.resultTaxPerPersonTarget.textContent}`,
      `Base Per Person: ${this.resultBasePerPersonTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}
