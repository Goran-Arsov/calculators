import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "currentSalary", "currentIndex", "targetIndex",
    "equivalentSalary", "salaryDifference", "percentageDifference",
    "purchasingPower", "costRatio"
  ]

  calculate() {
    const salary = parseFloat(this.currentSalaryTarget.value) || 0
    const currentIdx = parseFloat(this.currentIndexTarget.value) || 0
    const targetIdx = parseFloat(this.targetIndexTarget.value) || 0

    if (salary <= 0 || currentIdx <= 0 || targetIdx <= 0) {
      this.clearResults()
      return
    }

    const ratio = targetIdx / currentIdx
    const equivalentSalary = salary * ratio
    const salaryDifference = equivalentSalary - salary
    const percentageDifference = (ratio - 1) * 100
    const purchasingPower = salary / ratio

    this.equivalentSalaryTarget.textContent = this.formatCurrency(equivalentSalary)
    this.salaryDifferenceTarget.textContent = (salaryDifference >= 0 ? "+" : "") + this.formatCurrency(salaryDifference)
    this.percentageDifferenceTarget.textContent = (percentageDifference >= 0 ? "+" : "") + this.formatNumber(percentageDifference) + "%"
    this.purchasingPowerTarget.textContent = this.formatCurrency(purchasingPower)
    this.costRatioTarget.textContent = this.formatNumber(ratio)
  }

  clearResults() {
    ;["equivalentSalary", "salaryDifference", "percentageDifference", "purchasingPower", "costRatio"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Equivalent salary: ${this.equivalentSalaryTarget.textContent}\nSalary difference: ${this.salaryDifferenceTarget.textContent}\nPercentage difference: ${this.percentageDifferenceTarget.textContent}\nPurchasing power: ${this.purchasingPowerTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  formatNumber(value) {
    return Number(value).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
