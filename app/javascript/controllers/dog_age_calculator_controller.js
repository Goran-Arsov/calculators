import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dogAge", "size", "humanAge"]

  static sizeAdjustment = {
    small: -2,
    medium: 0,
    large: 2
  }

  calculate() {
    const dogAge = parseFloat(this.dogAgeTarget.value) || 0
    const size = this.sizeTarget.value

    if (dogAge <= 0) {
      this.humanAgeTarget.textContent = "— years"
      return
    }

    let humanAge
    if (dogAge <= 1) {
      humanAge = 15 * dogAge
    } else {
      humanAge = 16 * Math.log(dogAge) + 31
    }

    const adjustment = this.constructor.sizeAdjustment[size] || 0
    humanAge += adjustment

    this.humanAgeTarget.textContent = `${this.fmt(Math.max(0, humanAge))} years`
  }

  copy() {
    const text = `Human Age Equivalent: ${this.humanAgeTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return n.toFixed(1)
  }
}
