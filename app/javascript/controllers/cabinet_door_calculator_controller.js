import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "doorWidth", "doorHeight", "stileWidth", "railWidth", "tongueDepth", "panelClearance",
    "resultStileLength", "resultStileWidth",
    "resultRailLength", "resultRailWidth",
    "resultPanelWidth", "resultPanelHeight",
    "resultBoardFeet"
  ]

  calculate() {
    const doorWidth = parseFloat(this.doorWidthTarget.value) || 0
    const doorHeight = parseFloat(this.doorHeightTarget.value) || 0
    const stileWidth = parseFloat(this.stileWidthTarget.value) || 0
    const railWidth = parseFloat(this.railWidthTarget.value) || 0
    const tongueDepth = parseFloat(this.tongueDepthTarget.value) || 0
    const panelClearance = parseFloat(this.panelClearanceTarget.value) || 0

    if (doorWidth <= 0 || doorHeight <= 0 || stileWidth <= 0 || railWidth <= 0) {
      this.clearResults()
      return
    }

    if (stileWidth * 2 >= doorWidth || railWidth * 2 >= doorHeight) {
      this.clearResults()
      return
    }

    const stileLength = doorHeight
    const railLength = doorWidth - (2 * stileWidth) + (2 * tongueDepth)
    const panelWidth = doorWidth - (2 * stileWidth) + (2 * tongueDepth) - (2 * panelClearance)
    const panelHeight = doorHeight - (2 * railWidth) + (2 * tongueDepth) - (2 * panelClearance)

    const stilesBf = 2 * (0.75 * stileWidth * (stileLength / 12)) / 12
    const railsBf = 2 * (0.75 * railWidth * (railLength / 12)) / 12
    const panelBf = (0.5 * panelWidth * (panelHeight / 12)) / 12
    const totalBf = stilesBf + railsBf + panelBf

    this.resultStileLengthTarget.textContent = this.inches(stileLength)
    this.resultStileWidthTarget.textContent = this.inches(stileWidth)
    this.resultRailLengthTarget.textContent = this.inches(railLength)
    this.resultRailWidthTarget.textContent = this.inches(railWidth)
    this.resultPanelWidthTarget.textContent = this.inches(panelWidth)
    this.resultPanelHeightTarget.textContent = this.inches(panelHeight)
    this.resultBoardFeetTarget.textContent = totalBf.toFixed(3)
  }

  clearResults() {
    this.resultStileLengthTarget.textContent = this.inches(0)
    this.resultStileWidthTarget.textContent = this.inches(0)
    this.resultRailLengthTarget.textContent = this.inches(0)
    this.resultRailWidthTarget.textContent = this.inches(0)
    this.resultPanelWidthTarget.textContent = this.inches(0)
    this.resultPanelHeightTarget.textContent = this.inches(0)
    this.resultBoardFeetTarget.textContent = "0.000"
  }

  copy() {
    const text = `Shaker Cabinet Door Parts:\nStiles (x2): ${this.resultStileLengthTarget.textContent} x ${this.resultStileWidthTarget.textContent}\nRails (x2): ${this.resultRailLengthTarget.textContent} x ${this.resultRailWidthTarget.textContent}\nPanel: ${this.resultPanelWidthTarget.textContent} x ${this.resultPanelHeightTarget.textContent}\nTotal Board Feet (approx): ${this.resultBoardFeetTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  inches(n) {
    return `${Number(n).toFixed(4)}"`
  }
}
