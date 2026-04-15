import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, CUFT_TO_CUM, BTU_TO_W } from "utils/units"

const fToC = (f) => (f - 32) * 5 / 9
const cToF = (c) => c * 9 / 5 + 32
// R-value metric (m²·K/W) ↔ imperial (ft²·°F·h/BTU) factor
const R_IMP_TO_SI = 0.17611  // R-SI = R-IP × 0.17611
const U_SI_TO_IP = 5.678263 // U-IP = U-SI × 5.678 (W/m²K → BTU/h·ft²·°F)

export default class extends Controller {
  static targets = [
    "wallArea", "wallR",
    "roofArea", "roofR",
    "windowArea", "windowU",
    "floorArea", "floorR",
    "volume", "indoorT", "outdoorT", "ach",
    "unitSystem",
    "wallAreaLabel", "wallRLabel",
    "roofAreaLabel", "roofRLabel",
    "windowAreaLabel", "windowULabel",
    "floorAreaLabel", "floorRLabel",
    "volumeLabel", "indoorLabel", "outdoorLabel",
    "resultWall", "resultRoof", "resultWindow", "resultFloor", "resultInfil",
    "resultTotalBtu", "resultTotalKw"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"

    // Areas sqft ↔ m²
    const convArea = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * SQFT_TO_SQM : n / SQFT_TO_SQM).toFixed(1)
    }
    convArea(this.wallAreaTarget)
    convArea(this.roofAreaTarget)
    convArea(this.windowAreaTarget)
    convArea(this.floorAreaTarget)

    // Volume cuft ↔ m³
    const vol = parseFloat(this.volumeTarget.value)
    if (Number.isFinite(vol)) this.volumeTarget.value = (toMetric ? vol * CUFT_TO_CUM : vol / CUFT_TO_CUM).toFixed(1)

    // R-values IP ↔ SI (factor 0.17611)
    const convR = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * R_IMP_TO_SI : n / R_IMP_TO_SI).toFixed(2)
    }
    convR(this.wallRTarget)
    convR(this.roofRTarget)
    convR(this.floorRTarget)

    // Window U W/m²K ↔ BTU/h·ft²·°F (factor 5.678)
    const u = parseFloat(this.windowUTarget.value)
    if (Number.isFinite(u)) this.windowUTarget.value = (toMetric ? u * U_SI_TO_IP : u / U_SI_TO_IP).toFixed(2)

    // Temperatures °F ↔ °C
    const t1 = parseFloat(this.indoorTTarget.value)
    if (Number.isFinite(t1)) this.indoorTTarget.value = (toMetric ? fToC(t1) : cToF(t1)).toFixed(1)
    const t2 = parseFloat(this.outdoorTTarget.value)
    if (Number.isFinite(t2)) this.outdoorTTarget.value = (toMetric ? fToC(t2) : cToF(t2)).toFixed(1)

    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.wallAreaLabelTarget.textContent = metric ? "Wall area (m²)" : "Wall area (sq ft)"
    this.roofAreaLabelTarget.textContent = metric ? "Roof area (m²)" : "Roof area (sq ft)"
    this.windowAreaLabelTarget.textContent = metric ? "Window area (m²)" : "Window area (sq ft)"
    this.floorAreaLabelTarget.textContent = metric ? "Floor area (m²)" : "Floor area (sq ft)"
    this.wallRLabelTarget.textContent = metric ? "Wall R (m²·K/W)" : "Wall R-value"
    this.roofRLabelTarget.textContent = metric ? "Roof R (m²·K/W)" : "Roof R-value"
    this.floorRLabelTarget.textContent = metric ? "Floor R (m²·K/W)" : "Floor R-value"
    this.windowULabelTarget.textContent = metric ? "Window U (W/m²·K)" : "Window U (BTU/h·ft²·°F)"
    this.volumeLabelTarget.textContent = metric ? "House volume (m³)" : "House volume (cu ft)"
    this.indoorLabelTarget.textContent = metric ? "Indoor design temp (°C)" : "Indoor design temp (°F)"
    this.outdoorLabelTarget.textContent = metric ? "Outdoor design temp (°C)" : "Outdoor design temp (°F)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"

    // Read all inputs; convert to imperial internally.
    const wallArea = parseFloat(this.wallAreaTarget.value) || 0
    const wallR = parseFloat(this.wallRTarget.value) || 0
    const roofArea = parseFloat(this.roofAreaTarget.value) || 0
    const roofR = parseFloat(this.roofRTarget.value) || 0
    const windowArea = parseFloat(this.windowAreaTarget.value) || 0
    const windowU = parseFloat(this.windowUTarget.value) || 0
    const floorArea = parseFloat(this.floorAreaTarget.value) || 0
    const floorR = parseFloat(this.floorRTarget.value) || 0
    const volume = parseFloat(this.volumeTarget.value) || 0
    const indoorT = parseFloat(this.indoorTTarget.value)
    const outdoorT = parseFloat(this.outdoorTTarget.value)
    const ach = parseFloat(this.achTarget.value) || 0

    if (wallArea <= 0 || wallR <= 0 || roofArea <= 0 || roofR <= 0 ||
        windowU <= 0 || floorArea <= 0 || floorR <= 0 || volume <= 0 ||
        !Number.isFinite(indoorT) || !Number.isFinite(outdoorT) || indoorT <= outdoorT) {
      this.clear()
      return
    }

    // Convert everything to imperial for a single math path.
    const wallAreaSqft = metric ? wallArea / SQFT_TO_SQM : wallArea
    const roofAreaSqft = metric ? roofArea / SQFT_TO_SQM : roofArea
    const windowAreaSqft = metric ? windowArea / SQFT_TO_SQM : windowArea
    const floorAreaSqft = metric ? floorArea / SQFT_TO_SQM : floorArea
    const volumeCuft = metric ? volume / CUFT_TO_CUM : volume
    const wallRImp = metric ? wallR / R_IMP_TO_SI : wallR
    const roofRImp = metric ? roofR / R_IMP_TO_SI : roofR
    const floorRImp = metric ? floorR / R_IMP_TO_SI : floorR
    const windowUImp = metric ? windowU / U_SI_TO_IP : windowU
    const indoorF = metric ? cToF(indoorT) : indoorT
    const outdoorF = metric ? cToF(outdoorT) : outdoorT

    const dt = indoorF - outdoorF
    const netWall = Math.max(wallAreaSqft - windowAreaSqft, 0)
    const wallLoss = (1 / wallRImp) * netWall * dt
    const roofLoss = (1 / roofRImp) * roofAreaSqft * dt
    const windowLoss = windowUImp * windowAreaSqft * dt
    const floorLoss = (1 / floorRImp) * floorAreaSqft * dt
    const infilLoss = 0.018 * ach * volumeCuft * dt
    const totalBtu = wallLoss + roofLoss + windowLoss + floorLoss + infilLoss
    const totalWatts = totalBtu * BTU_TO_W
    const totalKw = totalWatts / 1000

    const fmt = (btu) => {
      const w = btu * BTU_TO_W
      return metric ? `${w.toFixed(0)} W (${btu.toFixed(0)} BTU/hr)`
                    : `${btu.toFixed(0)} BTU/hr (${w.toFixed(0)} W)`
    }

    this.resultWallTarget.textContent = fmt(wallLoss)
    this.resultRoofTarget.textContent = fmt(roofLoss)
    this.resultWindowTarget.textContent = fmt(windowLoss)
    this.resultFloorTarget.textContent = fmt(floorLoss)
    this.resultInfilTarget.textContent = fmt(infilLoss)
    this.resultTotalBtuTarget.textContent = metric
      ? `${totalWatts.toFixed(0)} W (${totalBtu.toFixed(0)} BTU/hr)`
      : `${totalBtu.toFixed(0)} BTU/hr (${totalWatts.toFixed(0)} W)`
    this.resultTotalKwTarget.textContent = `${totalKw.toFixed(2)} kW`
  }

  clear() {
    ["Wall","Roof","Window","Floor","Infil","TotalBtu","TotalKw"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Heat loss estimate:",
      `Walls: ${this.resultWallTarget.textContent}`,
      `Roof: ${this.resultRoofTarget.textContent}`,
      `Windows: ${this.resultWindowTarget.textContent}`,
      `Floor: ${this.resultFloorTarget.textContent}`,
      `Infiltration: ${this.resultInfilTarget.textContent}`,
      `Total: ${this.resultTotalBtuTarget.textContent}`,
      `Total kW: ${this.resultTotalKwTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
