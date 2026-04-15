import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, CUFT_TO_CUM, CUYD_TO_CUM } from "utils/units"

const CUBIC_FEET_PER_YARD = 27
const TRUCK_CUYD = 10

export default class extends Controller {
  static targets = [
    "length", "width", "depth", "shape", "swell",
    "unitSystem", "lengthLabel", "widthLabel", "depthLabel",
    "bankHeading", "looseHeading", "truckHeading",
    "widthRow",
    "resultBank", "resultLoose", "resultTrucks"
  ]

  connect() {
    this.updateLabels()
    this.toggleWidth()
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
    convert(this.depthTarget, FT_TO_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    const circle = this.shapeTarget.value === "circular"
    this.lengthLabelTarget.textContent = circle
      ? (metric ? "Diameter (m)" : "Diameter (ft)")
      : (metric ? "Length (m)" : "Length (ft)")
    this.widthLabelTarget.textContent = metric ? "Width (m)" : "Width (ft)"
    this.depthLabelTarget.textContent = metric ? "Depth (m)" : "Depth (ft)"
    this.bankHeadingTarget.textContent = metric ? "Bank volume (m³)" : "Bank volume (cu yd)"
    this.looseHeadingTarget.textContent = metric ? "Loose volume (m³)" : "Loose volume (cu yd)"
    this.truckHeadingTarget.textContent = metric ? "Truckloads (7.6 m³)" : "Truckloads (10 cu yd)"
  }

  toggleWidth() {
    const circle = this.shapeTarget.value === "circular"
    this.widthRowTarget.classList.toggle("hidden", circle)
    this.updateLabels()
    this.calculate()
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const shape = this.shapeTarget.value
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const widthInput = parseFloat(this.widthTarget.value) || 0
    const depthInput = parseFloat(this.depthTarget.value) || 0
    const swell = parseFloat(this.swellTarget.value)

    if (lengthInput <= 0 || depthInput <= 0 ||
        (shape === "rectangular" && widthInput <= 0) ||
        !Number.isFinite(swell) || swell < 0) {
      this.clear()
      return
    }

    // Work in imperial internally.
    const lengthFt = metric ? lengthInput / FT_TO_M : lengthInput
    const widthFt = metric ? widthInput / FT_TO_M : widthInput
    const depthFt = metric ? depthInput / FT_TO_M : depthInput

    let bankCuft
    if (shape === "circular") {
      const radius = lengthFt / 2
      bankCuft = Math.PI * radius * radius * depthFt
    } else {
      bankCuft = lengthFt * widthFt * depthFt
    }

    const bankCuyd = bankCuft / CUBIC_FEET_PER_YARD
    const looseCuyd = bankCuyd * (1 + swell / 100)
    const bankCum = bankCuft * CUFT_TO_CUM
    const looseCum = looseCuyd * CUYD_TO_CUM

    if (metric) {
      this.resultBankTarget.textContent = `${bankCum.toFixed(2)} m³ (${bankCuyd.toFixed(2)} cu yd)`
      this.resultLooseTarget.textContent = `${looseCum.toFixed(2)} m³ (${looseCuyd.toFixed(2)} cu yd)`
      // 10 cu yd truck ≈ 7.6 m³
      this.resultTrucksTarget.textContent = Math.ceil(looseCum / (TRUCK_CUYD * CUYD_TO_CUM))
    } else {
      this.resultBankTarget.textContent = `${bankCuyd.toFixed(2)} cu yd (${bankCum.toFixed(2)} m³)`
      this.resultLooseTarget.textContent = `${looseCuyd.toFixed(2)} cu yd (${looseCum.toFixed(2)} m³)`
      this.resultTrucksTarget.textContent = Math.ceil(looseCuyd / TRUCK_CUYD)
    }
  }

  clear() {
    this.resultBankTarget.textContent = "—"
    this.resultLooseTarget.textContent = "—"
    this.resultTrucksTarget.textContent = "—"
  }

  copy() {
    const text = [
      "Excavation Estimate:",
      `${this.bankHeadingTarget.textContent}: ${this.resultBankTarget.textContent}`,
      `${this.looseHeadingTarget.textContent}: ${this.resultLooseTarget.textContent}`,
      `${this.truckHeadingTarget.textContent}: ${this.resultTrucksTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
