import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "numPizzas", "size", "hydration", "fermentTime", "includeOil", "includeSugar",
    "results", "flour", "water", "salt", "yeast", "oil", "sugar",
    "totalWeight", "doughBallWeight", "yeastNote"
  ]

  get ballWeights() {
    return { small: 200, medium: 250, large: 300, extra_large: 350 }
  }

  calculate() {
    const numPizzas = parseInt(this.numPizzasTarget.value) || 0
    const size = this.sizeTarget.value
    const hydration = (parseFloat(this.hydrationTarget.value) || 65) / 100
    const fermentTime = this.fermentTimeTarget.value
    const includeOil = this.includeOilTarget.checked
    const includeSugar = this.includeSugarTarget.checked

    if (numPizzas <= 0 || !this.ballWeights[size] || hydration < 0.5 || hydration > 1.0) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const doughBallWeight = this.ballWeights[size]
    const totalDoughWeight = doughBallWeight * numPizzas

    const saltPct = 0.025
    const yeastPct = this.getYeastPct(fermentTime)
    const oilPct = includeOil ? 0.03 : 0
    const sugarPct = includeSugar ? 0.01 : 0

    const totalPct = 1.0 + hydration + saltPct + yeastPct + oilPct + sugarPct
    const flour = totalDoughWeight / totalPct
    const water = flour * hydration
    const salt = flour * saltPct
    const yeast = flour * yeastPct
    const oil = flour * oilPct
    const sugar = flour * sugarPct

    this.flourTarget.textContent = flour.toFixed(1) + " g"
    this.waterTarget.textContent = water.toFixed(1) + " g"
    this.saltTarget.textContent = salt.toFixed(1) + " g"
    this.yeastTarget.textContent = yeast.toFixed(2) + " g"
    this.oilTarget.textContent = includeOil ? oil.toFixed(1) + " g" : "---"
    this.sugarTarget.textContent = includeSugar ? sugar.toFixed(1) + " g" : "---"
    this.totalWeightTarget.textContent = totalDoughWeight + " g"
    this.doughBallWeightTarget.textContent = doughBallWeight + " g"
    this.yeastNoteTarget.textContent = this.getYeastNote(fermentTime)
    this.resultsTarget.classList.remove("hidden")
  }

  getYeastPct(fermentTime) {
    const pcts = { same_day: 0.01, overnight: 0.005, long: 0.003, cold_48h: 0.0015 }
    return pcts[fermentTime] || 0.005
  }

  getYeastNote(fermentTime) {
    const notes = {
      same_day: "Active dry or instant yeast. Ready in 2-4 hours at room temperature.",
      overnight: "Active dry or instant yeast. 8-12 hours at room temperature.",
      long: "Instant yeast preferred. 24 hours cold ferment in fridge.",
      cold_48h: "Instant yeast preferred. 48 hours cold ferment in fridge for best flavor."
    }
    return notes[fermentTime] || "Adjust yeast based on desired ferment time."
  }

  copy() {
    const text = [
      `Pizza Dough Recipe (${this.numPizzasTarget.value} pizzas):`,
      `Flour: ${this.flourTarget.textContent}`,
      `Water: ${this.waterTarget.textContent}`,
      `Salt: ${this.saltTarget.textContent}`,
      `Yeast: ${this.yeastTarget.textContent}`,
      `Oil: ${this.oilTarget.textContent}`,
      `Sugar: ${this.sugarTarget.textContent}`,
      `Total: ${this.totalWeightTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
