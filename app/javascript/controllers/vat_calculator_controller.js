import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "amount", "vatRate", "mode",
    "netPrice", "vatAmount", "grossPrice"
  ]

  connect() {
    if (prefillFromUrl(this, { amount: "amount", vatRate: "vatRate" })) {
      this.calculate()
    }
  }

  calculate() {
    const amount = parseFloat(this.amountTarget.value) || 0
    const vatRate = parseFloat(this.vatRateTarget.value) / 100 || 0
    const mode = this.modeTarget.value || "add"

    if (amount <= 0) {
      this.clearResults()
      return
    }

    let netPrice, vatAmount, grossPrice

    if (mode === "add") {
      netPrice = amount
      vatAmount = netPrice * vatRate
      grossPrice = netPrice + vatAmount
    } else {
      grossPrice = amount
      netPrice = grossPrice / (1 + vatRate)
      vatAmount = grossPrice - netPrice
    }

    this.netPriceTarget.textContent = formatCurrency(netPrice)
    this.vatAmountTarget.textContent = formatCurrency(vatAmount)
    this.grossPriceTarget.textContent = formatCurrency(grossPrice)
  }

  clearResults() {
    this.netPriceTarget.textContent = "$0.00"
    this.vatAmountTarget.textContent = "$0.00"
    this.grossPriceTarget.textContent = "$0.00"
  }

  copy(event) {
    const text = `Net Price: ${this.netPriceTarget.textContent}\nVAT Amount: ${this.vatAmountTarget.textContent}\nGross Price: ${this.grossPriceTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
