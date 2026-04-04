import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "earthWeight",
    "resultMercury", "resultVenus", "resultMars", "resultJupiter",
    "resultSaturn", "resultUranus", "resultNeptune", "resultMoon", "resultPluto"
  ]

  static gravityRatios = {
    Mercury: 0.378,
    Venus:   0.907,
    Mars:    0.377,
    Jupiter: 2.36,
    Saturn:  0.916,
    Uranus:  0.889,
    Neptune: 1.12,
    Moon:    0.1654,
    Pluto:   0.071
  }

  calculate() {
    const weight = parseFloat(this.earthWeightTarget.value) || 0

    const ratios = this.constructor.gravityRatios

    this.resultMercuryTarget.textContent = this.fmt(weight * ratios.Mercury)
    this.resultVenusTarget.textContent = this.fmt(weight * ratios.Venus)
    this.resultMarsTarget.textContent = this.fmt(weight * ratios.Mars)
    this.resultJupiterTarget.textContent = this.fmt(weight * ratios.Jupiter)
    this.resultSaturnTarget.textContent = this.fmt(weight * ratios.Saturn)
    this.resultUranusTarget.textContent = this.fmt(weight * ratios.Uranus)
    this.resultNeptuneTarget.textContent = this.fmt(weight * ratios.Neptune)
    this.resultMoonTarget.textContent = this.fmt(weight * ratios.Moon)
    this.resultPlutoTarget.textContent = this.fmt(weight * ratios.Pluto)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
