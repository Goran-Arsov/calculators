import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalDoughWeight", "targetHydration", "starterPercentage", "starterHydration", "saltPercentage",
    "results", "totalFlour", "totalWater", "starterAmount", "starterFlour", "starterWater",
    "addedFlour", "addedWater", "salt"
  ]

  calculate() {
    const totalDoughWeight = parseFloat(this.totalDoughWeightTarget.value) || 0
    const targetHydration = (parseFloat(this.targetHydrationTarget.value) || 0) / 100
    const starterPct = (parseFloat(this.starterPercentageTarget.value) || 0) / 100
    const starterHydration = (parseFloat(this.starterHydrationTarget.value) || 100) / 100
    const saltPct = (parseFloat(this.saltPercentageTarget.value) || 2) / 100

    if (totalDoughWeight <= 0 || targetHydration <= 0 || starterPct <= 0 || starterHydration <= 0) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    // Baker's percentage math
    const totalFlour = totalDoughWeight / (1.0 + targetHydration + saltPct)
    const totalWater = totalFlour * targetHydration
    const salt = totalFlour * saltPct

    const starterAmount = totalFlour * starterPct
    const starterFlour = starterAmount / (1.0 + starterHydration)
    const starterWater = starterAmount - starterFlour

    const addedFlour = totalFlour - starterFlour
    const addedWater = totalWater - starterWater

    this.totalFlourTarget.textContent = totalFlour.toFixed(1) + " g"
    this.totalWaterTarget.textContent = totalWater.toFixed(1) + " g"
    this.starterAmountTarget.textContent = starterAmount.toFixed(1) + " g"
    this.starterFlourTarget.textContent = starterFlour.toFixed(1) + " g"
    this.starterWaterTarget.textContent = starterWater.toFixed(1) + " g"
    this.addedFlourTarget.textContent = addedFlour.toFixed(1) + " g"
    this.addedWaterTarget.textContent = addedWater.toFixed(1) + " g"
    this.saltTarget.textContent = salt.toFixed(1) + " g"
    this.resultsTarget.classList.remove("hidden")
  }

  copy() {
    const text = [
      `Sourdough Recipe:`,
      `Total Flour: ${this.totalFlourTarget.textContent}`,
      `Total Water: ${this.totalWaterTarget.textContent}`,
      `Starter: ${this.starterAmountTarget.textContent}`,
      `Added Flour: ${this.addedFlourTarget.textContent}`,
      `Added Water: ${this.addedWaterTarget.textContent}`,
      `Salt: ${this.saltTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
