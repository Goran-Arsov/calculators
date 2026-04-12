import { Controller } from "@hotwired/stimulus"

const DIGITS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

function toDecimal(numStr, base) {
  const negative = numStr.startsWith("-")
  const clean = negative ? numStr.slice(1) : numStr
  let result = 0
  for (const ch of clean.toUpperCase()) {
    const d = DIGITS.indexOf(ch)
    if (d < 0 || d >= base) return NaN
    result = result * base + d
  }
  return negative ? -result : result
}

function fromDecimal(decimal, base) {
  if (decimal === 0) return "0"
  const negative = decimal < 0
  decimal = Math.abs(decimal)
  const digits = []
  while (decimal > 0) {
    digits.unshift(DIGITS[decimal % base])
    decimal = Math.floor(decimal / base)
  }
  return (negative ? "-" : "") + digits.join("")
}

function baseName(base) {
  if (base === 2) return "Binary"
  if (base === 8) return "Octal"
  if (base === 10) return "Decimal"
  if (base === 16) return "Hexadecimal"
  return `Base ${base}`
}

const OP_SYMBOLS = { add: "+", subtract: "-", multiply: "\u00D7" }

export default class extends Controller {
  static targets = ["number1", "number2", "base", "operation", "result", "resultDetail", "error", "validDigits"]

  connect() { this.updateValidDigits() }

  updateValidDigits() {
    const base = parseInt(this.baseTarget.value, 10) || 10
    if (this.hasValidDigitsTarget) {
      this.validDigitsTarget.textContent = `Valid digits: ${DIGITS.slice(0, base)}`
    }
    this.calculate()
  }

  calculate() {
    const n1 = this.number1Target.value.trim().toUpperCase()
    const n2 = this.number2Target.value.trim().toUpperCase()
    const base = parseInt(this.baseTarget.value, 10)
    const op = this.operationTarget.value
    this.errorTarget.textContent = ""

    if (!n1 || !n2 || isNaN(base) || base < 2 || base > 36) { this.clear(); return }

    const d1 = toDecimal(n1, base)
    const d2 = toDecimal(n2, base)

    if (isNaN(d1)) { this.errorTarget.textContent = `Number 1 has invalid digits for ${baseName(base)}`; this.clear(); return }
    if (isNaN(d2)) { this.errorTarget.textContent = `Number 2 has invalid digits for ${baseName(base)}`; this.clear(); return }

    let resultDec
    switch (op) {
      case "add": resultDec = d1 + d2; break
      case "subtract": resultDec = d1 - d2; break
      case "multiply": resultDec = d1 * d2; break
      default: this.clear(); return
    }

    const resultInBase = fromDecimal(resultDec, base)
    const sym = OP_SYMBOLS[op] || op

    this.resultTarget.textContent = resultInBase
    if (this.hasResultDetailTarget) {
      this.resultDetailTarget.textContent =
        `${n1} ${sym} ${n2} = ${resultInBase} (${baseName(base)})\n` +
        `In decimal: ${d1} ${sym} ${d2} = ${resultDec}`
    }
  }

  clear() {
    this.resultTarget.textContent = "\u2014"
    if (this.hasResultDetailTarget) this.resultDetailTarget.textContent = ""
  }

  copy() {
    navigator.clipboard.writeText(this.resultTarget.textContent)
  }
}
