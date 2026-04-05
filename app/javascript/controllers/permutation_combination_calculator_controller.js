import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["n", "r", "permutation", "combination", "nFactorial", "rFactorial", "nMinusRFactorial", "formula"]

  calculate() {
    const n = parseInt(this.nTarget.value)
    const r = parseInt(this.rTarget.value)

    if (isNaN(n) || isNaN(r) || n < 0 || r < 0 || r > n) {
      this.clearResults()
      return
    }

    const nFact = this.factorial(n)
    const rFact = this.factorial(r)
    const nrFact = this.factorial(n - r)

    const perm = nFact / nrFact
    const comb = nFact / (rFact * nrFact)

    this.permutationTarget.textContent = this.fmtBig(perm)
    this.combinationTarget.textContent = this.fmtBig(comb)
    this.nFactorialTarget.textContent = this.fmtBig(nFact)
    this.rFactorialTarget.textContent = this.fmtBig(rFact)
    this.nMinusRFactorialTarget.textContent = this.fmtBig(nrFact)
    this.formulaTarget.innerHTML = `P(${n},${r}) = ${n}! / ${n - r}! = ${this.fmtBig(perm)}<br>C(${n},${r}) = ${n}! / (${r}! &times; ${n - r}!) = ${this.fmtBig(comb)}`
  }

  factorial(num) {
    if (num <= 1) return 1
    let result = 1
    for (let i = 2; i <= num; i++) result *= i
    return result
  }

  clearResults() {
    this.permutationTarget.textContent = "—"
    this.combinationTarget.textContent = "—"
    this.nFactorialTarget.textContent = "—"
    this.rFactorialTarget.textContent = "—"
    this.nMinusRFactorialTarget.textContent = "—"
    this.formulaTarget.textContent = "—"
  }

  fmtBig(n) {
    if (n > Number.MAX_SAFE_INTEGER) return n.toExponential(4)
    return n.toLocaleString()
  }

  fmt(n) {
    if (n >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const p = this.permutationTarget.textContent
    const c = this.combinationTarget.textContent
    navigator.clipboard.writeText(`Permutation P(n,r): ${p}\nCombination C(n,r): ${c}`)
  }
}
