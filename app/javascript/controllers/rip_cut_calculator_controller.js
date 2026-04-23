import { Controller } from "@hotwired/stimulus"

const INCHES_TO_MM = 25.4

export default class extends Controller {
  static targets = [
    "unitSystem", "boardWidth", "ripWidth", "kerfWidth",
    "boardLabel", "ripLabel", "kerfLabel", "kerfHint",
    "resultNumStrips", "resultMaterialUsed", "resultKerfWaste",
    "resultLeftover", "resultEfficiency"
  ]

  unitChanged() {
    const metric = this.isMetric()
    const pairs = [
      [this.boardWidthTarget, 12, 305],
      [this.ripWidthTarget, 2.5, 64],
      [this.kerfWidthTarget, 0.125, 3.2]
    ]

    for (const [el, impDefault, metricDefault] of pairs) {
      const current = parseFloat(el.value) || 0
      if (current > 0) {
        el.value = metric
          ? (current * INCHES_TO_MM).toFixed(1)
          : (current / INCHES_TO_MM).toFixed(3)
      } else {
        el.value = metric ? metricDefault : impDefault
      }
    }

    if (this.hasBoardLabelTarget) {
      const unit = metric ? "mm" : "inches"
      this.boardLabelTarget.textContent = `Board Width (${unit})`
      this.ripLabelTarget.textContent = `Rip Width (${unit})`
      this.kerfLabelTarget.textContent = `Kerf Width (${unit})`
      this.kerfHintTarget.textContent = metric
        ? "Thin-kerf: 2.4 mm, Standard: 3.2 mm, Full-kerf: 4.0 mm"
        : `Thin-kerf: 0.094 (3/32"), Standard: 0.125 (1/8"), Full-kerf: 0.156 (5/32")`
    }

    this.calculate()
  }

  calculate() {
    const metric = this.isMetric()
    const toIn = (v) => (metric ? v / INCHES_TO_MM : v)

    const boardWidth = toIn(parseFloat(this.boardWidthTarget.value) || 0)
    const ripWidth = toIn(parseFloat(this.ripWidthTarget.value) || 0)
    const kerfWidth = toIn(parseFloat(this.kerfWidthTarget.value) || 0)

    if (boardWidth <= 0 || ripWidth <= 0 || kerfWidth < 0) {
      this.clearResults()
      return
    }

    if (ripWidth > boardWidth) {
      this.resultNumStripsTarget.textContent = "0"
      this.resultMaterialUsedTarget.textContent = this.fmt(0)
      this.resultKerfWasteTarget.textContent = this.fmt(0)
      this.resultLeftoverTarget.textContent = this.fmt(boardWidth)
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
    this.resultMaterialUsedTarget.textContent = this.fmt(materialUsed)
    this.resultKerfWasteTarget.textContent = this.fmt(kerfWaste)
    this.resultLeftoverTarget.textContent = this.fmt(leftover)
    this.resultEfficiencyTarget.textContent = `${efficiency.toFixed(1)}%`
  }

  isMetric() {
    return this.hasUnitSystemTarget && this.unitSystemTarget.value === "metric"
  }

  clearResults() {
    this.resultNumStripsTarget.textContent = "0"
    this.resultMaterialUsedTarget.textContent = this.fmt(0)
    this.resultKerfWasteTarget.textContent = this.fmt(0)
    this.resultLeftoverTarget.textContent = this.fmt(0)
    this.resultEfficiencyTarget.textContent = "0.0%"
  }

  copy() {
    const text = `Rip Cut Estimate:\nNumber of Strips: ${this.resultNumStripsTarget.textContent}\nMaterial Used: ${this.resultMaterialUsedTarget.textContent}\nKerf Waste: ${this.resultKerfWasteTarget.textContent}\nLeftover: ${this.resultLeftoverTarget.textContent}\nEfficiency: ${this.resultEfficiencyTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(inches) {
    const v = Number(inches)
    return `${v.toFixed(4)}" (${(v * INCHES_TO_MM).toFixed(1)} mm)`
  }
}
