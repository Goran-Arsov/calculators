import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM } from "utils/units"

const CUBIC_METERS_PER_BF = 0.002359737216

export default class extends Controller {
  static targets = [
    "thickness", "width", "length", "quantity", "price",
    "unitSystem", "thicknessLabel", "widthLabel", "lengthLabel", "priceLabel",
    "volumeHeading", "costHeading",
    "resultBfEach", "resultTotalBf", "resultVolume", "resultLinear", "resultCost"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convertIn = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * IN_TO_CM : n / IN_TO_CM).toFixed(2)
    }
    convertIn(this.thicknessTarget)
    convertIn(this.widthTarget)
    const n = parseFloat(this.lengthTarget.value)
    if (Number.isFinite(n)) this.lengthTarget.value = (toMetric ? n * FT_TO_M : n / FT_TO_M).toFixed(2)
    // Price per BF ≈ price per 0.00236 m³. Flip price per BF ↔ price per m³.
    const p = parseFloat(this.priceTarget.value)
    if (Number.isFinite(p)) {
      this.priceTarget.value = (toMetric ? p / CUBIC_METERS_PER_BF : p * CUBIC_METERS_PER_BF).toFixed(2)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.thicknessLabelTarget.textContent = metric ? "Thickness (cm)" : "Thickness (inches)"
    this.widthLabelTarget.textContent = metric ? "Width (cm)" : "Width (inches)"
    this.lengthLabelTarget.textContent = metric ? "Length (m)" : "Length (ft)"
    this.priceLabelTarget.textContent = metric ? "Price per m³ ($, optional)" : "Price per board foot ($, optional)"
    this.volumeHeadingTarget.textContent = metric ? "Total volume (m³)" : "Total volume (cu ft)"
    this.costHeadingTarget.textContent = "Total cost"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const thicknessInput = parseFloat(this.thicknessTarget.value) || 0
    const widthInput = parseFloat(this.widthTarget.value) || 0
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const quantity = parseInt(this.quantityTarget.value, 10) || 0
    const priceInput = parseFloat(this.priceTarget.value)

    if (thicknessInput <= 0 || widthInput <= 0 || lengthInput <= 0 || quantity < 1) {
      this.clear()
      return
    }

    // Work in imperial internally.
    const thickIn = metric ? thicknessInput / IN_TO_CM : thicknessInput
    const widIn = metric ? widthInput / IN_TO_CM : widthInput
    const lenFt = metric ? lengthInput / FT_TO_M : lengthInput

    const bfEach = (thickIn * widIn * lenFt) / 12
    const totalBf = bfEach * quantity
    const cubicMeters = totalBf * CUBIC_METERS_PER_BF
    const cubicFeet = cubicMeters / 0.028316846592
    const linearFt = lenFt * quantity
    const linearM = linearFt * FT_TO_M

    // Price conversion: if metric mode, price is per m³; convert to per BF internally
    const pricePerBf = Number.isFinite(priceInput) && priceInput > 0
      ? (metric ? priceInput * CUBIC_METERS_PER_BF : priceInput)
      : null
    const totalCost = pricePerBf ? totalBf * pricePerBf : null

    this.resultBfEachTarget.textContent = `${bfEach.toFixed(3)} BF`
    this.resultTotalBfTarget.textContent = `${totalBf.toFixed(2)} BF`

    if (metric) {
      this.resultVolumeTarget.textContent = `${cubicMeters.toFixed(4)} m³ (${cubicFeet.toFixed(2)} cu ft)`
      this.resultLinearTarget.textContent = `${linearM.toFixed(2)} m (${linearFt.toFixed(1)} ft)`
    } else {
      this.resultVolumeTarget.textContent = `${cubicFeet.toFixed(2)} cu ft (${cubicMeters.toFixed(4)} m³)`
      this.resultLinearTarget.textContent = `${linearFt.toFixed(1)} ft (${linearM.toFixed(2)} m)`
    }
    this.resultCostTarget.textContent = totalCost ? `$${totalCost.toFixed(2)}` : "—"
  }

  clear() {
    this.resultBfEachTarget.textContent = "—"
    this.resultTotalBfTarget.textContent = "—"
    this.resultVolumeTarget.textContent = "—"
    this.resultLinearTarget.textContent = "—"
    this.resultCostTarget.textContent = "—"
  }

  copy() {
    const text = [
      "Board Foot Estimate:",
      `BF each: ${this.resultBfEachTarget.textContent}`,
      `Total BF: ${this.resultTotalBfTarget.textContent}`,
      `${this.volumeHeadingTarget.textContent}: ${this.resultVolumeTarget.textContent}`,
      `Linear: ${this.resultLinearTarget.textContent}`,
      `Cost: ${this.resultCostTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
