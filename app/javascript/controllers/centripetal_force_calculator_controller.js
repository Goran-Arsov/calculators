import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mode",
    "force", "mass", "velocity", "radius",
    "forceGroup", "massGroup", "velocityGroup", "radiusGroup",
    "results",
    "resultForce", "resultMass", "resultVelocity", "resultRadius",
    "resultAcceleration", "resultAngularVelocity", "resultPeriod"
  ]

  connect() {
    this.updateFields()
  }

  updateFields() {
    const mode = this.modeTarget.value
    this.forceGroupTarget.classList.toggle("hidden", mode === "find_force")
    this.massGroupTarget.classList.toggle("hidden", mode === "find_mass")
    this.velocityGroupTarget.classList.toggle("hidden", mode === "find_velocity")
    this.radiusGroupTarget.classList.toggle("hidden", mode === "find_radius")
    this.resultsTarget.classList.add("hidden")
  }

  calculate() {
    const mode = this.modeTarget.value
    let F, m, v, r, a, omega, T

    if (mode === "find_force") {
      m = parseFloat(this.massTarget.value)
      v = parseFloat(this.velocityTarget.value)
      r = parseFloat(this.radiusTarget.value)
      if (isNaN(m) || m <= 0 || isNaN(v) || v <= 0 || isNaN(r) || r <= 0) { this.resultsTarget.classList.add("hidden"); return }
      F = m * v * v / r
    } else if (mode === "find_mass") {
      F = parseFloat(this.forceTarget.value)
      v = parseFloat(this.velocityTarget.value)
      r = parseFloat(this.radiusTarget.value)
      if (isNaN(F) || F <= 0 || isNaN(v) || v <= 0 || isNaN(r) || r <= 0) { this.resultsTarget.classList.add("hidden"); return }
      m = F * r / (v * v)
    } else if (mode === "find_velocity") {
      F = parseFloat(this.forceTarget.value)
      m = parseFloat(this.massTarget.value)
      r = parseFloat(this.radiusTarget.value)
      if (isNaN(F) || F <= 0 || isNaN(m) || m <= 0 || isNaN(r) || r <= 0) { this.resultsTarget.classList.add("hidden"); return }
      v = Math.sqrt(F * r / m)
    } else if (mode === "find_radius") {
      F = parseFloat(this.forceTarget.value)
      m = parseFloat(this.massTarget.value)
      v = parseFloat(this.velocityTarget.value)
      if (isNaN(F) || F <= 0 || isNaN(m) || m <= 0 || isNaN(v) || v <= 0) { this.resultsTarget.classList.add("hidden"); return }
      r = m * v * v / F
    }

    a = v * v / r
    omega = v / r
    T = 2 * Math.PI * r / v

    this.resultsTarget.classList.remove("hidden")
    this.resultForceTarget.textContent = this.fmt(F) + " N"
    this.resultMassTarget.textContent = this.fmt(m) + " kg"
    this.resultVelocityTarget.textContent = this.fmt(v) + " m/s"
    this.resultRadiusTarget.textContent = this.fmt(r) + " m"
    this.resultAccelerationTarget.textContent = this.fmt(a) + " m/s\u00B2"
    this.resultAngularVelocityTarget.textContent = this.fmt(omega) + " rad/s"
    this.resultPeriodTarget.textContent = this.fmt(T) + " s"
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
    navigator.clipboard.writeText("Centripetal Force: " + lines.join(" | "))
  }
}
