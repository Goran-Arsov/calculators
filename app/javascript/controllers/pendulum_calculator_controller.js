import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mode",
    "length", "gravity", "period",
    "lengthGroup", "gravityGroup", "periodGroup",
    "results",
    "resultPeriod", "resultFrequency", "resultAngularFreq",
    "resultLength", "resultGravity"
  ]

  connect() {
    this.updateFields()
  }

  updateFields() {
    const mode = this.modeTarget.value
    this.lengthGroupTarget.classList.toggle("hidden", mode === "find_length")
    this.periodGroupTarget.classList.toggle("hidden", mode === "find_period")
    // gravity group always visible (optional for find_period/find_length, required for find_gravity)
    this.gravityGroupTarget.classList.toggle("hidden", false)
    this.resultsTarget.classList.add("hidden")
  }

  calculate() {
    const mode = this.modeTarget.value
    const DEFAULT_G = 9.80665
    let L, g, T, f, omega

    if (mode === "find_period") {
      L = parseFloat(this.lengthTarget.value)
      g = parseFloat(this.gravityTarget.value) || DEFAULT_G
      if (isNaN(L) || L <= 0 || g <= 0) { this.resultsTarget.classList.add("hidden"); return }
      T = 2 * Math.PI * Math.sqrt(L / g)
      f = 1 / T
      omega = 2 * Math.PI * f
    } else if (mode === "find_length") {
      T = parseFloat(this.periodTarget.value)
      g = parseFloat(this.gravityTarget.value) || DEFAULT_G
      if (isNaN(T) || T <= 0 || g <= 0) { this.resultsTarget.classList.add("hidden"); return }
      L = g * Math.pow(T / (2 * Math.PI), 2)
      f = 1 / T
      omega = 2 * Math.PI * f
    } else if (mode === "find_gravity") {
      L = parseFloat(this.lengthTarget.value)
      T = parseFloat(this.periodTarget.value)
      if (isNaN(L) || L <= 0 || isNaN(T) || T <= 0) { this.resultsTarget.classList.add("hidden"); return }
      g = L * Math.pow(2 * Math.PI / T, 2)
      f = 1 / T
      omega = 2 * Math.PI * f
    }

    this.resultsTarget.classList.remove("hidden")
    this.resultPeriodTarget.textContent = this.fmt(T) + " s"
    this.resultFrequencyTarget.textContent = this.fmt(f) + " Hz"
    this.resultAngularFreqTarget.textContent = this.fmt(omega) + " rad/s"
    this.resultLengthTarget.textContent = this.fmt(L) + " m"
    this.resultGravityTarget.textContent = this.fmt(g) + " m/s\u00B2"
  }

  fmt(n) {
    const abs = Math.abs(n)
    if (abs >= 1e6) return n.toExponential(4)
    if (abs >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const results = this.resultsTarget.querySelectorAll("[data-result]")
    const lines = Array.from(results).map(el => el.textContent)
    navigator.clipboard.writeText("Pendulum: " + lines.join(" | "))
  }
}
