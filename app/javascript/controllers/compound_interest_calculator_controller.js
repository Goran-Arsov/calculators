import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"
import { toRealValue, applyInflationToggle } from "utils/inflation"

export default class extends Controller {
  static targets = [
    "principal", "rate", "years", "frequency",
    "futureValue", "totalInterest", "principalDisplay",
    "inflationEnabled", "inflationField", "inflationRate",
    "realResults", "realFutureValue", "realTotalInterest"
  ]

  connect() {
    prefillFromUrl(this, { principal: "principal", rate: "rate", years: "years", frequency: "frequency" })
    this.calculate()
  }

  calculate() {
    const principal = parseFloat(this.principalTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100
    const years = parseInt(this.yearsTarget.value) || 0
    const n = parseInt(this.frequencyTarget.value) || 12

    if (principal <= 0 || years <= 0 || annualRate < 0) {
      this.clearResults()
      return
    }

    const futureValue = principal * Math.pow(1 + annualRate / n, n * years)
    const totalInterest = futureValue - principal

    this.futureValueTarget.textContent = formatCurrency(futureValue)
    this.totalInterestTarget.textContent = formatCurrency(totalInterest)
    this.principalDisplayTarget.textContent = formatCurrency(principal)

    const { enabled, rate } = applyInflationToggle(this)
    if (enabled) {
      if (this.hasRealFutureValueTarget) this.realFutureValueTarget.textContent = formatCurrency(toRealValue(futureValue, rate, years))
      if (this.hasRealTotalInterestTarget) this.realTotalInterestTarget.textContent = formatCurrency(toRealValue(totalInterest, rate, years))
    }
  }

  clearResults() {
    this.futureValueTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
    this.principalDisplayTarget.textContent = "$0.00"
    if (this.hasRealFutureValueTarget) this.realFutureValueTarget.textContent = "$0.00"
    if (this.hasRealTotalInterestTarget) this.realTotalInterestTarget.textContent = "$0.00"
    applyInflationToggle(this)
  }

  copy(event) {
    const text = `Future Value: ${this.futureValueTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}\nPrincipal: ${this.principalDisplayTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
