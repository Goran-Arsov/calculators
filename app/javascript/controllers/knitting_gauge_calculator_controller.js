import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "stitchesPer4in", "rowsPer4in", "targetWidth", "targetLength",
    "resultStPerIn", "resultRowsPerIn", "resultStPer10cm", "resultRowsPer10cm",
    "resultCastOn", "resultTotalRows"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const st4 = parseFloat(this.stitchesPer4inTarget.value) || 0
    const rw4 = parseFloat(this.rowsPer4inTarget.value) || 0
    const w = parseFloat(this.targetWidthTarget.value) || 0
    const l = parseFloat(this.targetLengthTarget.value) || 0

    if (st4 <= 0 || rw4 <= 0 || w <= 0 || l <= 0) {
      this.clearResults()
      return
    }

    const stPerIn = st4 / 4
    const rowsPerIn = rw4 / 4
    const stPer10cm = stPerIn * (10 / 2.54)
    const rowsPer10cm = rowsPerIn * (10 / 2.54)
    const castOn = Math.round(stPerIn * w)
    const totalRows = Math.round(rowsPerIn * l)

    this.resultStPerInTarget.textContent = stPerIn.toFixed(3)
    this.resultRowsPerInTarget.textContent = rowsPerIn.toFixed(3)
    this.resultStPer10cmTarget.textContent = stPer10cm.toFixed(2)
    this.resultRowsPer10cmTarget.textContent = rowsPer10cm.toFixed(2)
    this.resultCastOnTarget.textContent = castOn.toString()
    this.resultTotalRowsTarget.textContent = totalRows.toString()
  }

  clearResults() {
    this.resultStPerInTarget.textContent = "0"
    this.resultRowsPerInTarget.textContent = "0"
    this.resultStPer10cmTarget.textContent = "0"
    this.resultRowsPer10cmTarget.textContent = "0"
    this.resultCastOnTarget.textContent = "0"
    this.resultTotalRowsTarget.textContent = "0"
  }

  copy() {
    const text = `Knitting Gauge Results:\nCast-On Stitches: ${this.resultCastOnTarget.textContent}\nTotal Rows: ${this.resultTotalRowsTarget.textContent}\nStitches per inch: ${this.resultStPerInTarget.textContent}\nRows per inch: ${this.resultRowsPerInTarget.textContent}\nStitches per 10 cm: ${this.resultStPer10cmTarget.textContent}\nRows per 10 cm: ${this.resultRowsPer10cmTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
