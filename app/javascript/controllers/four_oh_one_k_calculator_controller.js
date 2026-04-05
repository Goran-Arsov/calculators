import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "currentBalance", "annualContribution", "employerMatchPercent",
    "employerMatchLimit", "annualReturn", "yearsToRetirement",
    "futureValue", "totalContributions", "totalEmployerMatch",
    "totalGrowth", "employerAnnualMatch"
  ]

  calculate() {
    const currentBalance = parseFloat(this.currentBalanceTarget.value) || 0
    const annualContribution = parseFloat(this.annualContributionTarget.value) || 0
    const employerMatchPercent = (parseFloat(this.employerMatchPercentTarget.value) || 0) / 100
    const employerMatchLimit = (parseFloat(this.employerMatchLimitTarget.value) || 0) / 100
    const annualReturn = (parseFloat(this.annualReturnTarget.value) || 0) / 100
    const years = parseInt(this.yearsToRetirementTarget.value) || 0

    if (annualContribution <= 0 || years <= 0) {
      this.clearResults()
      return
    }

    let employerAnnualMatch = 0
    if (employerMatchPercent > 0 && employerMatchLimit > 0) {
      employerAnnualMatch = Math.min(
        annualContribution * employerMatchPercent,
        annualContribution * employerMatchLimit
      )
    }

    const totalAnnualAddition = annualContribution + employerAnnualMatch
    let balance = currentBalance
    let totalContributions = 0
    let totalEmployerMatch = 0

    for (let i = 0; i < years; i++) {
      const growth = balance * annualReturn
      balance += growth + totalAnnualAddition
      totalContributions += annualContribution
      totalEmployerMatch += employerAnnualMatch
    }

    const totalGrowth = balance - currentBalance - totalContributions - totalEmployerMatch

    this.futureValueTarget.textContent = this.formatCurrency(balance)
    this.totalContributionsTarget.textContent = this.formatCurrency(totalContributions)
    this.totalEmployerMatchTarget.textContent = this.formatCurrency(totalEmployerMatch)
    this.totalGrowthTarget.textContent = this.formatCurrency(totalGrowth)
    this.employerAnnualMatchTarget.textContent = this.formatCurrency(employerAnnualMatch)
  }

  clearResults() {
    this.futureValueTarget.textContent = "$0.00"
    this.totalContributionsTarget.textContent = "$0.00"
    this.totalEmployerMatchTarget.textContent = "$0.00"
    this.totalGrowthTarget.textContent = "$0.00"
    this.employerAnnualMatchTarget.textContent = "$0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `401(k) Calculator Results\nFuture Value: ${this.futureValueTarget.textContent}\nTotal Contributions: ${this.totalContributionsTarget.textContent}\nTotal Employer Match: ${this.totalEmployerMatchTarget.textContent}\nTotal Growth: ${this.totalGrowthTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
