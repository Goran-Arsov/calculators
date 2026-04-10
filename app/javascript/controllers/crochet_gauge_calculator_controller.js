import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "stitchesPer4in", "rowsPer4in", "targetWidth", "targetLength", "startingChainExtra",
    "resultStPerIn", "resultRowsPerIn", "resultStPer10cm", "resultRowsPer10cm",
    "resultBaseStitches", "resultStartingChain", "resultTotalRows"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const st4 = parseFloat(this.stitchesPer4inTarget.value) || 0
    const rw4 = parseFloat(this.rowsPer4inTarget.value) || 0
    const w = parseFloat(this.targetWidthTarget.value) || 0
    const l = parseFloat(this.targetLengthTarget.value) || 0
    const extra = parseInt(this.startingChainExtraTarget.value) || 0

    if (st4 <= 0 || rw4 <= 0 || w <= 0 || l <= 0 || extra < 0) {
      this.clearResults()
      return
    }

    const stPerIn = st4 / 4
    const rowsPerIn = rw4 / 4
    const stPer10cm = stPerIn * (10 / 2.54)
    const rowsPer10cm = rowsPerIn * (10 / 2.54)
    const baseStitches = Math.round(stPerIn * w)
    const startingChain = baseStitches + extra
    const totalRows = Math.round(rowsPerIn * l)

    this.resultStPerInTarget.textContent = stPerIn.toFixed(3)
    this.resultRowsPerInTarget.textContent = rowsPerIn.toFixed(3)
    this.resultStPer10cmTarget.textContent = stPer10cm.toFixed(2)
    this.resultRowsPer10cmTarget.textContent = rowsPer10cm.toFixed(2)
    this.resultBaseStitchesTarget.textContent = baseStitches.toString()
    this.resultStartingChainTarget.textContent = startingChain.toString()
    this.resultTotalRowsTarget.textContent = totalRows.toString()
  }

  clearResults() {
    this.resultStPerInTarget.textContent = "0"
    this.resultRowsPerInTarget.textContent = "0"
    this.resultStPer10cmTarget.textContent = "0"
    this.resultRowsPer10cmTarget.textContent = "0"
    this.resultBaseStitchesTarget.textContent = "0"
    this.resultStartingChainTarget.textContent = "0"
    this.resultTotalRowsTarget.textContent = "0"
  }

  copy() {
    const text = `Crochet Gauge Results:\nStarting Chain: ${this.resultStartingChainTarget.textContent}\nTotal Rows: ${this.resultTotalRowsTarget.textContent}\nBase Stitches: ${this.resultBaseStitchesTarget.textContent}\nStitches per inch: ${this.resultStPerInTarget.textContent}\nRows per inch: ${this.resultRowsPerInTarget.textContent}\nStitches per 10 cm: ${this.resultStPer10cmTarget.textContent}\nRows per 10 cm: ${this.resultRowsPer10cmTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
