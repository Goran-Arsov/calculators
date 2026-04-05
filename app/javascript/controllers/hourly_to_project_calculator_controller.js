import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "hourlyRate", "estimatedHours", "expenses", "taxRate",
    "laborCost", "subtotal", "taxAmount", "projectTotal",
    "effectiveRate", "afterTaxIncome"
  ]

  calculate() {
    const hourlyRate = parseFloat(this.hourlyRateTarget.value) || 0
    const hours = parseFloat(this.estimatedHoursTarget.value) || 0
    const expenses = parseFloat(this.expensesTarget.value) || 0
    const taxRate = parseFloat(this.taxRateTarget.value) || 0

    if (hourlyRate <= 0 || hours <= 0) {
      this.clearResults()
      return
    }

    const laborCost = hourlyRate * hours
    const subtotal = laborCost + expenses
    const taxAmount = subtotal * (taxRate / 100)
    const projectTotal = subtotal + taxAmount
    const effectiveRate = projectTotal / hours
    const afterTaxIncome = laborCost - (laborCost * taxRate / 100)

    this.laborCostTarget.textContent = this.formatCurrency(laborCost)
    this.subtotalTarget.textContent = this.formatCurrency(subtotal)
    this.taxAmountTarget.textContent = this.formatCurrency(taxAmount)
    this.projectTotalTarget.textContent = this.formatCurrency(projectTotal)
    this.effectiveRateTarget.textContent = this.formatCurrency(effectiveRate)
    this.afterTaxIncomeTarget.textContent = this.formatCurrency(afterTaxIncome)
  }

  clearResults() {
    ;["laborCost", "subtotal", "taxAmount", "projectTotal", "effectiveRate", "afterTaxIncome"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Labor cost: ${this.laborCostTarget.textContent}\nExpenses: ${this.expensesTarget.value || "$0.00"}\nSubtotal: ${this.subtotalTarget.textContent}\nTax: ${this.taxAmountTarget.textContent}\nProject total: ${this.projectTotalTarget.textContent}\nEffective rate: ${this.effectiveRateTarget.textContent}/hr\nAfter-tax income: ${this.afterTaxIncomeTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}
