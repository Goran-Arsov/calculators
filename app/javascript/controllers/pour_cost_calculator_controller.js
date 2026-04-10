import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "bottleCost", "bottleMl", "pourOz", "salePrice", "targetPct",
    "resultCostPour", "resultPourCostPct", "resultProfitPour",
    "resultMargin", "resultPoursPerBottle", "resultSuggested",
    "resultProfitBottle", "resultRating"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const bottleCost = parseFloat(this.bottleCostTarget.value) || 0
    const bottleMl = parseFloat(this.bottleMlTarget.value) || 0
    const pourOz = parseFloat(this.pourOzTarget.value) || 0
    const salePrice = parseFloat(this.salePriceTarget.value) || 0
    const targetPct = parseFloat(this.targetPctTarget.value) || 20

    const bottleOz = bottleMl / 29.5735

    if (bottleCost <= 0 || bottleMl <= 0 || pourOz <= 0 || salePrice <= 0 || pourOz > bottleOz) {
      this.clearResults()
      return
    }

    const poursPerBottle = bottleOz / pourOz
    const costPerOz = bottleCost / bottleOz
    const costPerPour = costPerOz * pourOz
    const pourCostPct = (costPerPour / salePrice) * 100
    const profitPerPour = salePrice - costPerPour
    const grossMarginPct = (profitPerPour / salePrice) * 100
    const suggested = costPerPour / (targetPct / 100)
    const profitPerBottle = profitPerPour * poursPerBottle

    this.resultCostPourTarget.textContent = "$" + costPerPour.toFixed(2)
    this.resultPourCostPctTarget.textContent = pourCostPct.toFixed(1) + "%"
    this.resultProfitPourTarget.textContent = "$" + profitPerPour.toFixed(2)
    this.resultMarginTarget.textContent = grossMarginPct.toFixed(1) + "%"
    this.resultPoursPerBottleTarget.textContent = poursPerBottle.toFixed(1)
    this.resultSuggestedTarget.textContent = "$" + suggested.toFixed(2)
    this.resultProfitBottleTarget.textContent = "$" + profitPerBottle.toFixed(2)
    this.resultRatingTarget.textContent = this.rating(pourCostPct)
  }

  rating(pct) {
    if (pct < 15) return "Excellent (under industry average)"
    if (pct < 20) return "Very good (premium bar territory)"
    if (pct < 25) return "Good (industry standard)"
    if (pct < 30) return "Below average (review pricing)"
    return "Poor (raise price or cut cost)"
  }

  clearResults() {
    this.resultCostPourTarget.textContent = "—"
    this.resultPourCostPctTarget.textContent = "—"
    this.resultProfitPourTarget.textContent = "—"
    this.resultMarginTarget.textContent = "—"
    this.resultPoursPerBottleTarget.textContent = "—"
    this.resultSuggestedTarget.textContent = "—"
    this.resultProfitBottleTarget.textContent = "—"
    this.resultRatingTarget.textContent = "—"
  }

  copy() {
    const text = `Pour Cost Analysis:\nCost per Pour: ${this.resultCostPourTarget.textContent}\nPour Cost %: ${this.resultPourCostPctTarget.textContent}\nProfit per Pour: ${this.resultProfitPourTarget.textContent}\nGross Margin: ${this.resultMarginTarget.textContent}\nPours per Bottle: ${this.resultPoursPerBottleTarget.textContent}\nSuggested Sale Price: ${this.resultSuggestedTarget.textContent}\nProfit per Bottle: ${this.resultProfitBottleTarget.textContent}\nRating: ${this.resultRatingTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
