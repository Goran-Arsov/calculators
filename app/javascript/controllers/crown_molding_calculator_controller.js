import { Controller } from "@hotwired/stimulus"
import { FT_TO_M } from "utils/units"

export default class extends Controller {
  static targets = [
    "length", "width", "doors", "stick", "waste",
    "unitSystem", "lengthLabel", "widthLabel", "doorsLabel", "stickLabel",
    "resultPerimeter", "resultNet", "resultWithWaste", "resultSticks"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * FT_TO_M : n / FT_TO_M).toFixed(2)
    }
    convert(this.lengthTarget)
    convert(this.widthTarget)
    convert(this.doorsTarget)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Room length (m)" : "Room length (ft)"
    this.widthLabelTarget.textContent = metric ? "Room width (m)" : "Room width (ft)"
    this.doorsLabelTarget.textContent = metric ? "Total door openings (m)" : "Total door openings (ft)"
    this.stickLabelTarget.textContent = "Stick length (ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lenInput = parseFloat(this.lengthTarget.value) || 0
    const widInput = parseFloat(this.widthTarget.value) || 0
    const doorsInput = parseFloat(this.doorsTarget.value) || 0
    const stickFt = parseInt(this.stickTarget.value, 10) || 12
    const waste = parseFloat(this.wasteTarget.value) || 0

    if (lenInput <= 0 || widInput <= 0 || doorsInput < 0 || waste < 0) {
      this.clear()
      return
    }

    // Work in imperial internally.
    const lengthFt = metric ? lenInput / FT_TO_M : lenInput
    const widthFt = metric ? widInput / FT_TO_M : widInput
    const doorsFt = metric ? doorsInput / FT_TO_M : doorsInput

    const perimeterFt = 2 * (lengthFt + widthFt)
    const netFt = Math.max(perimeterFt - doorsFt, 0)
    const withWasteFt = netFt * (1 + waste / 100)
    const sticks = Math.ceil(Math.round(withWasteFt / stickFt * 1e6) / 1e6)

    const perimeterM = perimeterFt * FT_TO_M
    const netM = netFt * FT_TO_M
    const withWasteM = withWasteFt * FT_TO_M

    if (metric) {
      this.resultPerimeterTarget.textContent = `${perimeterM.toFixed(2)} m (${perimeterFt.toFixed(1)} ft)`
      this.resultNetTarget.textContent = `${netM.toFixed(2)} m (${netFt.toFixed(1)} ft)`
      this.resultWithWasteTarget.textContent = `${withWasteM.toFixed(2)} m (${withWasteFt.toFixed(1)} ft)`
    } else {
      this.resultPerimeterTarget.textContent = `${perimeterFt.toFixed(1)} ft (${perimeterM.toFixed(2)} m)`
      this.resultNetTarget.textContent = `${netFt.toFixed(1)} ft (${netM.toFixed(2)} m)`
      this.resultWithWasteTarget.textContent = `${withWasteFt.toFixed(1)} ft (${withWasteM.toFixed(2)} m)`
    }
    this.resultSticksTarget.textContent = `${sticks} × ${stickFt} ft sticks`
  }

  clear() {
    ["Perimeter","Net","WithWaste","Sticks"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Crown molding estimate:",
      `Perimeter: ${this.resultPerimeterTarget.textContent}`,
      `Net linear: ${this.resultNetTarget.textContent}`,
      `With waste: ${this.resultWithWasteTarget.textContent}`,
      `Sticks needed: ${this.resultSticksTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
