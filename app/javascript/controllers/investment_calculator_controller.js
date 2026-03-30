import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initial", "monthly", "rate", "years", "futureValue", "totalContributions", "totalGrowth"]

  calculate() {
    const initial = parseFloat(this.initialTarget.value) || 0
    const monthly = parseFloat(this.monthlyTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100
    const years = parseInt(this.yearsTarget.value) || 0

    if (years <= 0 || annualRate < 0 || (initial <= 0 && monthly <= 0)) {
      this.clearResults()
      return
    }

    const monthlyRate = annualRate / 12
    const numMonths = years * 12
    let futureValue

    if (monthlyRate === 0) {
      futureValue = initial + monthly * numMonths
    } else {
      futureValue = initial * Math.pow(1 + monthlyRate, numMonths) +
                    monthly * (Math.pow(1 + monthlyRate, numMonths) - 1) / monthlyRate
    }

    const totalContributions = initial + monthly * numMonths
    const totalGrowth = futureValue - totalContributions

    this.futureValueTarget.textContent = this.formatCurrency(futureValue)
    this.totalContributionsTarget.textContent = this.formatCurrency(totalContributions)
    this.totalGrowthTarget.textContent = this.formatCurrency(totalGrowth)
  }

  clearResults() {
    this.futureValueTarget.textContent = "$0.00"
    this.totalContributionsTarget.textContent = "$0.00"
    this.totalGrowthTarget.textContent = "$0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Future Value: ${this.futureValueTarget.textContent}\nTotal Contributions: ${this.totalContributionsTarget.textContent}\nTotal Growth: ${this.totalGrowthTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
