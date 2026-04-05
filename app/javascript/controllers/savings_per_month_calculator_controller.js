import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "savingsGoal", "months", "currentSavings", "annualRate",
    "resultMonthly", "resultRemaining", "resultContributions", "resultInterest"
  ]

  calculate() {
    const savingsGoal = parseFloat(this.savingsGoalTarget.value) || 0
    const months = parseInt(this.monthsTarget.value) || 0
    const currentSavings = this.hasCurrentSavingsTarget ? (parseFloat(this.currentSavingsTarget.value) || 0) : 0
    const annualRate = this.hasAnnualRateTarget ? (parseFloat(this.annualRateTarget.value) || 0) : 0

    if (savingsGoal <= 0 || months <= 0 || currentSavings >= savingsGoal) {
      this.clearResults()
      return
    }

    const remaining = savingsGoal - currentSavings
    this.resultRemainingTarget.textContent = "$" + this.formatCurrency(remaining)

    if (annualRate > 0) {
      const monthlyRate = annualRate / 100 / 12
      const fvCurrent = currentSavings * Math.pow(1 + monthlyRate, months)
      const amountNeeded = savingsGoal - fvCurrent

      let monthlySavings = 0
      if (amountNeeded > 0) {
        monthlySavings = amountNeeded * monthlyRate / (Math.pow(1 + monthlyRate, months) - 1)
      }

      const totalContributions = monthlySavings * months
      const totalInterest = savingsGoal - currentSavings - totalContributions

      this.resultMonthlyTarget.textContent = "$" + this.formatCurrency(monthlySavings)
      this.resultContributionsTarget.textContent = "$" + this.formatCurrency(totalContributions)
      this.resultInterestTarget.textContent = "$" + this.formatCurrency(totalInterest)
    } else {
      const monthlySavings = remaining / months
      this.resultMonthlyTarget.textContent = "$" + this.formatCurrency(monthlySavings)
      this.resultContributionsTarget.textContent = "$" + this.formatCurrency(remaining)
      this.resultInterestTarget.textContent = "$0.00"
    }
  }

  clearResults() {
    this.resultMonthlyTarget.textContent = "\u2014"
    this.resultRemainingTarget.textContent = "\u2014"
    this.resultContributionsTarget.textContent = "\u2014"
    this.resultInterestTarget.textContent = "\u2014"
  }

  formatCurrency(n) {
    return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const monthly = this.resultMonthlyTarget.textContent
    const remaining = this.resultRemainingTarget.textContent
    const contributions = this.resultContributionsTarget.textContent
    const interest = this.resultInterestTarget.textContent
    const text = `Monthly Savings Needed: ${monthly}\nRemaining to Save: ${remaining}\nTotal Contributions: ${contributions}\nTotal Interest Earned: ${interest}`
    navigator.clipboard.writeText(text)
  }
}
