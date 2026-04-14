import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, SQFT_TO_SQM } from "utils/units"

const SQ_FT_PER_BOX = 25

export default class extends Controller {
  static targets = ["length", "width", "waste",
                    "unitSystem", "lengthLabel", "widthLabel", "areaHeading", "areaWasteHeading",
                    "resultArea", "resultAreaWaste", "resultBoxes"]

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
    convert(this.lengthTarget, FT_TO_M)
    convert(this.widthTarget, FT_TO_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Room Length (m)" : "Room Length (ft)"
    this.widthLabelTarget.textContent = metric ? "Room Width (m)" : "Room Width (ft)"
    this.areaHeadingTarget.textContent = metric ? "Area (m²)" : "Area"
    this.areaWasteHeadingTarget.textContent = metric ? "Area with Waste (m²)" : "Area with Waste"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const widthInput = parseFloat(this.widthTarget.value) || 0
    const waste = parseFloat(this.wasteTarget.value) || 10

    // Imperial math internally.
    const length = metric ? lengthInput / FT_TO_M : lengthInput
    const width = metric ? widthInput / FT_TO_M : widthInput

    const area = length * width
    const areaWaste = area * (1 + waste / 100)
    const boxes = areaWaste > 0 ? Math.ceil(areaWaste / SQ_FT_PER_BOX) : 0

    if (metric) {
      const areaM2 = area * SQFT_TO_SQM
      const areaWasteM2 = areaWaste * SQFT_TO_SQM
      this.resultAreaTarget.textContent = `${this.fmt(areaM2)} m²`
      this.resultAreaWasteTarget.textContent = `${this.fmt(areaWasteM2)} m²`
    } else {
      this.resultAreaTarget.textContent = `${this.fmt(area)} sq ft`
      this.resultAreaWasteTarget.textContent = `${this.fmt(areaWaste)} sq ft`
    }
    this.resultBoxesTarget.textContent = boxes
  }

  copy() {
    const area = this.resultAreaTarget.textContent
    const areaWaste = this.resultAreaWasteTarget.textContent
    const boxes = this.resultBoxesTarget.textContent
    const text = `Flooring Estimate:\nArea: ${area}\nArea with Waste: ${areaWaste}\nBoxes Needed: ${boxes}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
