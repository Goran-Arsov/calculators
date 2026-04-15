import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, FT_TO_M, BTU_TO_W } from "utils/units"

const BTU_PER_SQFT = { concrete: 32, tile: 27, wood: 22, carpet: 14 }
const SPACING_FACTOR = { 6: 2.0, 9: 1.33, 12: 1.0 }
const MAX_LOOP_FT = { "3/8": 200, "1/2": 300, "5/8": 400 }

export default class extends Controller {
  static targets = [
    "area", "spacing", "surface", "tubeSize",
    "unitSystem", "areaLabel",
    "resultTotalTube", "resultLoops", "resultLoopLength", "resultBtu", "resultKw"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const a = parseFloat(this.areaTarget.value)
    if (Number.isFinite(a)) this.areaTarget.value = (toMetric ? a * SQFT_TO_SQM : a / SQFT_TO_SQM).toFixed(0)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.areaLabelTarget.textContent = metric ? "Floor area (m²)" : "Floor area (sq ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const aInput = parseFloat(this.areaTarget.value) || 0
    const spacing = parseInt(this.spacingTarget.value, 10)
    const surface = this.surfaceTarget.value
    const tube = this.tubeSizeTarget.value

    if (aInput <= 0 || !SPACING_FACTOR[spacing] || !BTU_PER_SQFT[surface] || !MAX_LOOP_FT[tube]) {
      this.clear()
      return
    }

    const areaSqft = metric ? aInput / SQFT_TO_SQM : aInput
    const tubePerSqft = SPACING_FACTOR[spacing]
    const totalTubeFt = areaSqft * tubePerSqft * 1.10
    const maxLoop = MAX_LOOP_FT[tube]
    const loopCount = Math.max(Math.ceil(totalTubeFt / maxLoop), 1)
    const loopLenFt = totalTubeFt / loopCount
    const btuPerSqft = BTU_PER_SQFT[surface]
    const totalBtu = areaSqft * btuPerSqft
    const totalWatts = totalBtu * BTU_TO_W
    const kw = totalWatts / 1000

    const totalTubeM = totalTubeFt * FT_TO_M
    const loopLenM = loopLenFt * FT_TO_M

    if (metric) {
      this.resultTotalTubeTarget.textContent = `${totalTubeM.toFixed(0)} m (${totalTubeFt.toFixed(0)} ft)`
      this.resultLoopLengthTarget.textContent = `${loopLenM.toFixed(0)} m / loop (${loopLenFt.toFixed(0)} ft / loop)`
      this.resultBtuTarget.textContent = `${totalWatts.toFixed(0)} W (${totalBtu.toFixed(0)} BTU/hr)`
    } else {
      this.resultTotalTubeTarget.textContent = `${totalTubeFt.toFixed(0)} ft (${totalTubeM.toFixed(0)} m)`
      this.resultLoopLengthTarget.textContent = `${loopLenFt.toFixed(0)} ft / loop (${loopLenM.toFixed(0)} m / loop)`
      this.resultBtuTarget.textContent = `${totalBtu.toFixed(0)} BTU/hr (${totalWatts.toFixed(0)} W)`
    }
    this.resultLoopsTarget.textContent = loopCount
    this.resultKwTarget.textContent = `${kw.toFixed(2)} kW`
  }

  clear() {
    ["TotalTube","Loops","LoopLength","Btu","Kw"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Radiant floor heat:",
      `Total PEX tube: ${this.resultTotalTubeTarget.textContent}`,
      `Number of loops: ${this.resultLoopsTarget.textContent}`,
      `Length per loop: ${this.resultLoopLengthTarget.textContent}`,
      `Heat output: ${this.resultBtuTarget.textContent}`,
      `In kilowatts: ${this.resultKwTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
