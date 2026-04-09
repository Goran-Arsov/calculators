import { Controller } from "@hotwired/stimulus"

const WATTS_PER_SQFT_LIGHTING = 3
const SMALL_APPLIANCE_WATTS = 3000
const LAUNDRY_WATTS = 1500
const RANGE_WATTS = 8000
const DRYER_WATTS = 5000
const WATER_HEATER_WATTS = 4500
const WATTS_PER_AC_TON = 3517
const WATTS_PER_SQFT_HEAT = 10
const VOLTAGE = 240
const DEMAND_FACTOR_FIRST = 3000
const DEMAND_FACTOR_REMAINDER_RATE = 0.35

export default class extends Controller {
  static targets = ["squareFootage", "hasElectricRange", "hasElectricDryer", "hasElectricWaterHeater",
    "acTons", "hasElectricHeat",
    "resultGeneralLighting", "resultTotalLoad", "resultTotalAmps", "resultPanelSize"]

  calculate() {
    const sqft = parseFloat(this.squareFootageTarget.value) || 0
    const hasRange = this.hasElectricRangeTarget.checked
    const hasDryer = this.hasElectricDryerTarget.checked
    const hasWaterHeater = this.hasElectricWaterHeaterTarget.checked
    const acTons = parseFloat(this.acTonsTarget.value) || 0
    const hasHeat = this.hasElectricHeatTarget.checked

    const generalLighting = sqft * WATTS_PER_SQFT_LIGHTING
    const generalLoad = generalLighting + SMALL_APPLIANCE_WATTS + LAUNDRY_WATTS

    let demandAdjusted
    if (generalLoad <= DEMAND_FACTOR_FIRST) {
      demandAdjusted = generalLoad
    } else {
      demandAdjusted = DEMAND_FACTOR_FIRST + ((generalLoad - DEMAND_FACTOR_FIRST) * DEMAND_FACTOR_REMAINDER_RATE)
    }

    let totalWatts = demandAdjusted

    if (hasRange) totalWatts += RANGE_WATTS
    if (hasDryer) totalWatts += DRYER_WATTS
    if (hasWaterHeater) totalWatts += WATER_HEATER_WATTS

    const acWatts = acTons * WATTS_PER_AC_TON
    const heatWatts = hasHeat ? sqft * WATTS_PER_SQFT_HEAT : 0
    totalWatts += Math.max(acWatts, heatWatts)

    const totalAmps = (totalWatts / VOLTAGE).toFixed(1)

    let panelSize
    if (totalAmps <= 100) panelSize = 100
    else if (totalAmps <= 150) panelSize = 150
    else if (totalAmps <= 200) panelSize = 200
    else panelSize = 400

    this.resultGeneralLightingTarget.textContent = `${this.fmt(generalLighting)} W`
    this.resultTotalLoadTarget.textContent = `${this.fmt(totalWatts)} W`
    this.resultTotalAmpsTarget.textContent = `${totalAmps} A`
    this.resultPanelSizeTarget.textContent = `${panelSize} A`
  }

  copy() {
    const lighting = this.resultGeneralLightingTarget.textContent
    const totalLoad = this.resultTotalLoadTarget.textContent
    const amps = this.resultTotalAmpsTarget.textContent
    const panel = this.resultPanelSizeTarget.textContent
    const text = `Electrical Load Estimate:\nGeneral Lighting: ${lighting}\nTotal Load: ${totalLoad}\nTotal Amps (240V): ${amps}\nRecommended Panel: ${panel}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Math.round(n).toLocaleString("en-US")
  }
}
