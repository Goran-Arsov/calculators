import { Controller } from "@hotwired/stimulus"

function mod(a, m) {
  return ((a % m) + m) % m
}

function fastPow(base, exp, m) {
  let result = 1
  base = mod(base, m)
  while (exp > 0) {
    if (exp % 2 === 1) result = mod(result * base, m)
    exp = Math.floor(exp / 2)
    base = mod(base * base, m)
  }
  return result
}

function extGcd(a, b) {
  if (b === 0) return [a, 1, 0]
  const [g, x, y] = extGcd(b, a % b)
  return [g, y, x - Math.floor(a / b) * y]
}

function fmt(n) {
  return Number.isInteger(n) ? n.toString() : n.toFixed(6)
}

export default class extends Controller {
  static targets = ["a", "b", "modulus", "operation", "result", "resultDetail", "error", "bInput"]

  connect() { this.updateVisibility() }

  updateVisibility() {
    const op = this.operationTarget.value
    const needsB = ["add", "subtract", "multiply", "exponentiate"].includes(op)
    if (this.hasBInputTarget) this.bInputTarget.classList.toggle("hidden", !needsB)
    this.calculate()
  }

  calculate() {
    const a = parseInt(this.aTarget.value, 10)
    const b = parseInt(this.bTarget.value, 10)
    const m = parseInt(this.modulusTarget.value, 10)
    const op = this.operationTarget.value
    this.errorTarget.textContent = ""

    if (isNaN(a) || isNaN(m) || m <= 1) { this.clear(); return }

    try {
      let result, detail
      switch (op) {
        case "add": {
          if (isNaN(b)) { this.clear(); return }
          const r = mod(a + b, m)
          result = fmt(r)
          detail = `(${a} + ${b}) mod ${m} = ${r}`
          break
        }
        case "subtract": {
          if (isNaN(b)) { this.clear(); return }
          const r = mod(a - b, m)
          result = fmt(r)
          detail = `(${a} - ${b}) mod ${m} = ${r}`
          break
        }
        case "multiply": {
          if (isNaN(b)) { this.clear(); return }
          const r = mod(a * b, m)
          result = fmt(r)
          detail = `(${a} \u00D7 ${b}) mod ${m} = ${r}`
          break
        }
        case "exponentiate": {
          if (isNaN(b) || b < 0) { this.errorTarget.textContent = "Exponent must be non-negative"; this.clear(); return }
          const r = fastPow(a, b, m)
          result = fmt(r)
          detail = `${a}^${b} mod ${m} = ${r} (binary exponentiation)`
          break
        }
        case "inverse": {
          const amod = mod(a, m)
          const [g, x] = extGcd(amod, m)
          if (g !== 1) {
            result = "No inverse"
            detail = `gcd(${a}, ${m}) = ${g} \u2260 1, no modular inverse exists`
          } else {
            const inv = mod(x, m)
            result = fmt(inv)
            detail = `${a}\u207B\u00B9 \u2261 ${inv} (mod ${m})\nVerification: ${a} \u00D7 ${inv} = ${a * inv} \u2261 ${mod(a * inv, m)} (mod ${m})`
          }
          break
        }
        default: this.clear(); return
      }

      this.resultTarget.textContent = result
      if (this.hasResultDetailTarget) this.resultDetailTarget.textContent = detail
    } catch (e) {
      this.clear()
      this.errorTarget.textContent = e.message
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
