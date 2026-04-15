import { Controller } from "@hotwired/stimulus"

const SEER_TO_SEER2 = 0.96
const EER_TO_EER2 = 0.954
const HSPF_TO_HSPF2 = 0.85

function toSeer(value, type) {
  switch (type) {
    case "seer":  return value
    case "seer2": return value / SEER_TO_SEER2
    case "eer":   return value * 1.12
    case "eer2":  return (value / EER_TO_EER2) * 1.12
    case "hspf":  return value
    case "hspf2": return value / HSPF_TO_HSPF2
    case "cop":   return value * 3.412
    default:      return null
  }
}

export default class extends Controller {
  static targets = [
    "value", "type",
    "resultSeer", "resultSeer2", "resultEer", "resultEer2",
    "resultHspf", "resultHspf2", "resultCop"
  ]

  connect() { this.calculate() }

  calculate() {
    const value = parseFloat(this.valueTarget.value) || 0
    const type = this.typeTarget.value
    if (value <= 0) {
      this.clear()
      return
    }
    const seer = toSeer(value, type)
    if (seer === null) {
      this.clear()
      return
    }
    const seer2 = seer * SEER_TO_SEER2
    const eer = seer / 1.12
    const eer2 = eer * EER_TO_EER2
    const hspf = seer
    const hspf2 = hspf * HSPF_TO_HSPF2
    const cop = seer / 3.412

    this.resultSeerTarget.textContent = seer.toFixed(2)
    this.resultSeer2Target.textContent = seer2.toFixed(2)
    this.resultEerTarget.textContent = eer.toFixed(2)
    this.resultEer2Target.textContent = eer2.toFixed(2)
    this.resultHspfTarget.textContent = hspf.toFixed(2)
    this.resultHspf2Target.textContent = hspf2.toFixed(2)
    this.resultCopTarget.textContent = cop.toFixed(2)
  }

  clear() {
    ["Seer","Seer2","Eer","Eer2","Hspf","Hspf2","Cop"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Efficiency ratings:",
      `SEER: ${this.resultSeerTarget.textContent}`,
      `SEER2: ${this.resultSeer2Target.textContent}`,
      `EER: ${this.resultEerTarget.textContent}`,
      `EER2: ${this.resultEer2Target.textContent}`,
      `HSPF: ${this.resultHspfTarget.textContent}`,
      `HSPF2: ${this.resultHspf2Target.textContent}`,
      `COP: ${this.resultCopTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
