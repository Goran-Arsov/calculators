import { Controller } from "@hotwired/stimulus"

const BROWN_C = 50.0
const BROWN_N = 0.5
const GREEN_C = 45.0
const GREEN_N = 2.5
const IDEAL_MIN = 25
const IDEAL_MAX = 30

export default class extends Controller {
  static targets = ["browns", "greens", "resultCarbon", "resultNitrogen", "resultRatio", "resultStatus"]

  connect() { this.calculate() }

  calculate() {
    const browns = parseFloat(this.brownsTarget.value)
    const greens = parseFloat(this.greensTarget.value)

    if (!Number.isFinite(browns) || !Number.isFinite(greens) ||
        browns < 0 || greens <= 0) {
      this.clear()
      return
    }

    const carbon = (browns * BROWN_C / 100) + (greens * GREEN_C / 100)
    const nitrogen = (browns * BROWN_N / 100) + (greens * GREEN_N / 100)
    const ratio = carbon / nitrogen

    this.resultCarbonTarget.textContent = `${carbon.toFixed(2)} lb`
    this.resultNitrogenTarget.textContent = `${nitrogen.toFixed(2)} lb`
    this.resultRatioTarget.textContent = `${ratio.toFixed(1)} : 1`

    let status
    if (ratio < IDEAL_MIN) status = "Too nitrogen-rich — add more browns"
    else if (ratio > IDEAL_MAX) status = "Too carbon-rich — add more greens"
    else status = "Ideal for hot composting"
    this.resultStatusTarget.textContent = status
  }

  clear() {
    this.resultCarbonTarget.textContent = "—"
    this.resultNitrogenTarget.textContent = "—"
    this.resultRatioTarget.textContent = "—"
    this.resultStatusTarget.textContent = "—"
  }

  copy() {
    const text = `Compost C:N ratio:\nCarbon: ${this.resultCarbonTarget.textContent}\nNitrogen: ${this.resultNitrogenTarget.textContent}\nRatio: ${this.resultRatioTarget.textContent}\n${this.resultStatusTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
