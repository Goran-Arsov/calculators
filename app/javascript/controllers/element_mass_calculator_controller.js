import { Controller } from "@hotwired/stimulus"
import { ELEMENTS } from "controllers/element_density_data"

export default class extends Controller {
  static targets = ["element", "volume", "resultMass", "resultDensity", "resultElement"]

  calculate() {
    const symbol = this.elementTarget.value
    const volume = parseFloat(this.volumeTarget.value)
    const el = ELEMENTS.find(e => e.symbol === symbol)

    if (!el || !el.density || isNaN(volume) || volume <= 0) {
      this.clearResults()
      return
    }

    const mass = el.density * volume
    this.resultElementTarget.textContent = `${el.name} (${el.symbol})`
    this.resultDensityTarget.textContent = `${el.density} g/cm³`
    this.resultMassTarget.textContent = this.fmt(mass) + " g"
  }

  clearResults() {
    this.resultMassTarget.textContent = "—"
    this.resultDensityTarget.textContent = "—"
    this.resultElementTarget.textContent = "—"
  }

  fmt(n) {
    if (n >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    if (n >= 1) return n.toFixed(4).replace(/\.?0+$/, "")
    return n.toExponential(4)
  }

  copy() {
    const text = `Element: ${this.resultElementTarget.textContent}\nDensity: ${this.resultDensityTarget.textContent}\nMass: ${this.resultMassTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
