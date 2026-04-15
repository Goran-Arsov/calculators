import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, LB_TO_KG } from "utils/units"

const SHEET_AREA = 32
const SCREWS_PER_SHEET = { wall_standard: 32, wall_strict: 40, ceiling: 48, adhesive: 16 }
const SCREWS_PER_LB = 280

export default class extends Controller {
  static targets = [
    "area", "application", "waste",
    "unitSystem", "areaLabel",
    "resultSheets", "resultScrews", "resultWithWaste", "resultPounds"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const a = parseFloat(this.areaTarget.value)
    if (Number.isFinite(a)) this.areaTarget.value = (toMetric ? a * SQFT_TO_SQM : a / SQFT_TO_SQM).toFixed(1)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.areaLabelTarget.textContent = metric ? "Drywall area (m²)" : "Drywall area (sq ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const aInput = parseFloat(this.areaTarget.value) || 0
    const application = this.applicationTarget.value
    const waste = parseFloat(this.wasteTarget.value) || 0

    if (aInput <= 0 || !SCREWS_PER_SHEET[application]) {
      this.clear()
      return
    }

    const areaSqft = metric ? aInput / SQFT_TO_SQM : aInput
    const sheets = Math.ceil(areaSqft / SHEET_AREA)
    const screwsPerSheet = SCREWS_PER_SHEET[application]
    const totalScrews = sheets * screwsPerSheet
    const withWaste = Math.ceil(Math.round(totalScrews * (1 + waste / 100) * 1e6) / 1e6)
    const poundsNeeded = Math.ceil(withWaste / SCREWS_PER_LB)
    const kgNeeded = poundsNeeded * LB_TO_KG

    this.resultSheetsTarget.textContent = `${sheets} sheets (4×8)`
    this.resultScrewsTarget.textContent = `${totalScrews} (${screwsPerSheet}/sheet)`
    this.resultWithWasteTarget.textContent = `${withWaste} screws`
    this.resultPoundsTarget.textContent = metric
      ? `${(kgNeeded).toFixed(2)} kg (${poundsNeeded} lb)`
      : `${poundsNeeded} lb (${kgNeeded.toFixed(2)} kg)`
  }

  clear() {
    ["Sheets","Screws","WithWaste","Pounds"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Drywall screws:",
      `Sheets: ${this.resultSheetsTarget.textContent}`,
      `Total screws: ${this.resultScrewsTarget.textContent}`,
      `With waste: ${this.resultWithWasteTarget.textContent}`,
      `Pounds needed: ${this.resultPoundsTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
