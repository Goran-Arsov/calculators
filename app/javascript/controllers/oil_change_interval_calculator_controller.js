import { Controller } from "@hotwired/stimulus"
import { MI_TO_KM } from "utils/units"

export default class extends Controller {
  static targets = [
    "oilType", "currentMileage", "lastChangeMileage", "lastChangeDate",
    "dailyMiles", "drivingConditions",
    "unitSystem",
    "currentMileageLabel", "lastChangeMileageLabel", "dailyMilesLabel",
    "recommendedMiles", "recommendedMonths", "milesSinceChange",
    "milesRemaining", "oilLifePct", "nextChangeMileage", "nextChangeDate",
    "overdueWarning"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = Math.round(toMetric ? n * MI_TO_KM : n / MI_TO_KM)
    }
    convert(this.currentMileageTarget)
    convert(this.lastChangeMileageTarget)
    convert(this.dailyMilesTarget)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    if (this.hasCurrentMileageLabelTarget) {
      this.currentMileageLabelTarget.textContent = metric ? "Current Odometer (km)" : "Current Odometer (miles)"
    }
    if (this.hasLastChangeMileageLabelTarget) {
      this.lastChangeMileageLabelTarget.textContent = metric ? "Last Change Distance (km)" : "Last Change Mileage"
    }
    if (this.hasDailyMilesLabelTarget) {
      this.dailyMilesLabelTarget.textContent = metric ? "Average Daily km" : "Average Daily Miles"
    }
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const oilType = this.oilTypeTarget.value
    const currentInput = parseFloat(this.currentMileageTarget.value) || 0
    const lastInput = parseFloat(this.lastChangeMileageTarget.value) || 0
    const lastChangeDate = this.lastChangeDateTarget.value
    const dailyInput = parseFloat(this.dailyMilesTarget.value) || 30
    const conditions = this.drivingConditionsTarget.value

    if (currentInput <= 0 || currentInput < lastInput || !lastChangeDate) {
      this.clearResults()
      return
    }

    // Math internally in miles
    const currentMileage = metric ? currentInput / MI_TO_KM : currentInput
    const lastChangeMileage = metric ? lastInput / MI_TO_KM : lastInput
    const dailyMiles = metric ? dailyInput / MI_TO_KM : dailyInput

    const baseIntervalMiles = { conventional: 3000, synthetic_blend: 5000, full_synthetic: 7500, high_mileage: 5000 }[oilType] || 5000
    const baseIntervalMonths = { conventional: 3, synthetic_blend: 6, full_synthetic: 12, high_mileage: 6 }[oilType] || 6

    const conditionFactor = conditions === "severe" ? 0.5 : conditions === "moderate" ? 0.75 : 1.0

    const recMiles = Math.round(baseIntervalMiles * conditionFactor)
    const recMonths = Math.round(baseIntervalMonths * conditionFactor)

    const milesSince = currentMileage - lastChangeMileage
    const milesRemaining = Math.max(recMiles - milesSince, 0)

    const lastDate = new Date(lastChangeDate)
    const today = new Date()

    const daysUntilByMiles = dailyMiles > 0 ? Math.ceil(milesRemaining / dailyMiles) : 0
    const nextByMiles = new Date(today)
    nextByMiles.setDate(nextByMiles.getDate() + daysUntilByMiles)

    const nextByTime = new Date(lastDate)
    nextByTime.setMonth(nextByTime.getMonth() + recMonths)

    const nextDate = nextByTime < nextByMiles ? nextByTime : nextByMiles
    const nextMileage = lastChangeMileage + recMiles

    const oilLifePct = recMiles > 0 ? Math.max((1 - milesSince / recMiles) * 100, 0) : 0
    const overdue = milesSince > recMiles || today > nextByTime

    const unit = metric ? "km" : "mi"
    const toDisplay = (mi) => metric ? mi * MI_TO_KM : mi

    this.recommendedMilesTarget.textContent = Math.round(toDisplay(recMiles)).toLocaleString() + " " + unit
    this.recommendedMonthsTarget.textContent = recMonths + " months"
    this.milesSinceChangeTarget.textContent = Math.round(toDisplay(milesSince)).toLocaleString() + " " + unit
    this.milesRemainingTarget.textContent = Math.round(toDisplay(milesRemaining)).toLocaleString() + " " + unit
    this.oilLifePctTarget.textContent = oilLifePct.toFixed(1) + "%"
    this.nextChangeMileageTarget.textContent = Math.round(toDisplay(nextMileage)).toLocaleString() + " " + unit
    this.nextChangeDateTarget.textContent = nextDate.toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" })

    if (overdue) {
      this.overdueWarningTarget.classList.remove("hidden")
    } else {
      this.overdueWarningTarget.classList.add("hidden")
    }
  }

  clearResults() {
    const unit = this.unitSystemTarget.value === "metric" ? "km" : "mi"
    this.recommendedMilesTarget.textContent = "0 " + unit
    this.recommendedMonthsTarget.textContent = "0 months"
    this.milesSinceChangeTarget.textContent = "0 " + unit
    this.milesRemainingTarget.textContent = "0 " + unit
    this.oilLifePctTarget.textContent = "0.0%"
    this.nextChangeMileageTarget.textContent = "0 " + unit
    this.nextChangeDateTarget.textContent = "--"
    this.overdueWarningTarget.classList.add("hidden")
  }

  copy() {
    const text = `Recommended Interval: ${this.recommendedMilesTarget.textContent} / ${this.recommendedMonthsTarget.textContent}\nDistance Since Change: ${this.milesSinceChangeTarget.textContent}\nDistance Remaining: ${this.milesRemainingTarget.textContent}\nOil Life: ${this.oilLifePctTarget.textContent}\nNext Change: ${this.nextChangeDateTarget.textContent} at ${this.nextChangeMileageTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
