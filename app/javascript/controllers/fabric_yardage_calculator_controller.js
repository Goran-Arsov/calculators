import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "pieceLength", "pieceWidth", "numPieces", "fabricWidth", "repeat",
    "resultPiecesAcross", "resultRowsNeeded", "resultLengthIn",
    "resultYards", "resultMeters"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const pieceLength = parseFloat(this.pieceLengthTarget.value) || 0
    const pieceWidth = parseFloat(this.pieceWidthTarget.value) || 0
    const numPieces = parseInt(this.numPiecesTarget.value) || 0
    const fabricWidth = parseFloat(this.fabricWidthTarget.value) || 0
    const repeat = parseFloat(this.repeatTarget.value) || 0

    if (pieceLength <= 0 || pieceWidth <= 0 || numPieces < 1 || fabricWidth <= 0 || repeat < 0) {
      this.clearResults()
      return
    }

    const piecesAcross = Math.floor(fabricWidth / pieceWidth)
    if (piecesAcross === 0) {
      this.clearResults()
      this.resultPiecesAcrossTarget.textContent = "—"
      return
    }

    const rowsNeeded = Math.ceil(numPieces / piecesAcross)
    const effectiveLength = repeat > 0
      ? Math.ceil(pieceLength / repeat) * repeat
      : pieceLength
    const totalLengthIn = rowsNeeded * effectiveLength
    const totalYards = totalLengthIn / 36
    const totalMeters = totalLengthIn * 0.0254

    this.resultPiecesAcrossTarget.textContent = piecesAcross
    this.resultRowsNeededTarget.textContent = rowsNeeded
    this.resultLengthInTarget.textContent = `${totalLengthIn.toFixed(2)} in`
    this.resultYardsTarget.textContent = totalYards.toFixed(3)
    this.resultMetersTarget.textContent = totalMeters.toFixed(3)
  }

  clearResults() {
    this.resultPiecesAcrossTarget.textContent = "0"
    this.resultRowsNeededTarget.textContent = "0"
    this.resultLengthInTarget.textContent = "0 in"
    this.resultYardsTarget.textContent = "0"
    this.resultMetersTarget.textContent = "0"
  }

  copy() {
    const text = `Fabric Yardage Estimate:\nPieces Across: ${this.resultPiecesAcrossTarget.textContent}\nRows Needed: ${this.resultRowsNeededTarget.textContent}\nTotal Length: ${this.resultLengthInTarget.textContent}\nTotal Yards: ${this.resultYardsTarget.textContent}\nTotal Meters: ${this.resultMetersTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
