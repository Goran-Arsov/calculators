import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM, SQFT_TO_SQM, CUYD_TO_CUM, LB_TO_KG } from "utils/units"

export default class extends Controller {
  static targets = ["length", "width", "depth",
                    "unitSystem", "lengthLabel", "widthLabel", "depthLabel",
                    "areaHeading", "volumeHeading", "weightHeading",
                    "resultArea", "resultCubicYards", "resultTons"]

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
    convert(this.depthTarget, IN_TO_CM)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Length (m)" : "Length (ft)"
    this.widthLabelTarget.textContent = metric ? "Width (m)" : "Width (ft)"
    this.depthLabelTarget.textContent = metric ? "Depth (cm)" : "Depth (in)"
    this.areaHeadingTarget.textContent = metric ? "Area (m²)" : "Area"
    this.volumeHeadingTarget.textContent = metric ? "Volume (m³)" : "Cubic Yards"
    this.weightHeadingTarget.textContent = metric ? "Tonnes (Gravel)" : "Tons (Gravel)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const widthInput = parseFloat(this.widthTarget.value) || 0
    const depthInput = parseFloat(this.depthTarget.value) || 0

    // Imperial math internally (ft, ft, in).
    const length = metric ? lengthInput / FT_TO_M : lengthInput
    const width = metric ? widthInput / FT_TO_M : widthInput
    const depth = metric ? depthInput / IN_TO_CM : depthInput

    const area = length * width
    const cubicYards = (length * width * depth) / 324
    const tons = cubicYards * 1.4

    if (metric) {
      const areaM2 = area * SQFT_TO_SQM
      const cubicMeters = cubicYards * CUYD_TO_CUM
      // 1 US ton = 0.907185 metric tonne; tons here are US tons.
      const tonnes = tons * 0.90718474
      this.resultAreaTarget.textContent = `${this.fmt(areaM2)} m²`
      this.resultCubicYardsTarget.textContent = this.fmt(cubicMeters)
      this.resultTonsTarget.textContent = this.fmt(tonnes)
    } else {
      this.resultAreaTarget.textContent = `${this.fmt(area)} sq ft`
      this.resultCubicYardsTarget.textContent = this.fmt(cubicYards)
      this.resultTonsTarget.textContent = this.fmt(tons)
    }
  }

  copy() {
    const area = this.resultAreaTarget.textContent
    const cubicYards = this.resultCubicYardsTarget.textContent
    const tons = this.resultTonsTarget.textContent
    const volumeLabel = this.volumeHeadingTarget.textContent
    const weightLabel = this.weightHeadingTarget.textContent
    const text = `Gravel & Mulch Estimate:\nArea: ${area}\n${volumeLabel}: ${cubicYards}\n${weightLabel}: ${tons}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
