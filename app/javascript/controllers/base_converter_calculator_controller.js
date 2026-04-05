import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "inputBase", "decimal", "binary", "octal", "hex"]

  calculate() {
    const val = this.valueTarget.value.trim()
    const base = this.inputBaseTarget.value

    if (!val) {
      this.clearResults()
      return
    }

    const decimalVal = this.toDecimal(val, base)
    if (decimalVal === null) {
      this.decimalTarget.textContent = "Invalid input"
      this.binaryTarget.textContent = "—"
      this.octalTarget.textContent = "—"
      this.hexTarget.textContent = "—"
      return
    }

    this.decimalTarget.textContent = decimalVal.toString()
    this.binaryTarget.textContent = decimalVal.toString(2)
    this.octalTarget.textContent = decimalVal.toString(8)
    this.hexTarget.textContent = decimalVal.toString(16).toUpperCase()
  }

  toDecimal(val, base) {
    const cleaned = val.replace(/^-/, "")
    const neg = val.startsWith("-")

    let valid = false
    let radix = 10

    switch (base) {
      case "binary":
        valid = /^[01]+$/.test(cleaned)
        radix = 2
        break
      case "octal":
        valid = /^[0-7]+$/.test(cleaned)
        radix = 8
        break
      case "decimal":
        valid = /^\d+$/.test(cleaned)
        radix = 10
        break
      case "hex":
        valid = /^[0-9a-fA-F]+$/.test(cleaned)
        radix = 16
        break
      default:
        return null
    }

    if (!valid) return null

    const result = parseInt(cleaned, radix)
    return neg ? -result : result
  }

  clearResults() {
    this.decimalTarget.textContent = "—"
    this.binaryTarget.textContent = "—"
    this.octalTarget.textContent = "—"
    this.hexTarget.textContent = "—"
  }

  copy() {
    const d = this.decimalTarget.textContent
    const b = this.binaryTarget.textContent
    const o = this.octalTarget.textContent
    const h = this.hexTarget.textContent
    navigator.clipboard.writeText(`Decimal: ${d}\nBinary: ${b}\nOctal: ${o}\nHex: ${h}`)
  }
}
