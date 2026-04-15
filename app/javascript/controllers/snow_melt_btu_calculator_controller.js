import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, BTU_TO_W } from "utils/units"

const CLIMATE_BTU = { mild: 100, moderate: 125, cold: 150, severe: 200 }
const BACK_LOSS_FACTOR = 1.15

export default class extends Controller {
  static targets = [
    "area", "climate",
    "unitSystem", "areaLabel",
    "resultSurface", "resultTotal", "resultKw", "resultBoiler"
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
    this.areaLabelTarget.textContent = metric ? "Heated area (m²)" : "Heated area (sq ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const aInput = parseFloat(this.areaTarget.value) || 0
    const climate = this.climateTarget.value

    if (aInput <= 0 || !CLIMATE_BTU[climate]) {
      this.clear()
      return
    }

    const areaSqft = metric ? aInput / SQFT_TO_SQM : aInput
    const perSqft = CLIMATE_BTU[climate]
    const surfaceBtu = areaSqft * perSqft
    const totalBtu = surfaceBtu * BACK_LOSS_FACTOR
    const totalW = totalBtu * BTU_TO_W
    const totalKw = totalW / 1000
    const boilerInput = totalBtu / 0.85

    const fmt = (btu) => {
      const w = btu * BTU_TO_W
      return metric
        ? `${w.toFixed(0)} W (${btu.toFixed(0)} BTU/hr)`
        : `${btu.toFixed(0)} BTU/hr (${w.toFixed(0)} W)`
    }

    this.resultSurfaceTarget.textContent = fmt(surfaceBtu)
    this.resultTotalTarget.textContent = fmt(totalBtu)
    this.resultKwTarget.textContent = `${totalKw.toFixed(2)} kW`
    this.resultBoilerTarget.textContent = fmt(boilerInput)
  }

  clear() {
    ["Surface","Total","Kw","Boiler"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Snow melt sizing:",
      `Surface load: ${this.resultSurfaceTarget.textContent}`,
      `Total output required: ${this.resultTotalTarget.textContent}`,
      `In kW: ${this.resultKwTarget.textContent}`,
      `Boiler input (85% eff): ${this.resultBoilerTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
