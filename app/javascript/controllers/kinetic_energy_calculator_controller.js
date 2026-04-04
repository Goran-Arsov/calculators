import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["energy", "mass", "velocity", "mode",
                     "resultEnergy", "resultMass", "resultVelocity"]

  calculate() {
    const mode = this.modeTarget.value
    const ke = parseFloat(this.energyTarget.value)
    const m = parseFloat(this.massTarget.value)
    const v = parseFloat(this.velocityTarget.value)

    if (mode === "energy" && m > 0 && !isNaN(v)) {
      this.resultEnergyTarget.textContent = this.fmt(0.5 * m * v * v)
      this.resultMassTarget.textContent = this.fmt(m)
      this.resultVelocityTarget.textContent = this.fmt(v)
    } else if (mode === "mass" && ke >= 0 && v !== 0 && !isNaN(v)) {
      this.resultMassTarget.textContent = this.fmt((2 * ke) / (v * v))
      this.resultEnergyTarget.textContent = this.fmt(ke)
      this.resultVelocityTarget.textContent = this.fmt(v)
    } else if (mode === "velocity" && ke >= 0 && m > 0) {
      this.resultVelocityTarget.textContent = this.fmt(Math.sqrt(2 * ke / m))
      this.resultEnergyTarget.textContent = this.fmt(ke)
      this.resultMassTarget.textContent = this.fmt(m)
    } else {
      this.clearResults()
    }
  }

  clearResults() {
    this.resultEnergyTarget.textContent = "—"
    this.resultMassTarget.textContent = "—"
    this.resultVelocityTarget.textContent = "—"
  }

  fmt(n) { return n.toFixed(4).replace(/\.?0+$/, "") }

  copy() {
    const text = `Kinetic Energy: ${this.resultEnergyTarget.textContent} J\nMass: ${this.resultMassTarget.textContent} kg\nVelocity: ${this.resultVelocityTarget.textContent} m/s`
    navigator.clipboard.writeText(text)
  }
}
