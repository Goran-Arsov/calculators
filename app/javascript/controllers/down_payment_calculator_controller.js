import { Controller } from "@hotwired/stimulus"
import { formatCurrency, formatNumber } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "homePrice", "downPaymentPercent", "currentSavings", "monthlySavings", "annualReturnRate",
    "downPaymentTarget", "savingsGap", "monthsToSave", "yearsToSave", "totalWithInterest"
  ]

  connect() {
    prefillFromUrl(this, {
      price: "homePrice",
      percent: "downPaymentPercent",
      savings: "currentSavings",
      monthly: "monthlySavings",
      return_rate: "annualReturnRate"
    })
    this.calculate()
  }

  calculate() {
    const homePrice = parseFloat(this.homePriceTarget.value) || 0
    const downPct = parseFloat(this.downPaymentPercentTarget.value) || 0
    const currentSavings = parseFloat(this.currentSavingsTarget.value) || 0
    const monthlySavings = parseFloat(this.monthlySavingsTarget.value) || 0
    const annualReturn = parseFloat(this.annualReturnRateTarget.value) / 100

    if (homePrice <= 0 || downPct <= 0 || monthlySavings <= 0 || annualReturn < 0) {
      this.clearResults()
      return
    }

    const target = homePrice * (downPct / 100)
    const gap = target - currentSavings

    if (gap <= 0) {
      this.downPaymentTargetTarget.textContent = formatCurrency(target)
      this.savingsGapTarget.textContent = "$0.00"
      this.monthsToSaveTarget.textContent = "0"
      this.yearsToSaveTarget.textContent = "0.0"
      this.totalWithInterestTarget.textContent = formatCurrency(currentSavings)
      return
    }

    const monthlyRate = annualReturn / 12
    let monthsToSave

    if (monthlyRate === 0) {
      monthsToSave = Math.ceil(gap / monthlySavings)
    } else {
      const numerator = target + monthlySavings / monthlyRate
      const denominator = currentSavings + monthlySavings / monthlyRate

      if (denominator <= 0 || numerator <= denominator) {
        this.clearResults()
        return
      }

      monthsToSave = Math.ceil(Math.log(numerator / denominator) / Math.log(1 + monthlyRate))
    }

    const yearsToSave = (monthsToSave / 12).toFixed(1)

    let totalWithInterest
    if (monthlyRate === 0) {
      totalWithInterest = currentSavings + monthlySavings * monthsToSave
    } else {
      totalWithInterest = currentSavings * Math.pow(1 + monthlyRate, monthsToSave) +
        monthlySavings * (Math.pow(1 + monthlyRate, monthsToSave) - 1) / monthlyRate
    }

    this.downPaymentTargetTarget.textContent = formatCurrency(target)
    this.savingsGapTarget.textContent = formatCurrency(gap)
    this.monthsToSaveTarget.textContent = monthsToSave
    this.yearsToSaveTarget.textContent = yearsToSave
    this.totalWithInterestTarget.textContent = formatCurrency(totalWithInterest)
  }

  clearResults() {
    this.downPaymentTargetTarget.textContent = "$0.00"
    this.savingsGapTarget.textContent = "$0.00"
    this.monthsToSaveTarget.textContent = "0"
    this.yearsToSaveTarget.textContent = "0.0"
    this.totalWithInterestTarget.textContent = "$0.00"
  }

  copy(event) {
    const text = `Down Payment Target: ${this.downPaymentTargetTarget.textContent}\nSavings Gap: ${this.savingsGapTarget.textContent}\nMonths to Save: ${this.monthsToSaveTarget.textContent}\nYears to Save: ${this.yearsToSaveTarget.textContent}\nTotal with Interest: ${this.totalWithInterestTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
