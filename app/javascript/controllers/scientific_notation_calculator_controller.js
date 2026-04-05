import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "mode", "scientific", "eNotation", "decimal", "coefficient", "exponent"]

  calculate() {
    const val = this.valueTarget.value.trim()
    const mode = this.modeTarget.value

    if (!val) {
      this.clearResults()
      return
    }

    if (mode === "to_standard") {
      if (!/^[+-]?\d+(\.\d+)?[eE][+-]?\d+$/.test(val)) {
        this.scientificTarget.textContent = "Invalid format"
        this.eNotationTarget.textContent = "—"
        this.decimalTarget.textContent = "—"
        this.coefficientTarget.textContent = "—"
        this.exponentTarget.textContent = "—"
        return
      }
      const num = parseFloat(val)
      const parts = val.toLowerCase().split("e")
      const coeff = parseFloat(parts[0])
      const exp = parseInt(parts[1])

      this.coefficientTarget.textContent = coeff
      this.exponentTarget.textContent = exp
      this.scientificTarget.textContent = `${coeff} x 10^${exp}`
      this.eNotationTarget.textContent = val
      this.decimalTarget.textContent = this.formatDecimal(num)
      return
    }

    const num = parseFloat(val)
    if (isNaN(num)) {
      this.clearResults()
      return
    }

    if (num === 0) {
      this.coefficientTarget.textContent = "0"
      this.exponentTarget.textContent = "0"
      this.scientificTarget.textContent = "0 x 10^0"
      this.eNotationTarget.textContent = "0e0"
      this.decimalTarget.textContent = "0"
      return
    }

    let exp = Math.floor(Math.log10(Math.abs(num)))
    let coeff = num / Math.pow(10, exp)

    if (Math.abs(coeff) >= 10) {
      exp += 1
      coeff = num / Math.pow(10, exp)
    } else if (Math.abs(coeff) < 1 && coeff !== 0) {
      exp -= 1
      coeff = num / Math.pow(10, exp)
    }

    const roundedCoeff = parseFloat(coeff.toFixed(6))

    this.coefficientTarget.textContent = roundedCoeff
    this.exponentTarget.textContent = exp
    this.scientificTarget.textContent = `${roundedCoeff} x 10^${exp}`
    this.eNotationTarget.textContent = `${roundedCoeff}e${exp}`
    this.decimalTarget.textContent = this.formatDecimal(num)
  }

  formatDecimal(value) {
    if (value === Math.floor(value) && Math.abs(value) < 1e15) {
      return value.toFixed(0)
    }
    return value.toPrecision(15).replace(/\.?0+$/, "")
  }

  clearResults() {
    this.scientificTarget.textContent = "—"
    this.eNotationTarget.textContent = "—"
    this.decimalTarget.textContent = "—"
    this.coefficientTarget.textContent = "—"
    this.exponentTarget.textContent = "—"
  }

  copy() {
    const sci = this.scientificTarget.textContent
    const eNot = this.eNotationTarget.textContent
    const dec = this.decimalTarget.textContent
    navigator.clipboard.writeText(`Scientific: ${sci}\nE-notation: ${eNot}\nDecimal: ${dec}`)
  }
}
