import { Controller } from "@hotwired/stimulus"
import { BTU_TO_W } from "utils/units"

const TYPES = {
  panel:     { n: 1.30, ratedDtF: 90,  label: "Panel radiator (EN 442, dT 50K)" },
  cast_iron: { n: 1.45, ratedDtF: 100, label: "Cast iron radiator (IBR)" },
  fin_tube:  { n: 1.30, ratedDtF: 115, label: "Copper fin-tube baseboard" }
}

const fToC = (f) => (f - 32) * 5 / 9
const cToF = (c) => c * 9 / 5 + 32

export default class extends Controller {
  static targets = [
    "rated", "type", "supply", "return", "room",
    "unitSystem", "supplyLabel", "returnLabel", "roomLabel",
    "resultLabel", "resultMeanWater", "resultDt", "resultRatio",
    "resultActualBtu", "resultActualW"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    ;[this.supplyTarget, this.returnTarget, this.roomTarget].forEach(el => {
      const t = parseFloat(el.value)
      if (Number.isFinite(t)) el.value = (toMetric ? fToC(t) : cToF(t)).toFixed(1)
    })
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.supplyLabelTarget.textContent = metric ? "Supply water (°C)" : "Supply water (°F)"
    this.returnLabelTarget.textContent = metric ? "Return water (°C)" : "Return water (°F)"
    this.roomLabelTarget.textContent = metric ? "Room temperature (°C)" : "Room temperature (°F)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const rated = parseFloat(this.ratedTarget.value) || 0
    const type = this.typeTarget.value
    const supplyInput = parseFloat(this.supplyTarget.value)
    const returnInput = parseFloat(this.returnTarget.value)
    const roomInput = parseFloat(this.roomTarget.value)

    if (rated <= 0 || !TYPES[type] ||
        !Number.isFinite(supplyInput) || !Number.isFinite(returnInput) || !Number.isFinite(roomInput)) {
      this.clear()
      return
    }

    const supplyF = metric ? cToF(supplyInput) : supplyInput
    const returnF = metric ? cToF(returnInput) : returnInput
    const roomF = metric ? cToF(roomInput) : roomInput

    if (supplyF <= roomF || returnF < roomF || returnF > supplyF) {
      this.clear()
      return
    }

    const info = TYPES[type]
    const meanWaterF = (supplyF + returnF) / 2
    const actualDtF = meanWaterF - roomF
    const ratio = Math.pow(actualDtF / info.ratedDtF, info.n)
    const actualBtu = rated * ratio
    const actualW = actualBtu * BTU_TO_W

    this.resultLabelTarget.textContent = info.label
    this.resultMeanWaterTarget.textContent = metric
      ? `${fToC(meanWaterF).toFixed(1)} °C (${meanWaterF.toFixed(1)} °F)`
      : `${meanWaterF.toFixed(1)} °F (${fToC(meanWaterF).toFixed(1)} °C)`
    this.resultDtTarget.textContent = metric
      ? `${(actualDtF * 5 / 9).toFixed(1)} K (${actualDtF.toFixed(1)} °F)`
      : `${actualDtF.toFixed(1)} °F (${(actualDtF * 5 / 9).toFixed(1)} K)`
    this.resultRatioTarget.textContent = `${(ratio * 100).toFixed(1)}% of rated`
    this.resultActualBtuTarget.textContent = metric
      ? `${actualW.toFixed(0)} W (${actualBtu.toFixed(0)} BTU/hr)`
      : `${actualBtu.toFixed(0)} BTU/hr (${actualW.toFixed(0)} W)`
    this.resultActualWTarget.textContent = `${(actualW / 1000).toFixed(3)} kW`
  }

  clear() {
    ["Label","MeanWater","Dt","Ratio","ActualBtu","ActualW"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Radiator output:",
      `Type: ${this.resultLabelTarget.textContent}`,
      `Mean water: ${this.resultMeanWaterTarget.textContent}`,
      `dT: ${this.resultDtTarget.textContent}`,
      `Capacity ratio: ${this.resultRatioTarget.textContent}`,
      `Actual output: ${this.resultActualBtuTarget.textContent}`,
      `In kW: ${this.resultActualWTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
