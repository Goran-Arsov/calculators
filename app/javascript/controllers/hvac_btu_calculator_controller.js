import { Controller } from "@hotwired/stimulus"

const BASE_BTU_PER_SQFT = 20
const BASELINE_CEILING = 8
const BTU_PER_WINDOW = 1000

const CLIMATE_MULTIPLIERS = { hot: 1.20, warm: 1.10, moderate: 1.00, cool: 0.95, cold: 0.90 }
const INSULATION_MULTIPLIERS = { poor: 1.30, average: 1.00, good: 0.85 }

export default class extends Controller {
  static targets = [
    "roomSqft", "ceilingHeight", "insulation", "climateZone", "windows",
    "resultBaseBtu", "resultTotalBtu", "resultRecommended", "resultTonnage"
  ]

  calculate() {
    const sqft = parseFloat(this.roomSqftTarget.value) || 0
    const ceiling = parseFloat(this.ceilingHeightTarget.value) || 8
    const insulation = this.insulationTarget.value || "average"
    const climate = this.climateZoneTarget.value || "moderate"
    const windows = parseInt(this.windowsTarget.value) || 0

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

    this.resultBaseBtuTarget.textContent = this.fmtInt(baseBtu)
    this.resultTotalBtuTarget.textContent = this.fmtInt(totalBtu)
    this.resultRecommendedTarget.textContent = this.fmtInt(recommended)
    this.resultTonnageTarget.textContent = tonnage.toFixed(2)
  }

  clearResults() {
    this.resultBaseBtuTarget.textContent = "0"
    this.resultTotalBtuTarget.textContent = "0"
    this.resultRecommendedTarget.textContent = "0"
    this.resultTonnageTarget.textContent = "0"
  }

  copy() {
    const text = `HVAC BTU Estimate:\nBase BTU: ${this.resultBaseBtuTarget.textContent}\nTotal BTU: ${this.resultTotalBtuTarget.textContent}\nRecommended: ${this.resultRecommendedTarget.textContent} BTU\nTonnage: ${this.resultTonnageTarget.textContent} tons`
    navigator.clipboard.writeText(text)
  }

  fmtInt(n) {
    return Number(Math.round(n)).toLocaleString("en-US")
  }
}
