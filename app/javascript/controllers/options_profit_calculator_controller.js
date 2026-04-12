import { Controller } from "@hotwired/stimulus"
import { formatCurrency, formatPercent } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "optionType", "strikePrice", "premium", "underlyingPrice", "contracts",
    "totalProfit", "profitPerShare", "breakEven", "roi", "maxLoss",
    "maxProfit", "totalPremium", "moneyStatus"
  ]

  connect() {
    if (prefillFromUrl(this, {
      strikePrice: "strikePrice", premium: "premium",
      underlyingPrice: "underlyingPrice", contracts: "contracts"
    })) {
      this.calculate()
    }
  }

  calculate() {
    const optionType = this.optionTypeTarget.value || "call"
    const strike = parseFloat(this.strikePriceTarget.value) || 0
    const premium = parseFloat(this.premiumTarget.value) || 0
    const underlying = parseFloat(this.underlyingPriceTarget.value) || 0
    const contracts = parseInt(this.contractsTarget.value) || 0

    if (strike <= 0 || premium <= 0 || underlying <= 0 || contracts <= 0) {
      this.clearResults()
      return
    }

    const sharesPerContract = 100
    const totalShares = contracts * sharesPerContract
    const totalPremiumPaid = premium * totalShares

    let intrinsicValue, breakEven
    if (optionType === "call") {
      intrinsicValue = Math.max(underlying - strike, 0)
      breakEven = strike + premium
    } else {
      intrinsicValue = Math.max(strike - underlying, 0)
      breakEven = strike - premium
    }

    const profitPerShare = intrinsicValue - premium
    const totalProfit = profitPerShare * totalShares
    const roi = totalPremiumPaid > 0 ? (totalProfit / totalPremiumPaid) * 100 : 0
    const maxLoss = totalPremiumPaid

    let maxProfit
    if (optionType === "call") {
      maxProfit = "Unlimited"
    } else {
      maxProfit = formatCurrency(Math.max((strike - premium) * totalShares, 0))
    }

    this.totalProfitTarget.textContent = formatCurrency(totalProfit)
    this.profitPerShareTarget.textContent = formatCurrency(profitPerShare)
    this.breakEvenTarget.textContent = formatCurrency(breakEven)
    this.roiTarget.textContent = formatPercent(roi)
    this.maxLossTarget.textContent = formatCurrency(maxLoss)
    this.maxProfitTarget.textContent = maxProfit
    this.totalPremiumTarget.textContent = formatCurrency(totalPremiumPaid)

    if (intrinsicValue > 0) {
      this.moneyStatusTarget.textContent = "In the Money"
      this.moneyStatusTarget.classList.remove("text-red-600")
      this.moneyStatusTarget.classList.add("text-green-600")
    } else {
      this.moneyStatusTarget.textContent = "Out of the Money"
      this.moneyStatusTarget.classList.remove("text-green-600")
      this.moneyStatusTarget.classList.add("text-red-600")
    }
  }

  clearResults() {
    this.totalProfitTarget.textContent = "$0.00"
    this.profitPerShareTarget.textContent = "$0.00"
    this.breakEvenTarget.textContent = "$0.00"
    this.roiTarget.textContent = "0.00%"
    this.maxLossTarget.textContent = "$0.00"
    this.maxProfitTarget.textContent = "--"
    this.totalPremiumTarget.textContent = "$0.00"
    this.moneyStatusTarget.textContent = "--"
  }

  copy(event) {
    const text = `Total P/L: ${this.totalProfitTarget.textContent}\nBreak-Even: ${this.breakEvenTarget.textContent}\nROI: ${this.roiTarget.textContent}\nMax Loss: ${this.maxLossTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
