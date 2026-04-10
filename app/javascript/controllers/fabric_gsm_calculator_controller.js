import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sampleWeight", "sampleLength", "sampleWidth",
    "resultGsm", "resultOzSqYd", "resultClassification"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const weight = parseFloat(this.sampleWeightTarget.value) || 0
    const length = parseFloat(this.sampleLengthTarget.value) || 0
    const width = parseFloat(this.sampleWidthTarget.value) || 0

    if (weight <= 0 || length <= 0 || width <= 0) {
      this.clearResults()
      return
    }

    const areaM2 = (length * width) / 10000
    const gsm = weight / areaM2
    const ozPerSqYd = gsm * 0.0294935

    this.resultGsmTarget.textContent = gsm.toFixed(2)
    this.resultOzSqYdTarget.textContent = ozPerSqYd.toFixed(3)
    this.resultClassificationTarget.textContent = this.classify(gsm)
  }

  classify(gsm) {
    if (gsm < 100) return "Lightweight (chiffon, voile, organza, muslin)"
    if (gsm < 200) return "Medium-light (poplin, cotton lawn, shirting)"
    if (gsm < 300) return "Medium (quilting cotton, linen, standard t-shirt jersey)"
    if (gsm < 400) return "Medium-heavy (twill, canvas, denim)"
    if (gsm < 600) return "Heavy (upholstery, duck, heavy denim)"
    return "Very heavy (canvas tarp, heavy upholstery)"
  }

  clearResults() {
    this.resultGsmTarget.textContent = "0"
    this.resultOzSqYdTarget.textContent = "0"
    this.resultClassificationTarget.textContent = "—"
  }

  copy() {
    const text = `Fabric GSM:\nGSM: ${this.resultGsmTarget.textContent}\noz/yd²: ${this.resultOzSqYdTarget.textContent}\nClassification: ${this.resultClassificationTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
