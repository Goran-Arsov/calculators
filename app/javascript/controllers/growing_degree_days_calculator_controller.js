import { Controller } from "@hotwired/stimulus"

const DEFAULT_BASE_F = 50.0
const DEFAULT_BASE_C = 10.0

export default class extends Controller {
  static targets = ["tmax", "tmin", "base", "unit", "resultGdd", "resultAverage", "resultBase"]

  connect() { this.calculate() }

  calculate() {
    const tmax = parseFloat(this.tmaxTarget.value)
    const tmin = parseFloat(this.tminTarget.value)
    const unit = this.unitTarget.value
    let base = parseFloat(this.baseTarget.value)
    if (!Number.isFinite(base)) {
      base = unit === "celsius" ? DEFAULT_BASE_C : DEFAULT_BASE_F
    }

    if (!Number.isFinite(tmax) || !Number.isFinite(tmin) || tmax < tmin) {
      this.clear()
      return
    }

    const avg = (tmax + tmin) / 2
    const gdd = Math.max(avg - base, 0)
    const label = unit === "celsius" ? "°C" : "°F"

    this.resultAverageTarget.textContent = `${avg.toFixed(1)}${label}`
    this.resultBaseTarget.textContent = `${base.toFixed(1)}${label}`
    this.resultGddTarget.textContent = `${gdd.toFixed(1)}`
  }

  clear() {
    this.resultGddTarget.textContent = "—"
    this.resultAverageTarget.textContent = "—"
    this.resultBaseTarget.textContent = "—"
  }

  copy() {
    const text = `Growing Degree Days:\nAverage: ${this.resultAverageTarget.textContent}\nBase: ${this.resultBaseTarget.textContent}\nGDD: ${this.resultGddTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
