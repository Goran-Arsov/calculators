import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["distForMpg", "fuelForMpg", "resultMpg", "distForL100", "fuelForL100", "resultL100"]

  calcMpg() {
    const dist = parseFloat(this.distForMpgTarget.value) || 0
    const fuel = parseFloat(this.fuelForMpgTarget.value) || 0

    const mpg = fuel > 0 ? dist / fuel : 0

    this.resultMpgTarget.textContent = this.fmt(mpg)
  }

  calcL100() {
    const dist = parseFloat(this.distForL100Target.value) || 0
    const fuel = parseFloat(this.fuelForL100Target.value) || 0

    const l100 = dist > 0 ? (fuel / dist) * 100 : 0

    this.resultL100Target.textContent = this.fmt(l100)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
