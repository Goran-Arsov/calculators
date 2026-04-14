import { Controller } from "@hotwired/stimulus"
import { formatCurrency, formatNumber } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "annualExpenses", "annualSavings", "currentPortfolio",
    "expectedReturnRate", "safeWithdrawalRate",
    "fireNumber", "yearsToFire", "monthlySavingsNeeded", "projectedPortfolio"
  ]

  connect() {
    prefillFromUrl(this, {
      expenses: "annualExpenses",
      savings: "annualSavings",
      portfolio: "currentPortfolio",
      return_rate: "expectedReturnRate",
      swr: "safeWithdrawalRate"
    })
    this.calculate()
  }

  calculate() {
    const annualExpenses = parseFloat(this.annualExpensesTarget.value) || 0
    const annualSavings = parseFloat(this.annualSavingsTarget.value) || 0
    const currentPortfolio = parseFloat(this.currentPortfolioTarget.value) || 0
    const expectedReturn = parseFloat(this.expectedReturnRateTarget.value) / 100
    const swr = parseFloat(this.safeWithdrawalRateTarget.value) / 100

    if (annualExpenses <= 0 || swr <= 0 || expectedReturn < 0) {
      this.clearResults()
      return
    }

    const fireNumber = annualExpenses / swr

    let yearsToFire = 0
    let projectedPortfolio = currentPortfolio

    if (currentPortfolio < fireNumber) {
      if (expectedReturn === 0) {
        if (annualSavings > 0) {
          yearsToFire = Math.ceil((fireNumber - currentPortfolio) / annualSavings)
        }
      } else {
        const r = expectedReturn
        const numerator = fireNumber + annualSavings / r
        const denominator = currentPortfolio + annualSavings / r

        if (denominator > 0 && numerator > denominator) {
          yearsToFire = Math.ceil(Math.log(numerator / denominator) / Math.log(1 + r))
        }
      }
      projectedPortfolio = fireNumber
    }

    let monthlySavingsNeeded = 0
    if (yearsToFire > 0) {
      const monthlyRate = expectedReturn / 12
      const numMonths = yearsToFire * 12

      if (monthlyRate === 0) {
        monthlySavingsNeeded = (fireNumber - currentPortfolio) / numMonths
      } else {
        const fvCurrent = currentPortfolio * Math.pow(1 + monthlyRate, numMonths)
        const remaining = fireNumber - fvCurrent
        const annuityFactor = (Math.pow(1 + monthlyRate, numMonths) - 1) / monthlyRate
        monthlySavingsNeeded = remaining / annuityFactor
      }
    }

    this.fireNumberTarget.textContent = formatCurrency(fireNumber)
    this.yearsToFireTarget.textContent = yearsToFire
    this.monthlySavingsNeededTarget.textContent = formatCurrency(Math.max(0, monthlySavingsNeeded))
    this.projectedPortfolioTarget.textContent = formatCurrency(projectedPortfolio)
  }

  clearResults() {
    this.fireNumberTarget.textContent = "$0.00"
    this.yearsToFireTarget.textContent = "0"
    this.monthlySavingsNeededTarget.textContent = "$0.00"
    this.projectedPortfolioTarget.textContent = "$0.00"
  }

  copy(event) {
    const text = `FIRE Number: ${this.fireNumberTarget.textContent}\nYears to FIRE: ${this.yearsToFireTarget.textContent}\nMonthly Savings Needed: ${this.monthlySavingsNeededTarget.textContent}\nProjected Portfolio at FIRE: ${this.projectedPortfolioTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
