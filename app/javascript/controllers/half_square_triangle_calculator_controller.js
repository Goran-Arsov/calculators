import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "finishedSize", "method",
    "resultCutSize", "resultCutSizeFraction", "resultNumHsts",
    "resultMethod2", "resultMethod4", "resultMethod8"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const finishedSize = parseFloat(this.finishedSizeTarget.value) || 0
    const method = this.selectedMethod()

    if (finishedSize <= 0 || !method) {
      this.clearResults()
      return
    }

    const cutSize = this.cutSizeFor(method, finishedSize)
    const numHsts = this.hstsFor(method)

    const cut2 = this.cutSizeFor("2_at_a_time", finishedSize)
    const cut4 = this.cutSizeFor("4_at_a_time", finishedSize)
    const cut8 = this.cutSizeFor("8_at_a_time", finishedSize)

    this.resultCutSizeTarget.textContent = `${cutSize.toFixed(4)} (${(cutSize * 25.4).toFixed(1)} mm)`
    this.resultCutSizeFractionTarget.textContent = this.toEighthFraction(cutSize)
    this.resultNumHstsTarget.textContent = numHsts
    this.resultMethod2Target.textContent = this.toEighthFraction(cut2)
    this.resultMethod4Target.textContent = this.toEighthFraction(cut4)
    this.resultMethod8Target.textContent = this.toEighthFraction(cut8)
  }

  selectedMethod() {
    const checked = this.methodTargets.find(el => el.checked)
    return checked ? checked.value : "2_at_a_time"
  }

  cutSizeFor(method, finishedSize) {
    switch (method) {
      case "2_at_a_time": return finishedSize + (7 / 8)
      case "4_at_a_time": return (finishedSize * Math.sqrt(2)) + 1.25
      case "8_at_a_time": return (finishedSize * 2) + 1.75
      default: return 0
    }
  }

  hstsFor(method) {
    switch (method) {
      case "2_at_a_time": return 2
      case "4_at_a_time": return 4
      case "8_at_a_time": return 8
      default: return 0
    }
  }

  toEighthFraction(value) {
    if (!value || value <= 0) return `0" (0 mm)`
    const rounded = Math.round(value * 8) / 8
    const mm = (value * 25.4).toFixed(1)
    let whole = Math.floor(rounded)
    let fractional = rounded - whole
    if (fractional >= 1.0) {
      whole += 1
      fractional = 0
    }
    const eighths = Math.round(fractional * 8)
    const fractionMap = {
      0: null, 1: "1/8", 2: "1/4", 3: "3/8", 4: "1/2",
      5: "5/8", 6: "3/4", 7: "7/8"
    }
    const fracStr = fractionMap[eighths]
    const imp = fracStr === null
      ? `${whole}"`
      : (whole === 0 ? `${fracStr}"` : `${whole} ${fracStr}"`)
    return `${imp} (${mm} mm)`
  }

  clearResults() {
    this.resultCutSizeTarget.textContent = "0 (0 mm)"
    this.resultCutSizeFractionTarget.textContent = `0" (0 mm)`
    this.resultNumHstsTarget.textContent = "0"
    this.resultMethod2Target.textContent = "—"
    this.resultMethod4Target.textContent = "—"
    this.resultMethod8Target.textContent = "—"
  }

  copy() {
    const text = `Half-Square Triangle Estimate:\nCut Square Size: ${this.resultCutSizeFractionTarget.textContent} (${this.resultCutSizeTarget.textContent})\nHSTs per Pair: ${this.resultNumHstsTarget.textContent}\n\nMethod Comparison:\n2 at a time: ${this.resultMethod2Target.textContent}\n4 at a time: ${this.resultMethod4Target.textContent}\n8 at a time: ${this.resultMethod8Target.textContent}`
    navigator.clipboard.writeText(text)
  }
}
