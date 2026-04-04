import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dogAge", "size", "resultHumanAge"]

  static sizeAdjustment = {
    small: -2,
    medium: 0,
    large: 2
  }

  calculate() {
    const dogAge = parseFloat(this.dogAgeTarget.value) || 0
    const size = this.sizeTarget.value

    if (dogAge <= 0) {
      this.resultHumanAgeTarget.textContent = "0"
      return
    }

    const baseAge = 16 * Math.log(dogAge) + 31
    const adjustment = this.constructor.sizeAdjustment[size] || 0
    const humanAge = baseAge + adjustment

    this.resultHumanAgeTarget.textContent = this.fmt(Math.max(0, humanAge))
  }

  fmt(n) {
    return n.toFixed(1)
  }
}
