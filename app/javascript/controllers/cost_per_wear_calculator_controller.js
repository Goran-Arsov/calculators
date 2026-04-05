import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "itemPrice", "estimatedWears", "alternativePrice", "alternativeWears",
    "resultCostPerWear", "resultAltCostPerWear", "resultBetterValue",
    "resultSavingsPerWear", "resultBreakEvenWears",
    "altResultsPanel"
  ]

  calculate() {
    const itemPrice = parseFloat(this.itemPriceTarget.value) || 0
    const wears = parseFloat(this.estimatedWearsTarget.value) || 0
    const altPrice = parseFloat(this.alternativePriceTarget.value) || 0
    const altWears = parseFloat(this.alternativeWearsTarget.value) || 0

    if (itemPrice <= 0 || wears <= 0) {
      this.clearResults()
      return
    }

    const costPerWear = itemPrice / wears
    this.resultCostPerWearTarget.textContent = this.formatCurrency(costPerWear)

    if (altPrice > 0 && altWears > 0) {
      const altCostPerWear = altPrice / altWears
      const savingsPerWear = costPerWear - altCostPerWear
      const breakEven = Math.ceil(itemPrice / altCostPerWear)
      let betterValue = "Tie"
      if (costPerWear < altCostPerWear) betterValue = "Main item"
      else if (altCostPerWear < costPerWear) betterValue = "Alternative"

      this.resultAltCostPerWearTarget.textContent = this.formatCurrency(altCostPerWear)
      this.resultBetterValueTarget.textContent = betterValue
      this.resultSavingsPerWearTarget.textContent = this.formatCurrency(Math.abs(savingsPerWear))
      this.resultBreakEvenWearsTarget.textContent = breakEven + " wears"
      if (this.hasAltResultsPanelTarget) this.altResultsPanelTarget.classList.remove("hidden")
    } else {
      if (this.hasAltResultsPanelTarget) this.altResultsPanelTarget.classList.add("hidden")
    }
  }

  clearResults() {
    this.resultCostPerWearTarget.textContent = "\u2014"
    if (this.hasAltResultsPanelTarget) this.altResultsPanelTarget.classList.add("hidden")
  }

  copy() {
    let text = `Cost Per Wear: ${this.resultCostPerWearTarget.textContent}`
    if (this.hasAltResultsPanelTarget && !this.altResultsPanelTarget.classList.contains("hidden")) {
      text += `\nAlternative Cost Per Wear: ${this.resultAltCostPerWearTarget.textContent}`
      text += `\nBetter Value: ${this.resultBetterValueTarget.textContent}`
      text += `\nSavings Per Wear: ${this.resultSavingsPerWearTarget.textContent}`
      text += `\nBreak-Even: ${this.resultBreakEvenWearsTarget.textContent}`
    }
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}
