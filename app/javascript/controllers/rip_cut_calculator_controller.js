import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "boardWidth", "ripWidth", "kerfWidth",
    "resultNumStrips", "resultMaterialUsed", "resultKerfWaste",
    "resultLeftover", "resultEfficiency"
  ]

  calculate() {
    const boardWidth = parseFloat(this.boardWidthTarget.value) || 0
    const ripWidth = parseFloat(this.ripWidthTarget.value) || 0
    const kerfWidth = parseFloat(this.kerfWidthTarget.value) || 0

    if (boardWidth <= 0 || ripWidth <= 0 || kerfWidth < 0) {
      this.clearResults()
      return
    }

    if (ripWidth > boardWidth) {
      this.resultNumStripsTarget.textContent = "0"
      this.resultMaterialUsedTarget.textContent = this.inches(0)
      this.resultKerfWasteTarget.textContent = this.inches(0)
      this.resultLeftoverTarget.textContent = this.inches(boardWidth)
      this.resultEfficiencyTarget.textContent = "0.0%"
      return
    }

    const numStrips = Math.floor((boardWidth + kerfWidth) / (ripWidth + kerfWidth))
    const cuts = Math.max(numStrips - 1, 0)
    const materialUsed = numStrips * ripWidth + cuts * kerfWidth
    const kerfWaste = cuts * kerfWidth
    const leftover = boardWidth - materialUsed
    const efficiency = (numStrips * ripWidth) / boardWidth * 100

    this.resultNumStripsTarget.textContent = numStrips.toString()
    this.resultMaterialUsedTarget.textContent = this.inches(materialUsed)
    this.resultKerfWasteTarget.textContent = this.inches(kerfWaste)
    this.resultLeftoverTarget.textContent = this.inches(leftover)
    this.resultEfficiencyTarget.textContent = `${efficiency.toFixed(1)}%`
  }

  clearResults() {
    this.resultNumStripsTarget.textContent = "0"
    this.resultMaterialUsedTarget.textContent = this.inches(0)
    this.resultKerfWasteTarget.textContent = this.inches(0)
    this.resultLeftoverTarget.textContent = this.inches(0)
    this.resultEfficiencyTarget.textContent = "0.0%"
  }

  copy() {
    const text = `Rip Cut Estimate:\nNumber of Strips: ${this.resultNumStripsTarget.textContent}\nMaterial Used: ${this.resultMaterialUsedTarget.textContent}\nKerf Waste: ${this.resultKerfWasteTarget.textContent}\nLeftover: ${this.resultLeftoverTarget.textContent}\nEfficiency: ${this.resultEfficiencyTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  inches(n) {
    return `${Number(n).toFixed(4)}"`
  }
}
