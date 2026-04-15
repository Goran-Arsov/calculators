import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM, CUFT_TO_CUM, CUYD_TO_CUM } from "utils/units"

export default class extends Controller {
  static targets = ["length", "width", "depth",
                    "unitSystem", "lengthLabel", "widthLabel", "depthLabel",
                    "cubicFeetHeading", "cubicYardsHeading",
                    "resultCubicFeet", "resultCubicYards", "resultBags60", "resultBags80", "resultBags25kg"]

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
    this.depthLabelTarget.textContent = metric ? "Depth (cm)" : "Depth (inches)"
    this.cubicFeetHeadingTarget.textContent = metric ? "Cubic Meters" : "Cubic Feet"
    this.cubicYardsHeadingTarget.textContent = metric ? "Volume (m³)" : "Cubic Yards"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const widthInput = parseFloat(this.widthTarget.value) || 0
    const depthInput = parseFloat(this.depthTarget.value) || 0

    // Imperial math internally.
    const lengthFt = metric ? lengthInput / FT_TO_M : lengthInput
    const widthFt = metric ? widthInput / FT_TO_M : widthInput
    const depthIn = metric ? depthInput / IN_TO_CM : depthInput

    const cubicFeet = lengthFt * widthFt * (depthIn / 12)
    const cubicYards = cubicFeet / 27
    const bags60 = cubicFeet > 0 ? Math.ceil(cubicFeet / 0.45) : 0
    const bags80 = cubicFeet > 0 ? Math.ceil(cubicFeet / 0.6) : 0
    // 25 kg ≈ 55.1 lb, yielding ~0.4135 cu ft per bag (scaled from the 60 lb / 0.45 cu ft figure).
    const bags25kg = cubicFeet > 0 ? Math.ceil(cubicFeet / 0.4135) : 0

    if (metric) {
      const cubicMeters = cubicFeet * CUFT_TO_CUM
      this.resultCubicFeetTarget.textContent = this.fmt(cubicMeters)
      this.resultCubicYardsTarget.textContent = this.fmt(cubicMeters)
    } else {
      this.resultCubicFeetTarget.textContent = this.fmt(cubicFeet)
      this.resultCubicYardsTarget.textContent = this.fmt(cubicYards)
    }
    this.resultBags60Target.textContent = bags60
    this.resultBags80Target.textContent = bags80
    this.resultBags25kgTarget.textContent = bags25kg
  }

  copy() {
    const cubicFeet = this.resultCubicFeetTarget.textContent
    const cubicYards = this.resultCubicYardsTarget.textContent
    const bags60 = this.resultBags60Target.textContent
    const bags80 = this.resultBags80Target.textContent
    const bags25kg = this.resultBags25kgTarget.textContent
    const cfLabel = this.cubicFeetHeadingTarget.textContent
    const cyLabel = this.cubicYardsHeadingTarget.textContent
    const text = `Concrete Estimate:\n${cfLabel}: ${cubicFeet}\n${cyLabel}: ${cubicYards}\n60 lb Bags: ${bags60}\n80 lb Bags: ${bags80}\n25 kg Bags: ${bags25kg}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
