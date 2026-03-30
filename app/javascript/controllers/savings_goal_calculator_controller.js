import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["goal", "years", "rate", "currentSavings", "monthlySavings", "totalContributions", "totalInterest"]

  calculate() {
    const goal = parseFloat(this.goalTarget.value) || 0
    const years = parseInt(this.yearsTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100
    const currentSavings = parseFloat(this.currentSavingsTarget.value) || 0

    if (goal <= 0 || years <= 0 || annualRate < 0) {
      this.clearResults()
      return
    }

    const monthlyRate = annualRate / 12
    const numMonths = years * 12
    let monthlySavings

    if (monthlyRate === 0) {
      monthlySavings = (goal - currentSavings) / numMonths
    } else {
      const futureCurrent = currentSavings * Math.pow(1 + monthlyRate, numMonths)
      const remaining = goal - futureCurrent
      monthlySavings = remaining * monthlyRate / (Math.pow(1 + monthlyRate, numMonths) - 1)
    }

    monthlySavings = Math.max(monthlySavings, 0)
    const totalContributions = monthlySavings * numMonths + currentSavings
    const totalInterest = goal - totalContributions

    this.monthlySavingsTarget.textContent = this.formatCurrency(monthlySavings)
    this.totalContributionsTarget.textContent = this.formatCurrency(totalContributions)
    this.totalInterestTarget.textContent = this.formatCurrency(totalInterest)
  }

  clearResults() {
    this.monthlySavingsTarget.textContent = "$0.00"
    this.totalContributionsTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Monthly Savings Needed: ${this.monthlySavingsTarget.textContent}\nTotal Contributions: ${this.totalContributionsTarget.textContent}\nTotal Interest Earned: ${this.totalInterestTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
