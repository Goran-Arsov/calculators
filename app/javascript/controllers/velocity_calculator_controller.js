import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["distance", "time", "velocity", "mode",
                     "resultDistance", "resultTime", "resultVelocity"]

  calculate() {
    const mode = this.modeTarget.value
    const d = parseFloat(this.distanceTarget.value)
    const t = parseFloat(this.timeTarget.value)
    const v = parseFloat(this.velocityTarget.value)

    if (mode === "velocity" && d > 0 && t > 0) {
      this.resultVelocityTarget.textContent = this.fmt(d / t)
      this.resultDistanceTarget.textContent = this.fmt(d)
      this.resultTimeTarget.textContent = this.fmt(t)
    } else if (mode === "distance" && v > 0 && t > 0) {
      this.resultDistanceTarget.textContent = this.fmt(v * t)
      this.resultVelocityTarget.textContent = this.fmt(v)
      this.resultTimeTarget.textContent = this.fmt(t)
    } else if (mode === "time" && d > 0 && v > 0) {
      this.resultTimeTarget.textContent = this.fmt(d / v)
      this.resultDistanceTarget.textContent = this.fmt(d)
      this.resultVelocityTarget.textContent = this.fmt(v)
    } else {
      this.clearResults()
    }
  }

  clearResults() {
    this.resultDistanceTarget.textContent = "—"
    this.resultTimeTarget.textContent = "—"
    this.resultVelocityTarget.textContent = "—"
  }

  fmt(n) { return n.toFixed(4).replace(/\.?0+$/, "") }

  copy() {
    const text = `Velocity: ${this.resultVelocityTarget.textContent} m/s\nDistance: ${this.resultDistanceTarget.textContent} m\nTime: ${this.resultTimeTarget.textContent} s`
    navigator.clipboard.writeText(text)
  }
}
