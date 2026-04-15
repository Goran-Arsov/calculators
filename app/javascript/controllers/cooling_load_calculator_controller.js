import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, BTU_TO_W } from "utils/units"

const PEAK_SOLAR = { s: 150, e: 200, w: 200, n: 40 }
const PEOPLE_SENSIBLE_BTU = 300
const WATTS_TO_BTU_HR = 3.412
const R_IMP_TO_SI = 0.17611
const U_SI_TO_IP = 5.678263
const fToC = (f) => (f - 32) * 5 / 9
const cToF = (c) => c * 9 / 5 + 32

export default class extends Controller {
  static targets = [
    "wallArea", "wallR", "roofArea", "roofR",
    "windowArea", "windowU", "windowShgc", "orientation",
    "people", "watts",
    "indoorT", "outdoorT", "infil",
    "unitSystem",
    "wallAreaLabel", "wallRLabel", "roofAreaLabel", "roofRLabel",
    "windowAreaLabel", "windowULabel", "indoorLabel", "outdoorLabel",
    "resultWalls", "resultRoof", "resultWindows", "resultSolar",
    "resultPeople", "resultLights", "resultInfil",
    "resultTotalBtu", "resultTons"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convArea = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * SQFT_TO_SQM : n / SQFT_TO_SQM).toFixed(1)
    }
    [this.wallAreaTarget, this.roofAreaTarget, this.windowAreaTarget].forEach(convArea)

    const convR = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * R_IMP_TO_SI : n / R_IMP_TO_SI).toFixed(2)
    }
    convR(this.wallRTarget)
    convR(this.roofRTarget)

    const u = parseFloat(this.windowUTarget.value)
    if (Number.isFinite(u)) this.windowUTarget.value = (toMetric ? u * U_SI_TO_IP : u / U_SI_TO_IP).toFixed(2)

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
    this.wallRLabelTarget.textContent = metric ? "Wall R (m²·K/W)" : "Wall R-value"
    this.roofRLabelTarget.textContent = metric ? "Roof R (m²·K/W)" : "Roof R-value"
    this.windowULabelTarget.textContent = metric ? "Window U (W/m²·K)" : "Window U (BTU/h·ft²·°F)"
    this.indoorLabelTarget.textContent = metric ? "Indoor design temp (°C)" : "Indoor design temp (°F)"
    this.outdoorLabelTarget.textContent = metric ? "Outdoor design temp (°C)" : "Outdoor design temp (°F)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const wallArea = parseFloat(this.wallAreaTarget.value) || 0
    const wallR = parseFloat(this.wallRTarget.value) || 0
    const roofArea = parseFloat(this.roofAreaTarget.value) || 0
    const roofR = parseFloat(this.roofRTarget.value) || 0
    const windowArea = parseFloat(this.windowAreaTarget.value) || 0
    const windowU = parseFloat(this.windowUTarget.value) || 0
    const shgc = parseFloat(this.windowShgcTarget.value) || 0
    const orient = this.orientationTarget.value
    const people = parseInt(this.peopleTarget.value, 10) || 0
    const watts = parseFloat(this.wattsTarget.value) || 0
    const indoorT = parseFloat(this.indoorTTarget.value)
    const outdoorT = parseFloat(this.outdoorTTarget.value)
    const infilCfm = parseFloat(this.infilTarget.value) || 0

    if (wallArea <= 0 || wallR <= 0 || roofArea <= 0 || roofR <= 0 ||
        windowU <= 0 || shgc < 0 || shgc > 1 ||
        !PEAK_SOLAR[orient] ||
        !Number.isFinite(indoorT) || !Number.isFinite(outdoorT) || outdoorT <= indoorT) {
      this.clear()
      return
    }

    const wallAreaSqft = metric ? wallArea / SQFT_TO_SQM : wallArea
    const roofAreaSqft = metric ? roofArea / SQFT_TO_SQM : roofArea
    const windowAreaSqft = metric ? windowArea / SQFT_TO_SQM : windowArea
    const wallRImp = metric ? wallR / R_IMP_TO_SI : wallR
    const roofRImp = metric ? roofR / R_IMP_TO_SI : roofR
    const windowUImp = metric ? windowU / U_SI_TO_IP : windowU
    const indoorF = metric ? cToF(indoorT) : indoorT
    const outdoorF = metric ? cToF(outdoorT) : outdoorT

    const dt = outdoorF - indoorF
    const netWall = Math.max(wallAreaSqft - windowAreaSqft, 0)
    const walls = (1 / wallRImp) * netWall * dt
    const roof = (1 / roofRImp) * roofAreaSqft * dt
    const windowsCond = windowUImp * windowAreaSqft * dt
    const solar = windowAreaSqft * shgc * PEAK_SOLAR[orient]
    const peopleGain = people * PEOPLE_SENSIBLE_BTU
    const lights = watts * WATTS_TO_BTU_HR
    const infil = 1.08 * infilCfm * dt
    const total = walls + roof + windowsCond + solar + peopleGain + lights + infil
    const totalW = total * BTU_TO_W
    const tons = total / 12000

    const fmt = (btu) => {
      const w = btu * BTU_TO_W
      return metric ? `${w.toFixed(0)} W (${btu.toFixed(0)} BTU/hr)` : `${btu.toFixed(0)} BTU/hr (${w.toFixed(0)} W)`
    }

    this.resultWallsTarget.textContent = fmt(walls)
    this.resultRoofTarget.textContent = fmt(roof)
    this.resultWindowsTarget.textContent = fmt(windowsCond)
    this.resultSolarTarget.textContent = fmt(solar)
    this.resultPeopleTarget.textContent = fmt(peopleGain)
    this.resultLightsTarget.textContent = fmt(lights)
    this.resultInfilTarget.textContent = fmt(infil)
    this.resultTotalBtuTarget.textContent = metric
      ? `${totalW.toFixed(0)} W (${total.toFixed(0)} BTU/hr)`
      : `${total.toFixed(0)} BTU/hr (${totalW.toFixed(0)} W)`
    this.resultTonsTarget.textContent = `${tons.toFixed(2)} tons (${(totalW / 1000).toFixed(2)} kW)`
  }

  clear() {
    ["Walls","Roof","Windows","Solar","People","Lights","Infil","TotalBtu","Tons"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Cooling load:",
      `Walls: ${this.resultWallsTarget.textContent}`,
      `Roof: ${this.resultRoofTarget.textContent}`,
      `Windows (conduction): ${this.resultWindowsTarget.textContent}`,
      `Windows (solar): ${this.resultSolarTarget.textContent}`,
      `People: ${this.resultPeopleTarget.textContent}`,
      `Lighting: ${this.resultLightsTarget.textContent}`,
      `Infiltration: ${this.resultInfilTarget.textContent}`,
      `Total: ${this.resultTotalBtuTarget.textContent}`,
      `AC size: ${this.resultTonsTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
