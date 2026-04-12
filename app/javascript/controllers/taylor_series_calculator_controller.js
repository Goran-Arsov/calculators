import { Controller } from "@hotwired/stimulus"

function factorial(n) {
  let r = 1
  for (let i = 2; i <= n; i++) r *= i
  return r
}

function toFraction(val) {
  if (val === 0) return "0"
  const sign = val < 0 ? "-" : ""
  val = Math.abs(val)
  for (let d = 1; d <= 5040; d++) {
    const n = Math.round(val * d)
    if (Math.abs(n / d - val) < 1e-12) {
      const g = gcd(n, d)
      const nr = n / g, dr = d / g
      return dr === 1 ? `${sign}${nr}` : `${sign}${nr}/${dr}`
    }
  }
  return val.toPrecision(8)
}

function gcd(a, b) { return b === 0 ? a : gcd(b, a % b) }

function computeTerms(func, numTerms) {
  const terms = []
  switch (func) {
    case "exp":
      for (let n = 0; n < numTerms; n++) terms.push({ coeff: 1.0 / factorial(n), power: n })
      break
    case "sin":
      for (let k = 0; k < numTerms; k++) {
        const n = 2 * k + 1
        terms.push({ coeff: Math.pow(-1, k) / factorial(n), power: n })
      }
      break
    case "cos":
      for (let k = 0; k < numTerms; k++) {
        const n = 2 * k
        terms.push({ coeff: Math.pow(-1, k) / factorial(n), power: n })
      }
      break
    case "ln_1_plus_x":
      for (let k = 0; k < numTerms; k++) {
        const n = k + 1
        terms.push({ coeff: Math.pow(-1, n + 1) / n, power: n })
      }
      break
    case "one_over_1_minus_x":
      for (let n = 0; n < numTerms; n++) terms.push({ coeff: 1, power: n })
      break
    case "sinh":
      for (let k = 0; k < numTerms; k++) {
        const n = 2 * k + 1
        terms.push({ coeff: 1.0 / factorial(n), power: n })
      }
      break
    case "cosh":
      for (let k = 0; k < numTerms; k++) {
        const n = 2 * k
        terms.push({ coeff: 1.0 / factorial(n), power: n })
      }
      break
    case "atan":
      for (let k = 0; k < numTerms; k++) {
        const n = 2 * k + 1
        terms.push({ coeff: Math.pow(-1, k) / n, power: n })
      }
      break
  }
  return terms
}

function formatTerm(coeff, power) {
  if (power === 0) return toFraction(coeff)
  const xp = power === 1 ? "x" : `x^${power}`
  if (coeff === 1) return xp
  if (coeff === -1) return `-${xp}`
  return `${toFraction(coeff)}${xp}`
}

function formatPolynomial(terms) {
  if (!terms.length) return "0"
  const parts = []
  terms.forEach((t, i) => {
    if (t.coeff === 0) return
    const s = formatTerm(t.coeff, t.power)
    if (i === 0) parts.push(s)
    else if (t.coeff > 0) parts.push(`+ ${s}`)
    else parts.push(`- ${s.replace(/^-/, "")}`)
  })
  return parts.join(" ") + " + ..."
}

const FUNC_NAMES = {
  exp: "e^x", sin: "sin(x)", cos: "cos(x)",
  ln_1_plus_x: "ln(1+x)", one_over_1_minus_x: "1/(1-x)",
  sinh: "sinh(x)", cosh: "cosh(x)", atan: "atan(x)"
}

export default class extends Controller {
  static targets = ["func", "numTerms", "result", "termsList", "funcDisplay", "error"]

  calculate() {
    const func = this.funcTarget.value
    const numTerms = parseInt(this.numTermsTarget.value, 10)
    this.errorTarget.textContent = ""

    if (!func || isNaN(numTerms) || numTerms < 1) { this.clear(); return }
    const n = Math.min(Math.max(numTerms, 1), 20)

    const terms = computeTerms(func, n)
    const poly = formatPolynomial(terms)
    this.resultTarget.textContent = poly
    if (this.hasFuncDisplayTarget) this.funcDisplayTarget.textContent = FUNC_NAMES[func] || func

    if (this.hasTermsListTarget) {
      const rows = terms.map((t, i) => {
        const termStr = formatTerm(t.coeff, t.power)
        return `<div class="flex justify-between text-sm"><span class="text-gray-500 dark:text-gray-400">n=${i}</span><span class="font-mono">${termStr}</span></div>`
      }).join("")
      this.termsListTarget.innerHTML = rows
    }
  }

  clear() {
    this.resultTarget.textContent = "\u2014"
    if (this.hasTermsListTarget) this.termsListTarget.innerHTML = ""
    if (this.hasFuncDisplayTarget) this.funcDisplayTarget.textContent = ""
  }

  copy() {
    navigator.clipboard.writeText(this.resultTarget.textContent)
  }
}
