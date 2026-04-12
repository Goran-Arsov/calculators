import { Controller } from "@hotwired/stimulus"

const BASE_GALLONS = 1000
const GALLONS_PER_ADDITIONAL_BEDROOM = 250
const BASE_BEDROOMS = 3
const GALLONS_PER_PERSON_PER_DAY = 75
const MINIMUM_TANK_GALLONS = 1000
const STANDARD_TANK_SIZES = [1000, 1250, 1500, 1750, 2000, 2500, 3000, 3500, 4000, 5000]

export default class extends Controller {
  static targets = ["bedrooms", "occupants", "dailyWater", "garbageDisposal", "hotTub",
    "resultDailyFlow", "resultBedroomBased", "resultFlowBased",
    "resultRequired", "resultRecommended", "resultDrainfield",
    "resultOccupants"]

  calculate() {
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
    const dailyWater = dailyWaterInput !== "" ? parseFloat(dailyWaterInput) : occupants * GALLONS_PER_PERSON_PER_DAY

    let bedroomBasedGallons
    if (bedrooms <= BASE_BEDROOMS) {
      bedroomBasedGallons = BASE_GALLONS
    } else {
      bedroomBasedGallons = BASE_GALLONS + (bedrooms - BASE_BEDROOMS) * GALLONS_PER_ADDITIONAL_BEDROOM
    }

    const flowBasedGallons = Math.ceil(dailyWater * 2)
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

    const drainfieldFt = Math.round(dailyWater / 0.5)

    this.resultDailyFlowTarget.textContent = `${Math.round(dailyWater).toLocaleString()} gal/day`
    this.resultBedroomBasedTarget.textContent = `${bedroomBasedGallons.toLocaleString()} gal`
    this.resultFlowBasedTarget.textContent = `${flowBasedGallons.toLocaleString()} gal`
    this.resultRequiredTarget.textContent = `${requiredGallons.toLocaleString()} gal`
    this.resultRecommendedTarget.textContent = `${recommendedTank.toLocaleString()} gal`
    this.resultDrainfieldTarget.textContent = `${drainfieldFt.toLocaleString()} ft`
    this.resultOccupantsTarget.textContent = occupants
  }

  clearResults() {
    this.resultDailyFlowTarget.textContent = "0 gal/day"
    this.resultBedroomBasedTarget.textContent = "0 gal"
    this.resultFlowBasedTarget.textContent = "0 gal"
    this.resultRequiredTarget.textContent = "0 gal"
    this.resultRecommendedTarget.textContent = "0 gal"
    this.resultDrainfieldTarget.textContent = "0 ft"
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
