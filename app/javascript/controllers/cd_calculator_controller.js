import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "principal", "apy", "termMonths", "compounding",
    "maturityValue", "interestEarned", "effectiveApy", "termDisplay"
  ]

  static compoundingPeriods = { daily: 365, monthly: 12, quarterly: 4, annually: 1 }

  calculate() {
    const principal = parseFloat(this.principalTarget.value) || 0
    const apy = (parseFloat(this.apyTarget.value) || 0) / 100
    const termMonths = parseInt(this.termMonthsTarget.value) || 0
    const compounding = this.compoundingTarget.value || "daily"

    if (principal <= 0 || apy <= 0 || termMonths <= 0) {
      this.clearResults()
      return
    }

    const n = this.constructor.compoundingPeriods[compounding] || 365
    const t = termMonths / 12

    // Convert APY to nominal rate: r = n * ((1 + APY)^(1/n) - 1)
    const nominalRate = n * (Math.pow(1 + apy, 1 / n) - 1)
    const maturityValue = principal * Math.pow(1 + nominalRate / n, n * t)
    const interestEarned = maturityValue - principal

    const years = Math.floor(termMonths / 12)
    const months = termMonths % 12
    let termDisplay = ""
    if (years > 0) termDisplay += `${years} year${years > 1 ? "s" : ""}`
    if (years > 0 && months > 0) termDisplay += ", "
    if (months > 0) termDisplay += `${months} month${months > 1 ? "s" : ""}`

    this.maturityValueTarget.textContent = this.formatCurrency(maturityValue)
    this.interestEarnedTarget.textContent = this.formatCurrency(interestEarned)
    this.effectiveApyTarget.textContent = (apy * 100).toFixed(2) + "%"
    this.termDisplayTarget.textContent = termDisplay
  }

  clearResults() {
    this.maturityValueTarget.textContent = "$0.00"
    this.interestEarnedTarget.textContent = "$0.00"
    this.effectiveApyTarget.textContent = "0.00%"
    this.termDisplayTarget.textContent = "0"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `CD Calculator Results\nMaturity Value: ${this.maturityValueTarget.textContent}\nInterest Earned: ${this.interestEarnedTarget.textContent}\nAPY: ${this.effectiveApyTarget.textContent}\nTerm: ${this.termDisplayTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
