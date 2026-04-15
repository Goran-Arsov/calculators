import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM, SQFT_TO_SQM, CUYD_TO_CUM } from "utils/units"

const BASE_DEPTH_IN = 4
const SAND_DEPTH_IN = 1
const CUBIC_FEET_PER_YARD = 27
const SQ_IN_PER_SQ_FT = 144

export default class extends Controller {
  static targets = [
    "patioLength", "patioWidth", "paverLength", "paverWidth", "waste",
    "unitSystem", "patioLengthLabel", "patioWidthLabel", "paverLengthLabel", "paverWidthLabel",
    "areaHeading", "baseHeading", "sandHeading",
    "resultArea", "resultPavers", "resultPaversWaste", "resultBase", "resultSand"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(2)
    }
    convert(this.patioLengthTarget, FT_TO_M)
    convert(this.patioWidthTarget, FT_TO_M)
    convert(this.paverLengthTarget, IN_TO_CM)
    convert(this.paverWidthTarget, IN_TO_CM)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.patioLengthLabelTarget.textContent = metric ? "Patio length (m)" : "Patio length (ft)"
    this.patioWidthLabelTarget.textContent = metric ? "Patio width (m)" : "Patio width (ft)"
    this.paverLengthLabelTarget.textContent = metric ? "Paver length (cm)" : "Paver length (inches)"
    this.paverWidthLabelTarget.textContent = metric ? "Paver width (cm)" : "Paver width (inches)"
    this.areaHeadingTarget.textContent = metric ? "Patio area (m²)" : "Patio area (sq ft)"
    this.baseHeadingTarget.textContent = metric ? "Base gravel (m³)" : "Base gravel (cu yd)"
    this.sandHeadingTarget.textContent = metric ? "Leveling sand (m³)" : "Leveling sand (cu yd)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const patioLengthInput = parseFloat(this.patioLengthTarget.value) || 0
    const patioWidthInput = parseFloat(this.patioWidthTarget.value) || 0
    const paverLengthInput = parseFloat(this.paverLengthTarget.value) || 0
    const paverWidthInput = parseFloat(this.paverWidthTarget.value) || 0
    const waste = parseFloat(this.wasteTarget.value)

    if (patioLengthInput <= 0 || patioWidthInput <= 0 ||
        paverLengthInput <= 0 || paverWidthInput <= 0 ||
        !Number.isFinite(waste) || waste < 0) {
      this.clear()
      return
    }

    // Work in imperial internally.
    const patioLenFt = metric ? patioLengthInput / FT_TO_M : patioLengthInput
    const patioWidFt = metric ? patioWidthInput / FT_TO_M : patioWidthInput
    const paverLenIn = metric ? paverLengthInput / IN_TO_CM : paverLengthInput
    const paverWidIn = metric ? paverWidthInput / IN_TO_CM : paverWidthInput

    const patioAreaSqft = patioLenFt * patioWidFt
    const paverAreaSqft = (paverLenIn * paverWidIn) / SQ_IN_PER_SQ_FT
    const rawPavers = patioAreaSqft / paverAreaSqft
    const paversExact = Math.ceil(rawPavers)
    // Round to 6 decimals before ceil to avoid float drift (100 × 1.1 = 110.0000001).
    const paversWithWaste = Math.ceil(Math.round(rawPavers * (1 + waste / 100) * 1e6) / 1e6)

    const baseCuyd = patioAreaSqft * (BASE_DEPTH_IN / 12) / CUBIC_FEET_PER_YARD
    const sandCuyd = patioAreaSqft * (SAND_DEPTH_IN / 12) / CUBIC_FEET_PER_YARD

    if (metric) {
      const patioAreaM2 = patioAreaSqft * SQFT_TO_SQM
      const baseCum = baseCuyd * CUYD_TO_CUM
      const sandCum = sandCuyd * CUYD_TO_CUM
      this.resultAreaTarget.textContent = `${patioAreaM2.toFixed(2)} m² (${patioAreaSqft.toFixed(0)} sq ft)`
      this.resultBaseTarget.textContent = `${baseCum.toFixed(2)} m³ (${baseCuyd.toFixed(2)} cu yd)`
      this.resultSandTarget.textContent = `${sandCum.toFixed(2)} m³ (${sandCuyd.toFixed(2)} cu yd)`
    } else {
      const patioAreaM2 = patioAreaSqft * SQFT_TO_SQM
      const baseCum = baseCuyd * CUYD_TO_CUM
      const sandCum = sandCuyd * CUYD_TO_CUM
      this.resultAreaTarget.textContent = `${patioAreaSqft.toFixed(0)} sq ft (${patioAreaM2.toFixed(2)} m²)`
      this.resultBaseTarget.textContent = `${baseCuyd.toFixed(2)} cu yd (${baseCum.toFixed(2)} m³)`
      this.resultSandTarget.textContent = `${sandCuyd.toFixed(2)} cu yd (${sandCum.toFixed(2)} m³)`
    }
    this.resultPaversTarget.textContent = paversExact
    this.resultPaversWasteTarget.textContent = paversWithWaste
  }

  clear() {
    this.resultAreaTarget.textContent = "—"
    this.resultPaversTarget.textContent = "—"
    this.resultPaversWasteTarget.textContent = "—"
    this.resultBaseTarget.textContent = "—"
    this.resultSandTarget.textContent = "—"
  }

  copy() {
    const text = [
      "Paver Estimate:",
      `${this.areaHeadingTarget.textContent}: ${this.resultAreaTarget.textContent}`,
      `Pavers needed: ${this.resultPaversTarget.textContent}`,
      `Pavers with waste: ${this.resultPaversWasteTarget.textContent}`,
      `${this.baseHeadingTarget.textContent}: ${this.resultBaseTarget.textContent}`,
      `${this.sandHeadingTarget.textContent}: ${this.resultSandTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
