import { Controller } from "@hotwired/stimulus"
import { CUFT_TO_CUM, FT_TO_M, IN_TO_CM } from "../utils/units"

const CUBIC_FEET_PER_YARD = 27.0
const BAG_CUBIC_FEET = 1.5
const IMPERIAL_DEFAULTS = { length: 8, width: 4, height: 12 }
const METRIC_DEFAULTS = { length: 2.4, width: 1.2, height: 30 }

const withCubicMeters = (cubicFeet) =>
  `${cubicFeet.toFixed(2)} cu ft (${(cubicFeet * CUFT_TO_CUM).toFixed(3)} m³)`

export default class extends Controller {
  static targets = [
    "unitSystem", "length", "width", "height", "beds",
    "topsoilPct", "compostPct", "aerationPct",
    "lengthLabel", "widthLabel", "heightLabel",
    "resultPerBed", "resultTotalCf", "resultTotalCy", "resultBags",
    "resultTopsoil", "resultCompost", "resultAeration", "resultError"
  ]

  connect() { this.calculate() }

  unitChanged() {
    const metric = this.isMetric()
    const inputs = [
      [this.lengthTarget, IMPERIAL_DEFAULTS.length, METRIC_DEFAULTS.length, FT_TO_M],
      [this.widthTarget, IMPERIAL_DEFAULTS.width, METRIC_DEFAULTS.width, FT_TO_M],
      [this.heightTarget, IMPERIAL_DEFAULTS.height, METRIC_DEFAULTS.height, IN_TO_CM]
    ]

    for (const [el, impDefault, metricDefault, factor] of inputs) {
      const current = parseFloat(el.value) || 0
      if (current > 0) {
        el.value = metric ? (current * factor).toFixed(2) : (current / factor).toFixed(2)
      } else {
        el.value = metric ? metricDefault : impDefault
      }
    }

    if (this.hasLengthLabelTarget) {
      this.lengthLabelTarget.textContent = metric ? "Length (m)" : "Length (ft)"
      this.widthLabelTarget.textContent = metric ? "Width (m)" : "Width (ft)"
      this.heightLabelTarget.textContent = metric ? "Height (cm)" : "Height (inches)"
    }

    this.calculate()
  }

  calculate() {
    const metric = this.isMetric()
    const length = metric
      ? (parseFloat(this.lengthTarget.value) || 0) / FT_TO_M
      : (parseFloat(this.lengthTarget.value) || 0)
    const width = metric
      ? (parseFloat(this.widthTarget.value) || 0) / FT_TO_M
      : (parseFloat(this.widthTarget.value) || 0)
    const height = metric
      ? (parseFloat(this.heightTarget.value) || 0) / IN_TO_CM
      : (parseFloat(this.heightTarget.value) || 0)
    const beds = parseInt(this.bedsTarget.value, 10)
    const topPct = parseFloat(this.topsoilPctTarget.value)
    const comPct = parseFloat(this.compostPctTarget.value)
    const aerPct = parseFloat(this.aerationPctTarget.value)

    if (!Number.isFinite(length) || length <= 0 ||
        !Number.isFinite(width) || width <= 0 ||
        !Number.isFinite(height) || height <= 0 ||
        !Number.isFinite(beds) || beds < 1) {
      this.clear()
      return
    }

    const sum = topPct + comPct + aerPct
    if (Math.abs(sum - 100) > 1) {
      this.resultErrorTarget.textContent = `Mix must total 100% (currently ${sum.toFixed(0)}%)`
      this.resultErrorTarget.classList.remove("hidden")
    } else {
      this.resultErrorTarget.textContent = ""
      this.resultErrorTarget.classList.add("hidden")
    }

    const perBedCf = length * width * (height / 12.0)
    const totalCf = perBedCf * beds
    const totalCy = totalCf / CUBIC_FEET_PER_YARD
    const bags = Math.ceil(totalCf / BAG_CUBIC_FEET)

    this.resultPerBedTarget.textContent = withCubicMeters(perBedCf)
    this.resultTotalCfTarget.textContent = withCubicMeters(totalCf)
    this.resultTotalCyTarget.textContent = `${totalCy.toFixed(2)} cu yd (${(totalCf * CUFT_TO_CUM).toFixed(3)} m³)`
    this.resultBagsTarget.textContent = `${bags}`
    this.resultTopsoilTarget.textContent = withCubicMeters(totalCf * topPct / 100)
    this.resultCompostTarget.textContent = withCubicMeters(totalCf * comPct / 100)
    this.resultAerationTarget.textContent = withCubicMeters(totalCf * aerPct / 100)
  }

  isMetric() {
    return this.hasUnitSystemTarget && this.unitSystemTarget.value === "metric"
  }

  clear() {
    this.resultPerBedTarget.textContent = "—"
    this.resultTotalCfTarget.textContent = "—"
    this.resultTotalCyTarget.textContent = "—"
    this.resultBagsTarget.textContent = "—"
    this.resultTopsoilTarget.textContent = "—"
    this.resultCompostTarget.textContent = "—"
    this.resultAerationTarget.textContent = "—"
  }

  copy() {
    const text = [
      "Raised bed soil:",
      `Per bed: ${this.resultPerBedTarget.textContent}`,
      `Total: ${this.resultTotalCfTarget.textContent}`,
      `Total (yards): ${this.resultTotalCyTarget.textContent}`,
      `Bags (1.5 cu ft): ${this.resultBagsTarget.textContent}`,
      `Topsoil: ${this.resultTopsoilTarget.textContent}`,
      `Compost: ${this.resultCompostTarget.textContent}`,
      `Aeration: ${this.resultAerationTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
