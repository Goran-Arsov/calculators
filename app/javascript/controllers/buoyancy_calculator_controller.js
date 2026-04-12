import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mass", "volume", "fluid", "customDensity", "customDensityGroup",
    "results",
    "resultBuoyantForce", "resultWeight", "resultNetForce",
    "resultStatus", "resultObjectDensity", "resultApparentWeight",
    "resultPercentSubmerged"
  ]

  static values = {
    fluids: { type: Object, default: {
      water: 998.0, seawater: 1025.0, mercury: 13534.0, oil: 900.0,
      glycerin: 1261.0, ethanol: 789.0, gasoline: 680.0, air: 1.204
    }}
  }

  connect() {
    this.updateCustomField()
  }

  updateCustomField() {
    const isCustom = this.fluidTarget.value === "custom"
    this.customDensityGroupTarget.classList.toggle("hidden", !isCustom)
    this.calculate()
  }

  calculate() {
    const mass = parseFloat(this.massTarget.value)
    const volume = parseFloat(this.volumeTarget.value)
    const fluid = this.fluidTarget.value
    const g = 9.80665

    if (isNaN(mass) || mass <= 0 || isNaN(volume) || volume <= 0) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    let fluidDensity
    if (fluid === "custom") {
      fluidDensity = parseFloat(this.customDensityTarget.value)
      if (isNaN(fluidDensity) || fluidDensity <= 0) { this.resultsTarget.classList.add("hidden"); return }
    } else {
      fluidDensity = this.fluidsValue[fluid]
      if (!fluidDensity) { this.resultsTarget.classList.add("hidden"); return }
    }

    const buoyantForce = fluidDensity * volume * g
    const weight = mass * g
    const netForce = buoyantForce - weight
    const objectDensity = mass / volume
    const fractionSubmerged = Math.min(objectDensity / fluidDensity, 1.0)
    const apparentWeight = buoyantForce >= weight ? 0 : weight - buoyantForce

    let status
    if (buoyantForce > weight) status = "Floats"
    else if (buoyantForce < weight) status = "Sinks"
    else status = "Neutrally buoyant"

    this.resultsTarget.classList.remove("hidden")
    this.resultBuoyantForceTarget.textContent = this.fmt(buoyantForce) + " N"
    this.resultWeightTarget.textContent = this.fmt(weight) + " N"
    this.resultNetForceTarget.textContent = this.fmt(netForce) + " N"
    this.resultStatusTarget.textContent = status
    this.resultObjectDensityTarget.textContent = this.fmt(objectDensity) + " kg/m\u00B3"
    this.resultApparentWeightTarget.textContent = this.fmt(apparentWeight) + " N"
    this.resultPercentSubmergedTarget.textContent = (fractionSubmerged * 100).toFixed(2) + "%"

    // Color-code status
    const statusEl = this.resultStatusTarget
    statusEl.classList.remove("text-green-600", "text-red-600", "text-blue-600", "dark:text-green-400", "dark:text-red-400", "dark:text-blue-400")
    if (status === "Floats") { statusEl.classList.add("text-green-600", "dark:text-green-400") }
    else if (status === "Sinks") { statusEl.classList.add("text-red-600", "dark:text-red-400") }
    else { statusEl.classList.add("text-blue-600", "dark:text-blue-400") }
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
    navigator.clipboard.writeText("Buoyancy: " + lines.join(" | "))
  }
}
