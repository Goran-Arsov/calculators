import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM, CUFT_TO_CUM, LB_TO_KG } from "utils/units"

// Metric tonne = 1000 kg; US ton = 2000 lb ≈ 907.185 kg.
const POUNDS_PER_US_TON = 2000
const KG_PER_TONNE = 1000
const DEFAULT_DENSITY_LB_PER_CUFT = 145
const TRUCK_TONS = 20

export default class extends Controller {
  static targets = [
    "length", "width", "depth", "density",
    "unitSystem", "lengthLabel", "widthLabel", "depthLabel", "densityLabel",
    "volumeHeading", "weightHeading", "truckHeading",
    "resultArea", "resultVolume", "resultWeight", "resultTrucks"
  ]

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
    // Density: 145 lb/ft³ ↔ 2322.7 kg/m³ (factor 16.0185)
    const d = parseFloat(this.densityTarget.value)
    if (Number.isFinite(d)) {
      this.densityTarget.value = (toMetric ? d * 16.0185 : d / 16.0185).toFixed(1)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Length (m)" : "Length (ft)"
    this.widthLabelTarget.textContent = metric ? "Width (m)" : "Width (ft)"
    this.depthLabelTarget.textContent = metric ? "Depth (cm)" : "Depth (inches)"
    this.densityLabelTarget.textContent = metric ? "Density (kg/m³)" : "Density (lb/ft³)"
    this.volumeHeadingTarget.textContent = metric ? "Volume (m³)" : "Volume (cu yd)"
    this.weightHeadingTarget.textContent = metric ? "Weight (tonnes)" : "Weight (US tons)"
    this.truckHeadingTarget.textContent = "Truckloads (20 t)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const widthInput = parseFloat(this.widthTarget.value) || 0
    const depthInput = parseFloat(this.depthTarget.value) || 0
    const densityInput = parseFloat(this.densityTarget.value)

    if (lengthInput <= 0 || widthInput <= 0 || depthInput <= 0) {
      this.clear()
      return
    }

    // Work in imperial internally.
    const lengthFt = metric ? lengthInput / FT_TO_M : lengthInput
    const widthFt = metric ? widthInput / FT_TO_M : widthInput
    const depthIn = metric ? depthInput / IN_TO_CM : depthInput
    const densityLb = Number.isFinite(densityInput) && densityInput > 0
      ? (metric ? densityInput / 16.0185 : densityInput)
      : DEFAULT_DENSITY_LB_PER_CUFT

    const areaSqft = lengthFt * widthFt
    const cubicFeet = areaSqft * (depthIn / 12)
    const cubicYards = cubicFeet / 27
    const pounds = cubicFeet * densityLb
    const usTons = pounds / POUNDS_PER_US_TON
    const cubicMeters = cubicFeet * CUFT_TO_CUM
    const tonnes = (pounds * LB_TO_KG) / KG_PER_TONNE

    if (metric) {
      this.resultAreaTarget.textContent = `${(areaSqft * 0.09290304).toFixed(2)} m²`
      this.resultVolumeTarget.textContent = `${cubicMeters.toFixed(2)} m³`
      this.resultWeightTarget.textContent = `${tonnes.toFixed(2)} t (${usTons.toFixed(2)} US tons)`
      this.resultTrucksTarget.textContent = Math.ceil(tonnes / TRUCK_TONS)
    } else {
      this.resultAreaTarget.textContent = `${areaSqft.toFixed(0)} sq ft (${(areaSqft * 0.09290304).toFixed(1)} m²)`
      this.resultVolumeTarget.textContent = `${cubicYards.toFixed(2)} cu yd (${cubicMeters.toFixed(2)} m³)`
      this.resultWeightTarget.textContent = `${usTons.toFixed(2)} US tons (${tonnes.toFixed(2)} t)`
      this.resultTrucksTarget.textContent = Math.ceil(usTons / TRUCK_TONS)
    }
  }

  clear() {
    this.resultAreaTarget.textContent = "—"
    this.resultVolumeTarget.textContent = "—"
    this.resultWeightTarget.textContent = "—"
    this.resultTrucksTarget.textContent = "—"
  }

  copy() {
    const text = [
      "Asphalt Estimate:",
      `Area: ${this.resultAreaTarget.textContent}`,
      `${this.volumeHeadingTarget.textContent}: ${this.resultVolumeTarget.textContent}`,
      `${this.weightHeadingTarget.textContent}: ${this.resultWeightTarget.textContent}`,
      `Truckloads: ${this.resultTrucksTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
