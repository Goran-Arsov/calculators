import { Controller } from "@hotwired/stimulus"
import { toRealValue, applyInflationToggle } from "utils/inflation"

export default class extends Controller {
  static targets = [
    "initialBalance", "monthlyDeposit", "annualRate", "years",
    "futureValue", "totalDeposits", "totalInterest", "totalContributions",
    "inflationEnabled", "inflationField", "inflationRate",
    "realResults", "realFutureValue", "realTotalInterest"
  ]

  calculate() {
    const initialBalance = parseFloat(this.initialBalanceTarget.value) || 0
    const monthlyDeposit = parseFloat(this.monthlyDepositTarget.value) || 0
    const annualRate = (parseFloat(this.annualRateTarget.value) || 0) / 100
    const years = parseInt(this.yearsTarget.value) || 0

    if ((initialBalance <= 0 && monthlyDeposit <= 0) || years <= 0) {
      this.clearResults()
      return
    }

    const monthlyRate = annualRate / 12
    const totalMonths = years * 12

    let fvInitial, fvDeposits
    if (monthlyRate === 0) {
      fvInitial = initialBalance
      fvDeposits = monthlyDeposit * totalMonths
    } else {
      fvInitial = initialBalance * Math.pow(1 + monthlyRate, totalMonths)
      fvDeposits = monthlyDeposit * ((Math.pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate)
    }

    const futureValue = fvInitial + fvDeposits
    const totalDeposits = monthlyDeposit * totalMonths
    const totalContributions = initialBalance + totalDeposits
    const totalInterest = futureValue - totalContributions

    this.futureValueTarget.textContent = this.formatCurrency(futureValue)
    this.totalDepositsTarget.textContent = this.formatCurrency(totalDeposits)
    this.totalInterestTarget.textContent = this.formatCurrency(totalInterest)
    this.totalContributionsTarget.textContent = this.formatCurrency(totalContributions)

    const { enabled, rate } = applyInflationToggle(this)
    if (enabled) {
      if (this.hasRealFutureValueTarget) this.realFutureValueTarget.textContent = this.formatCurrency(toRealValue(futureValue, rate, years))
      if (this.hasRealTotalInterestTarget) this.realTotalInterestTarget.textContent = this.formatCurrency(toRealValue(totalInterest, rate, years))
    }
  }

  clearResults() {
    this.futureValueTarget.textContent = "$0.00"
    this.totalDepositsTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
    this.totalContributionsTarget.textContent = "$0.00"
    if (this.hasRealFutureValueTarget) this.realFutureValueTarget.textContent = "$0.00"
    if (this.hasRealTotalInterestTarget) this.realTotalInterestTarget.textContent = "$0.00"
    applyInflationToggle(this)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Savings Interest Calculator Results\nFuture Value: ${this.futureValueTarget.textContent}\nTotal Deposits: ${this.totalDepositsTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}\nTotal Contributions: ${this.totalContributionsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
