import { Controller } from "@hotwired/stimulus"

const FACTORS = {
  red_oak: 4.0, white_oak: 5.0, red_maple: 4.5, sugar_maple: 5.5, silver_maple: 3.0,
  white_pine: 5.0, scotch_pine: 3.5, cottonwood: 2.0, dogwood: 7.0, white_birch: 5.0,
  walnut: 4.5, ash: 4.0, american_beech: 6.0, apple: 2.0, basswood: 3.0, bradford_pear: 3.0,
  shagbark_hickory: 7.5, tulip_poplar: 3.0, redwood: 5.0
}

export default class extends Controller {
  static targets = ["circumference", "species", "resultDiameter", "resultAge", "resultFactor"]

  connect() { this.calculate() }

  calculate() {
    const circ = parseFloat(this.circumferenceTarget.value)
    const species = this.speciesTarget.value
    const factor = FACTORS[species]

    if (!Number.isFinite(circ) || circ <= 0 || !factor) {
      this.clear()
      return
    }

    const diameter = circ / Math.PI
    const age = Math.round(diameter * factor)

    this.resultDiameterTarget.textContent = `${diameter.toFixed(2)} in`
    this.resultFactorTarget.textContent = `${factor.toFixed(1)}`
    this.resultAgeTarget.textContent = `${age} years`
  }

  clear() {
    this.resultDiameterTarget.textContent = "—"
    this.resultFactorTarget.textContent = "—"
    this.resultAgeTarget.textContent = "—"
  }

  copy() {
    const text = `Tree age estimate:\nDiameter: ${this.resultDiameterTarget.textContent}\nGrowth factor: ${this.resultFactorTarget.textContent}\nEstimated age: ${this.resultAgeTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
