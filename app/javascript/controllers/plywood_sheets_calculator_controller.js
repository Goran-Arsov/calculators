import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, SQFT_TO_SQM } from "utils/units"

// Sheet areas in sq ft (width × length). Metric standard is the same
// 4×8 ft sheet sold as 1.22 × 2.44 m outside North America.
const SHEET_AREA = {
  "4x8": 32,
  "4x10": 40,
  "5x10": 50
}
const SHEET_LABEL = {
  "4x8": "4 × 8 ft / 1.22 × 2.44 m",
  "4x10": "4 × 10 ft / 1.22 × 3.05 m",
  "5x10": "5 × 10 ft / 1.52 × 3.05 m"
}

export default class extends Controller {
  static targets = [
    "length", "width", "sheet", "waste",
    "unitSystem", "lengthLabel", "widthLabel",
    "areaHeading",
    "resultArea", "resultSheet", "resultExact", "resultWaste"
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
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Surface length (m)" : "Surface length (ft)"
    this.widthLabelTarget.textContent = metric ? "Surface width (m)" : "Surface width (ft)"
    this.areaHeadingTarget.textContent = metric ? "Total area (m²)" : "Total area (sq ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const widthInput = parseFloat(this.widthTarget.value) || 0
    const sheetType = this.sheetTarget.value
    const waste = parseFloat(this.wasteTarget.value)

    if (lengthInput <= 0 || widthInput <= 0 || !Number.isFinite(waste) || waste < 0) {
      this.clear()
      return
    }

    // Work in imperial internally.
    const lengthFt = metric ? lengthInput / FT_TO_M : lengthInput
    const widthFt = metric ? widthInput / FT_TO_M : widthInput
    const totalSqft = lengthFt * widthFt
    const sheetArea = SHEET_AREA[sheetType] || 32
    const exactSheets = totalSqft / sheetArea
    const fullSheets = Math.ceil(exactSheets)
    const sheetsWithWaste = Math.ceil(Math.round(exactSheets * (1 + waste / 100) * 1e6) / 1e6)

    this.resultSheetTarget.textContent = SHEET_LABEL[sheetType] || sheetType
    if (metric) {
      const totalM2 = totalSqft * SQFT_TO_SQM
      this.resultAreaTarget.textContent = `${totalM2.toFixed(2)} m² (${totalSqft.toFixed(0)} sq ft)`
    } else {
      const totalM2 = totalSqft * SQFT_TO_SQM
      this.resultAreaTarget.textContent = `${totalSqft.toFixed(0)} sq ft (${totalM2.toFixed(2)} m²)`
    }
    this.resultExactTarget.textContent = fullSheets
    this.resultWasteTarget.textContent = sheetsWithWaste
  }

  clear() {
    this.resultAreaTarget.textContent = "—"
    this.resultSheetTarget.textContent = "—"
    this.resultExactTarget.textContent = "—"
    this.resultWasteTarget.textContent = "—"
  }

  copy() {
    const text = [
      "Plywood Sheets:",
      `Sheet size: ${this.resultSheetTarget.textContent}`,
      `${this.areaHeadingTarget.textContent}: ${this.resultAreaTarget.textContent}`,
      `Full sheets: ${this.resultExactTarget.textContent}`,
      `Sheets with waste: ${this.resultWasteTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
