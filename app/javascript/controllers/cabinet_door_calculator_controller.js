import { Controller } from "@hotwired/stimulus"
import { IN_TO_CM } from "utils/units"

export default class extends Controller {
  static targets = [
    "doorWidth", "doorHeight", "stileWidth", "railWidth", "tongueDepth", "panelClearance",
    "unitSystem",
    "doorWidthLabel", "doorHeightLabel", "stileWidthLabel", "railWidthLabel",
    "tongueDepthLabel", "panelClearanceLabel",
    "resultStileLength", "resultStileWidth",
    "resultRailLength", "resultRailWidth",
    "resultPanelWidth", "resultPanelHeight",
    "resultBoardFeet"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor, digits = 4) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(digits)
    }
    convert(this.doorWidthTarget, IN_TO_CM, 2)
    convert(this.doorHeightTarget, IN_TO_CM, 2)
    convert(this.stileWidthTarget, IN_TO_CM, 2)
    convert(this.railWidthTarget, IN_TO_CM, 2)
    convert(this.tongueDepthTarget, IN_TO_CM, 3)
    convert(this.panelClearanceTarget, IN_TO_CM, 3)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    const unit = metric ? "cm" : "inches"
    this.doorWidthLabelTarget.textContent = `Door Width (${unit})`
    this.doorHeightLabelTarget.textContent = `Door Height (${unit})`
    this.stileWidthLabelTarget.textContent = `Stile Width (${unit})`
    this.railWidthLabelTarget.textContent = `Rail Width (${unit})`
    this.tongueDepthLabelTarget.textContent = `Tongue Depth (${unit})`
    this.panelClearanceLabelTarget.textContent = `Panel Clearance per Side (${unit})`
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const doorWidthInput = parseFloat(this.doorWidthTarget.value) || 0
    const doorHeightInput = parseFloat(this.doorHeightTarget.value) || 0
    const stileWidthInput = parseFloat(this.stileWidthTarget.value) || 0
    const railWidthInput = parseFloat(this.railWidthTarget.value) || 0
    const tongueDepthInput = parseFloat(this.tongueDepthTarget.value) || 0
    const panelClearanceInput = parseFloat(this.panelClearanceTarget.value) || 0

    // Math in imperial (inches) internally.
    const doorWidth = metric ? doorWidthInput / IN_TO_CM : doorWidthInput
    const doorHeight = metric ? doorHeightInput / IN_TO_CM : doorHeightInput
    const stileWidth = metric ? stileWidthInput / IN_TO_CM : stileWidthInput
    const railWidth = metric ? railWidthInput / IN_TO_CM : railWidthInput
    const tongueDepth = metric ? tongueDepthInput / IN_TO_CM : tongueDepthInput
    const panelClearance = metric ? panelClearanceInput / IN_TO_CM : panelClearanceInput

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

    this.resultStileLengthTarget.textContent = this.display(stileLength, metric)
    this.resultStileWidthTarget.textContent = this.display(stileWidth, metric)
    this.resultRailLengthTarget.textContent = this.display(railLength, metric)
    this.resultRailWidthTarget.textContent = this.display(railWidth, metric)
    this.resultPanelWidthTarget.textContent = this.display(panelWidth, metric)
    this.resultPanelHeightTarget.textContent = this.display(panelHeight, metric)
    this.resultBoardFeetTarget.textContent = totalBf.toFixed(3)
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    this.resultStileLengthTarget.textContent = this.display(0, metric)
    this.resultStileWidthTarget.textContent = this.display(0, metric)
    this.resultRailLengthTarget.textContent = this.display(0, metric)
    this.resultRailWidthTarget.textContent = this.display(0, metric)
    this.resultPanelWidthTarget.textContent = this.display(0, metric)
    this.resultPanelHeightTarget.textContent = this.display(0, metric)
    this.resultBoardFeetTarget.textContent = "0.000"
  }

  copy() {
    const text = `Shaker Cabinet Door Parts:\nStiles (x2): ${this.resultStileLengthTarget.textContent} x ${this.resultStileWidthTarget.textContent}\nRails (x2): ${this.resultRailLengthTarget.textContent} x ${this.resultRailWidthTarget.textContent}\nPanel: ${this.resultPanelWidthTarget.textContent} x ${this.resultPanelHeightTarget.textContent}\nTotal Board Feet (approx): ${this.resultBoardFeetTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  display(inches, metric) {
    if (metric) {
      return `${(inches * IN_TO_CM).toFixed(2)} cm`
    }
    return `${Number(inches).toFixed(4)}"`
  }
}
