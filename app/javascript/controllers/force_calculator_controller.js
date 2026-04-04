import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["force", "mass", "acceleration", "mode",
                     "resultForce", "resultMass", "resultAcceleration"]

  calculate() {
    const mode = this.modeTarget.value
    const f = parseFloat(this.forceTarget.value)
    const m = parseFloat(this.massTarget.value)
    const a = parseFloat(this.accelerationTarget.value)

    if (mode === "force" && m > 0 && a !== undefined && !isNaN(a)) {
      this.resultForceTarget.textContent = this.fmt(m * a)
      this.resultMassTarget.textContent = this.fmt(m)
      this.resultAccelerationTarget.textContent = this.fmt(a)
    } else if (mode === "mass" && f !== undefined && !isNaN(f) && a !== 0 && !isNaN(a)) {
      this.resultMassTarget.textContent = this.fmt(f / a)
      this.resultForceTarget.textContent = this.fmt(f)
      this.resultAccelerationTarget.textContent = this.fmt(a)
    } else if (mode === "acceleration" && f !== undefined && !isNaN(f) && m > 0) {
      this.resultAccelerationTarget.textContent = this.fmt(f / m)
      this.resultForceTarget.textContent = this.fmt(f)
      this.resultMassTarget.textContent = this.fmt(m)
    } else {
      this.clearResults()
    }
  }

  clearResults() {
    this.resultForceTarget.textContent = "—"
    this.resultMassTarget.textContent = "—"
    this.resultAccelerationTarget.textContent = "—"
  }

  fmt(n) { return n.toFixed(4).replace(/\.?0+$/, "") }

  copy() {
    const text = `Force: ${this.resultForceTarget.textContent} N\nMass: ${this.resultMassTarget.textContent} kg\nAcceleration: ${this.resultAccelerationTarget.textContent} m/s²`
    navigator.clipboard.writeText(text)
  }
}
