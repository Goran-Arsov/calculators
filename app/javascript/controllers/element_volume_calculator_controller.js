import { Controller } from "@hotwired/stimulus"
import { ELEMENTS } from "controllers/element_density_data"

export default class extends Controller {
  static targets = ["element", "mass", "resultVolume", "resultDensity", "resultElement"]

  calculate() {
    const symbol = this.elementTarget.value
    const mass = parseFloat(this.massTarget.value)
    const el = ELEMENTS.find(e => e.symbol === symbol)

    if (!el || !el.density || isNaN(mass) || mass <= 0) {
      this.clearResults()
      return
    }

    const volume = mass / el.density
    this.resultElementTarget.textContent = `${el.name} (${el.symbol})`
    this.resultDensityTarget.textContent = `${el.density} g/cm³`
    this.resultVolumeTarget.textContent = this.fmt(volume) + " cm³"
  }

  clearResults() {
    this.resultVolumeTarget.textContent = "—"
    this.resultDensityTarget.textContent = "—"
    this.resultElementTarget.textContent = "—"
  }

  fmt(n) {
    if (n >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    if (n >= 1) return n.toFixed(4).replace(/\.?0+$/, "")
    return n.toExponential(4)
  }

  copy() {
    const text = `Element: ${this.resultElementTarget.textContent}\nDensity: ${this.resultDensityTarget.textContent}\nVolume: ${this.resultVolumeTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
