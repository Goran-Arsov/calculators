import { Controller } from "@hotwired/stimulus"
import { CUFT_TO_CUM } from "../utils/units"

const CUBIC_FEET_PER_YARD = 27.0
const BAG_CUBIC_FEET = 1.5

const withCubicMeters = (cubicFeet) =>
  `${cubicFeet.toFixed(2)} cu ft (${(cubicFeet * CUFT_TO_CUM).toFixed(3)} m³)`

export default class extends Controller {
  static targets = [
    "length", "width", "height", "beds",
    "topsoilPct", "compostPct", "aerationPct",
    "resultPerBed", "resultTotalCf", "resultTotalCy", "resultBags",
    "resultTopsoil", "resultCompost", "resultAeration", "resultError"
  ]

  connect() { this.calculate() }

  calculate() {
    const length = parseFloat(this.lengthTarget.value)
    const width = parseFloat(this.widthTarget.value)
    const height = parseFloat(this.heightTarget.value)
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
