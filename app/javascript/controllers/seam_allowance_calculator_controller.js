import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "finishedSize", "seamAllowance", "unit", "seamsPerEdge",
    "resultTotalSa", "resultCutSize", "resultCutSizeIn", "resultCutSizeCm",
    "resultSaIn", "resultSaCm"
  ]

  connect() {
    this.calculate()
  }

  currentUnit() {
    const checked = this.unitTargets.find(t => t.checked)
    return checked ? checked.value : "in"
  }

  calculate() {
    const finishedSize = parseFloat(this.finishedSizeTarget.value) || 0
    const seamAllowance = parseFloat(this.seamAllowanceTarget.value) || 0
    const unit = this.currentUnit()
    const seamsPerEdge = parseInt(this.seamsPerEdgeTarget.value) || 0

    if (finishedSize <= 0 || seamAllowance < 0) {
      this.clearResults()
      return
    }

    const totalSa = seamAllowance * seamsPerEdge
    const cutSize = finishedSize + totalSa

    let cutSizeIn, cutSizeCm, saIn, saCm
    if (unit === "in") {
      cutSizeIn = cutSize
      cutSizeCm = cutSize * 2.54
      saIn = seamAllowance
      saCm = seamAllowance * 2.54
    } else {
      cutSizeCm = cutSize
      cutSizeIn = cutSize / 2.54
      saCm = seamAllowance
      saIn = seamAllowance / 2.54
    }

    const unitLabel = unit === "in" ? "in" : "cm"
    this.resultTotalSaTarget.textContent = `${totalSa.toFixed(4)} ${unitLabel}`
    this.resultCutSizeTarget.textContent = `${cutSize.toFixed(4)} ${unitLabel}`
    this.resultCutSizeInTarget.textContent = `${cutSizeIn.toFixed(4)} in`
    this.resultCutSizeCmTarget.textContent = `${cutSizeCm.toFixed(4)} cm`
    this.resultSaInTarget.textContent = `${saIn.toFixed(4)} in`
    this.resultSaCmTarget.textContent = `${saCm.toFixed(4)} cm`
  }

  clearResults() {
    this.resultTotalSaTarget.textContent = "0"
    this.resultCutSizeTarget.textContent = "0"
    this.resultCutSizeInTarget.textContent = "0"
    this.resultCutSizeCmTarget.textContent = "0"
    this.resultSaInTarget.textContent = "0"
    this.resultSaCmTarget.textContent = "0"
  }

  quickPick(event) {
    const value = event.currentTarget.dataset.value
    const unit = event.currentTarget.dataset.unit
    this.seamAllowanceTarget.value = value
    this.unitTargets.forEach(t => { t.checked = (t.value === unit) })
    this.calculate()
  }

  copy() {
    const text = `Seam Allowance Conversion:\nTotal SA Added: ${this.resultTotalSaTarget.textContent}\nCut Size: ${this.resultCutSizeTarget.textContent}\nCut Size (in): ${this.resultCutSizeInTarget.textContent}\nCut Size (cm): ${this.resultCutSizeCmTarget.textContent}\nSA (in): ${this.resultSaInTarget.textContent}\nSA (cm): ${this.resultSaCmTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
