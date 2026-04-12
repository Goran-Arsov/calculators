import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "oilType", "currentMileage", "lastChangeMileage", "lastChangeDate",
    "dailyMiles", "drivingConditions",
    "recommendedMiles", "recommendedMonths", "milesSinceChange",
    "milesRemaining", "oilLifePct", "nextChangeMileage", "nextChangeDate",
    "overdueWarning"
  ]

  calculate() {
    const oilType = this.oilTypeTarget.value
    const currentMileage = parseFloat(this.currentMileageTarget.value) || 0
    const lastChangeMileage = parseFloat(this.lastChangeMileageTarget.value) || 0
    const lastChangeDate = this.lastChangeDateTarget.value
    const dailyMiles = parseFloat(this.dailyMilesTarget.value) || 30
    const conditions = this.drivingConditionsTarget.value

    if (currentMileage <= 0 || currentMileage < lastChangeMileage || !lastChangeDate) {
      this.clearResults()
      return
    }

    const baseIntervalMiles = { conventional: 3000, synthetic_blend: 5000, full_synthetic: 7500, high_mileage: 5000 }[oilType] || 5000
    const baseIntervalMonths = { conventional: 3, synthetic_blend: 6, full_synthetic: 12, high_mileage: 6 }[oilType] || 6

    const conditionFactor = conditions === "severe" ? 0.5 : conditions === "moderate" ? 0.75 : 1.0

    const recMiles = Math.round(baseIntervalMiles * conditionFactor)
    const recMonths = Math.round(baseIntervalMonths * conditionFactor)

    const milesSince = currentMileage - lastChangeMileage
    const milesRemaining = Math.max(recMiles - milesSince, 0)

    const lastDate = new Date(lastChangeDate)
    const today = new Date()
    const daysSince = Math.floor((today - lastDate) / (1000 * 60 * 60 * 24))

    const daysUntilByMiles = dailyMiles > 0 ? Math.ceil(milesRemaining / dailyMiles) : 0
    const nextByMiles = new Date(today)
    nextByMiles.setDate(nextByMiles.getDate() + daysUntilByMiles)

    const nextByTime = new Date(lastDate)
    nextByTime.setMonth(nextByTime.getMonth() + recMonths)

    const nextDate = nextByTime < nextByMiles ? nextByTime : nextByMiles
    const nextMileage = lastChangeMileage + recMiles

    const oilLifePct = recMiles > 0 ? Math.max((1 - milesSince / recMiles) * 100, 0) : 0
    const overdue = milesSince > recMiles || today > nextByTime

    this.recommendedMilesTarget.textContent = recMiles.toLocaleString() + " mi"
    this.recommendedMonthsTarget.textContent = recMonths + " months"
    this.milesSinceChangeTarget.textContent = Math.round(milesSince).toLocaleString() + " mi"
    this.milesRemainingTarget.textContent = Math.round(milesRemaining).toLocaleString() + " mi"
    this.oilLifePctTarget.textContent = oilLifePct.toFixed(1) + "%"
    this.nextChangeMileageTarget.textContent = Math.round(nextMileage).toLocaleString() + " mi"
    this.nextChangeDateTarget.textContent = nextDate.toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" })

    if (overdue) {
      this.overdueWarningTarget.classList.remove("hidden")
    } else {
      this.overdueWarningTarget.classList.add("hidden")
    }
  }

  clearResults() {
    this.recommendedMilesTarget.textContent = "0 mi"
    this.recommendedMonthsTarget.textContent = "0 months"
    this.milesSinceChangeTarget.textContent = "0 mi"
    this.milesRemainingTarget.textContent = "0 mi"
    this.oilLifePctTarget.textContent = "0.0%"
    this.nextChangeMileageTarget.textContent = "0 mi"
    this.nextChangeDateTarget.textContent = "--"
    this.overdueWarningTarget.classList.add("hidden")
  }

  copy() {
    const text = `Recommended Interval: ${this.recommendedMilesTarget.textContent} / ${this.recommendedMonthsTarget.textContent}\nMiles Since Change: ${this.milesSinceChangeTarget.textContent}\nMiles Remaining: ${this.milesRemainingTarget.textContent}\nOil Life: ${this.oilLifePctTarget.textContent}\nNext Change: ${this.nextChangeDateTarget.textContent} at ${this.nextChangeMileageTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
