import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, SQFT_TO_SQM, BTU_TO_W } from "utils/units"

const BASE_BTU_PER_SQFT = 20
const BASELINE_CEILING = 8
const BTU_PER_WINDOW = 1000

const CLIMATE_MULTIPLIERS = { hot: 1.20, warm: 1.10, moderate: 1.00, cool: 0.95, cold: 0.90 }
const INSULATION_MULTIPLIERS = { poor: 1.30, average: 1.00, good: 0.85 }

export default class extends Controller {
  static targets = [
    "roomSqft", "ceilingHeight", "insulation", "climateZone", "windows",
    "unitSystem", "roomSqftLabel", "ceilingHeightLabel",
    "baseHeading", "totalHeading", "recommendedHeading",
    "resultBaseBtu", "resultTotalBtu", "resultRecommended", "resultTonnage"
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
    convert(this.roomSqftTarget, SQFT_TO_SQM)
    convert(this.ceilingHeightTarget, FT_TO_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.roomSqftLabelTarget.textContent = metric ? "Room Size (m²)" : "Room Size (sq ft)"
    this.ceilingHeightLabelTarget.textContent = metric ? "Ceiling Height (m)" : "Ceiling Height (ft)"
    this.baseHeadingTarget.textContent = metric ? "Base Power" : "Base BTU"
    this.totalHeadingTarget.textContent = metric ? "Adjusted Power" : "Adjusted BTU"
    this.recommendedHeadingTarget.textContent = metric ? "Recommended" : "Recommended"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const sqftInput = parseFloat(this.roomSqftTarget.value) || 0
    const ceilingInput = parseFloat(this.ceilingHeightTarget.value) || (metric ? 8 * FT_TO_M : 8)
    const insulation = this.insulationTarget.value || "average"
    const climate = this.climateZoneTarget.value || "moderate"
    const windows = parseInt(this.windowsTarget.value) || 0

    // Imperial math internally.
    const sqft = metric ? sqftInput / SQFT_TO_SQM : sqftInput
    const ceiling = metric ? ceilingInput / FT_TO_M : ceilingInput

    if (sqft <= 0) {
      this.clearResults()
      return
    }

    const baseBtu = sqft * BASE_BTU_PER_SQFT
    const ceilingFactor = ceiling / BASELINE_CEILING
    let adjusted = baseBtu * ceilingFactor

    const climateMult = CLIMATE_MULTIPLIERS[climate] || 1.0
    adjusted *= climateMult

    const insulationMult = INSULATION_MULTIPLIERS[insulation] || 1.0
    adjusted *= insulationMult

    const windowBtu = windows * BTU_PER_WINDOW
    const totalBtu = adjusted + windowBtu
    const recommended = Math.ceil(totalBtu / 1000) * 1000
    const tonnage = recommended / 12000

    if (metric) {
      this.resultBaseBtuTarget.textContent = `${this.fmtInt(baseBtu * BTU_TO_W)} W`
      this.resultTotalBtuTarget.textContent = `${this.fmtInt(totalBtu * BTU_TO_W)} W`
      this.resultRecommendedTarget.textContent = `${this.fmtInt(recommended * BTU_TO_W)} W`
      // Tonnage is also expressed in kW for metric.
      this.resultTonnageTarget.textContent = `${(recommended * BTU_TO_W / 1000).toFixed(2)} kW`
    } else {
      this.resultBaseBtuTarget.textContent = this.fmtInt(baseBtu)
      this.resultTotalBtuTarget.textContent = this.fmtInt(totalBtu)
      this.resultRecommendedTarget.textContent = this.fmtInt(recommended)
      this.resultTonnageTarget.textContent = tonnage.toFixed(2)
    }
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    const unit = metric ? " W" : ""
    this.resultBaseBtuTarget.textContent = `0${unit}`
    this.resultTotalBtuTarget.textContent = `0${unit}`
    this.resultRecommendedTarget.textContent = `0${unit}`
    this.resultTonnageTarget.textContent = metric ? "0 kW" : "0"
  }

  copy() {
    const text = `HVAC BTU Estimate:\nBase: ${this.resultBaseBtuTarget.textContent}\nTotal: ${this.resultTotalBtuTarget.textContent}\nRecommended: ${this.resultRecommendedTarget.textContent}\nTonnage: ${this.resultTonnageTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmtInt(n) {
    return Number(Math.round(n)).toLocaleString("en-US")
  }
}
