import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "priceA", "quantityA", "priceB", "quantityB", "unit",
    "resultUnitPriceA", "resultUnitPriceB", "resultBetterDeal",
    "resultSavingsPerUnit", "resultSavingsPercent"
  ]

  calculate() {
    const priceA = parseFloat(this.priceATarget.value) || 0
    const qtyA = parseFloat(this.quantityATarget.value) || 0
    const priceB = parseFloat(this.priceBTarget.value) || 0
    const qtyB = parseFloat(this.quantityBTarget.value) || 0
    const unit = this.unitTarget.value || "unit"

    if (priceA <= 0 || qtyA <= 0 || priceB <= 0 || qtyB <= 0) return

    const unitPriceA = priceA / qtyA
    const unitPriceB = priceB / qtyB
    const savingsPerUnit = Math.abs(unitPriceA - unitPriceB)
    const maxPrice = Math.max(unitPriceA, unitPriceB)
    const savingsPct = maxPrice > 0 ? (savingsPerUnit / maxPrice) * 100 : 0

    let betterDeal
    if (unitPriceA < unitPriceB) {
      betterDeal = "Product A is cheaper"
    } else if (unitPriceB < unitPriceA) {
      betterDeal = "Product B is cheaper"
    } else {
      betterDeal = "Same price"
    }

    this.resultUnitPriceATarget.textContent = "$" + unitPriceA.toFixed(4) + " / " + unit
    this.resultUnitPriceBTarget.textContent = "$" + unitPriceB.toFixed(4) + " / " + unit
    this.resultBetterDealTarget.textContent = betterDeal
    this.resultSavingsPerUnitTarget.textContent = "$" + savingsPerUnit.toFixed(4) + " / " + unit
    this.resultSavingsPercentTarget.textContent = savingsPct.toFixed(1) + "%"
  }

  copy() {
    const a = this.resultUnitPriceATarget.textContent
    const b = this.resultUnitPriceBTarget.textContent
    const deal = this.resultBetterDealTarget.textContent
    const savings = this.resultSavingsPerUnitTarget.textContent
    const pct = this.resultSavingsPercentTarget.textContent
    const text = `Product A: ${a}\nProduct B: ${b}\n${deal}\nSavings: ${savings} (${pct})`
    navigator.clipboard.writeText(text)
  }
}
