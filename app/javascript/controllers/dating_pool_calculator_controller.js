import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["population", "ageMin", "ageMax", "gender", "resultAge", "resultGender", "resultSingle", "resultCompatible", "resultMutual"]

  connect() { this.calculate() }

  calculate() {
    const pop = parseFloat(this.populationTarget.value)
    const min = parseInt(this.ageMinTarget.value)
    const max = parseInt(this.ageMaxTarget.value)
    const genderPct = parseFloat(this.genderTarget.value)
    if (!Number.isFinite(pop) || pop <= 0 || min < 18 || max < min) { this.clear(); return }

    const years = max - min + 1
    const inAge = pop * years * 0.015
    const ofGender = inAge * genderPct
    const single = ofGender * 0.45
    const compat = single * 0.20
    const mutual = compat * 0.10

    this.resultAgeTarget.textContent = Math.round(inAge).toLocaleString()
    this.resultGenderTarget.textContent = Math.round(ofGender).toLocaleString()
    this.resultSingleTarget.textContent = Math.round(single).toLocaleString()
    this.resultCompatibleTarget.textContent = Math.round(compat).toLocaleString()
    this.resultMutualTarget.textContent = Math.round(mutual).toLocaleString()
  }

  clear() {
    ["Age","Gender","Single","Compatible","Mutual"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Dating pool: ${this.resultMutualTarget.textContent} potential matches`)
  }
}
