import { Controller } from "@hotwired/stimulus"
import { GAL_TO_L, FT_TO_M } from "utils/units"

const BASE_GALLONS = 1000
const GALLONS_PER_ADDITIONAL_BEDROOM = 250
const BASE_BEDROOMS = 3
const GALLONS_PER_PERSON_PER_DAY = 75
const MINIMUM_TANK_GALLONS = 1000
const STANDARD_TANK_SIZES = [1000, 1250, 1500, 1750, 2000, 2500, 3000, 3500, 4000, 5000]

export default class extends Controller {
  static targets = [
    "bedrooms", "occupants", "dailyWater", "garbageDisposal", "hotTub",
    "unitSystem", "waterLabel",
    "resultDailyFlow", "resultBedroomBased", "resultFlowBased",
    "resultRequired", "resultRecommended", "resultDrainfield",
    "resultOccupants"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(0)
    }
    convert(this.dailyWaterTarget, GAL_TO_L)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.waterLabelTarget.textContent = metric ? "Daily Water Usage (L, optional)" : "Daily Water Usage (gal, optional)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const bedrooms = parseInt(this.bedroomsTarget.value) || 0
    const occupantsInput = this.occupantsTarget.value.trim()
    const dailyWaterInput = this.dailyWaterTarget.value.trim()
    const hasGarbageDisposal = this.garbageDisposalTarget.checked
    const hasHotTub = this.hotTubTarget.checked

    if (bedrooms < 1) {
      this.clearResults()
      return
    }

    const occupants = occupantsInput !== "" ? parseInt(occupantsInput) : bedrooms * 2
    // All canonical math in gallons
    let dailyWaterGal
    if (dailyWaterInput !== "") {
      const val = parseFloat(dailyWaterInput)
      dailyWaterGal = metric ? val / GAL_TO_L : val
    } else {
      dailyWaterGal = occupants * GALLONS_PER_PERSON_PER_DAY
    }

    let bedroomBasedGallons
    if (bedrooms <= BASE_BEDROOMS) {
      bedroomBasedGallons = BASE_GALLONS
    } else {
      bedroomBasedGallons = BASE_GALLONS + (bedrooms - BASE_BEDROOMS) * GALLONS_PER_ADDITIONAL_BEDROOM
    }

    const flowBasedGallons = Math.ceil(dailyWaterGal * 2)
    let requiredGallons = Math.max(bedroomBasedGallons, flowBasedGallons, MINIMUM_TANK_GALLONS)

    if (hasGarbageDisposal) requiredGallons = Math.ceil(requiredGallons * 1.10)
    if (hasHotTub) requiredGallons = Math.ceil(requiredGallons * 1.10)

    let recommendedTank = STANDARD_TANK_SIZES[STANDARD_TANK_SIZES.length - 1]
    for (const size of STANDARD_TANK_SIZES) {
      if (size >= requiredGallons) {
        recommendedTank = size
        break
      }
    }

    const drainfieldFt = Math.round(dailyWaterGal / 0.5)

    this.resultOccupantsTarget.textContent = occupants

    if (metric) {
      const dailyWaterL = Math.round(dailyWaterGal * GAL_TO_L)
      const bedroomBasedL = Math.round(bedroomBasedGallons * GAL_TO_L)
      const flowBasedL = Math.round(flowBasedGallons * GAL_TO_L)
      const requiredL = Math.round(requiredGallons * GAL_TO_L)
      const recommendedL = Math.round(recommendedTank * GAL_TO_L)
      const drainfieldM = (drainfieldFt * FT_TO_M).toFixed(1)
      this.resultDailyFlowTarget.textContent = `${dailyWaterL.toLocaleString()} L/day`
      this.resultBedroomBasedTarget.textContent = `${bedroomBasedL.toLocaleString()} L`
      this.resultFlowBasedTarget.textContent = `${flowBasedL.toLocaleString()} L`
      this.resultRequiredTarget.textContent = `${requiredL.toLocaleString()} L`
      this.resultRecommendedTarget.textContent = `${recommendedL.toLocaleString()} L`
      this.resultDrainfieldTarget.textContent = `${drainfieldM} m`
    } else {
      this.resultDailyFlowTarget.textContent = `${Math.round(dailyWaterGal).toLocaleString()} gal/day`
      this.resultBedroomBasedTarget.textContent = `${bedroomBasedGallons.toLocaleString()} gal`
      this.resultFlowBasedTarget.textContent = `${flowBasedGallons.toLocaleString()} gal`
      this.resultRequiredTarget.textContent = `${requiredGallons.toLocaleString()} gal`
      this.resultRecommendedTarget.textContent = `${recommendedTank.toLocaleString()} gal`
      this.resultDrainfieldTarget.textContent = `${drainfieldFt.toLocaleString()} ft`
    }
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    const vol = metric ? "L" : "gal"
    const len = metric ? "m" : "ft"
    this.resultDailyFlowTarget.textContent = `0 ${vol}/day`
    this.resultBedroomBasedTarget.textContent = `0 ${vol}`
    this.resultFlowBasedTarget.textContent = `0 ${vol}`
    this.resultRequiredTarget.textContent = `0 ${vol}`
    this.resultRecommendedTarget.textContent = `0 ${vol}`
    this.resultDrainfieldTarget.textContent = `0 ${len}`
    this.resultOccupantsTarget.textContent = "0"
  }

  copy() {
    const daily = this.resultDailyFlowTarget.textContent
    const required = this.resultRequiredTarget.textContent
    const recommended = this.resultRecommendedTarget.textContent
    const drainfield = this.resultDrainfieldTarget.textContent
    const text = `Septic Tank Size Estimate:\nDaily Flow: ${daily}\nRequired: ${required}\nRecommended Tank: ${recommended}\nDrain Field: ${drainfield}`
    navigator.clipboard.writeText(text)
  }
}
