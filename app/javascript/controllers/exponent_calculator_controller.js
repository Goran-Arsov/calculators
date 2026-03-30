import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["base", "exponent", "result"]

  calculate() {
    const base = parseFloat(this.baseTarget.value)
    const exp = parseFloat(this.exponentTarget.value)

    if (isNaN(base) || isNaN(exp)) {
      this.resultTarget.textContent = "0"
      return
    }

    if (base === 0 && exp < 0) {
      this.resultTarget.textContent = "Undefined (division by zero)"
      return
    }

    if (base < 0 && exp !== Math.floor(exp)) {
      this.resultTarget.textContent = "Undefined (negative base with fractional exponent)"
      return
    }

    const result = Math.pow(base, exp)

    if (!isFinite(result)) {
      this.resultTarget.textContent = "Result is too large"
      return
    }

    this.resultTarget.textContent = Number.isInteger(result) ? result.toString() : result.toPrecision(10).replace(/\.?0+$/, "")
  }

  copy() {
    navigator.clipboard.writeText(this.resultTarget.textContent)
  }
}
