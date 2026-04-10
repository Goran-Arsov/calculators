import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "volume", "tempF", "targetCo2", "sugarType",
    "resultGrams", "resultOz", "resultResidual", "resultStyle"
  ]

  static factors = { corn_sugar: 1.0, table_sugar: 0.91, dme: 1.47 }

  connect() {
    this.calculate()
  }

  calculate() {
    const volume = parseFloat(this.volumeTarget.value) || 0
    const tempF = parseFloat(this.tempFTarget.value) || 0
    const targetCo2 = parseFloat(this.targetCo2Target.value) || 0
    const sugarType = this.sugarTypeTarget.value
    const factors = { corn_sugar: 1.0, table_sugar: 0.91, dme: 1.47 }

    if (volume <= 0 || tempF < 32 || tempF > 100 || targetCo2 < 0.5 || targetCo2 > 5) {
      this.clearResults()
      return
    }

    const residual = 3.0378 - 0.050062 * tempF + 0.00026555 * tempF * tempF
    let additional = targetCo2 - residual
    if (additional < 0) additional = 0
    const volumeL = volume * 3.78541
    const grams = additional * volumeL * 3.97 * factors[sugarType]
    const oz = grams / 28.3495

    this.resultGramsTarget.textContent = grams.toFixed(1) + " g"
    this.resultOzTarget.textContent = oz.toFixed(2) + " oz"
    this.resultResidualTarget.textContent = residual.toFixed(2) + " vols"
    this.resultStyleTarget.textContent = this.style(targetCo2)
  }

  style(co2) {
    if (co2 < 1.5) return "Cask ales (English real ale)"
    if (co2 < 2.0) return "British / Irish ales"
    if (co2 < 2.5) return "American ales, porters, stouts"
    if (co2 < 3.0) return "European lagers, IPAs"
    if (co2 < 4.0) return "Belgian ales, wheat beers"
    return "Highly carbonated"
  }

  clearResults() {
    this.resultGramsTarget.textContent = "—"
    this.resultOzTarget.textContent = "—"
    this.resultResidualTarget.textContent = "—"
    this.resultStyleTarget.textContent = "—"
  }

  copy() {
    const text = `Priming Sugar:\nSugar: ${this.resultGramsTarget.textContent} (${this.resultOzTarget.textContent})\nResidual CO2: ${this.resultResidualTarget.textContent}\nStyle: ${this.resultStyleTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
