import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["age", "resultMin", "resultMax", "resultRange"]

  connect() { this.calculate() }

  calculate() {
    const age = parseInt(this.ageTarget.value)
    if (!Number.isFinite(age) || age < 14) { this.clear(); return }

    const min = Math.floor(age / 2 + 7)
    const max = Math.floor((age - 7) * 2)

    this.resultMinTarget.textContent = `${min} years`
    this.resultMaxTarget.textContent = `${max} years`
    this.resultRangeTarget.textContent = `${min} – ${max}`
  }

  clear() {
    ["Min","Max","Range"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Acceptable dating age range: ${this.resultRangeTarget.textContent}`)
  }
}
