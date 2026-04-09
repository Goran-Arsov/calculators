import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["dailyBudget", "numDays", "numTravelers",
                     "resultDailyTotal", "resultTripTotal",
                     "resultAccommodation", "resultFood",
                     "resultTransport", "resultActivities"]

  connect() {
    if (prefillFromUrl(this, { dailyBudget: "dailyBudget", numDays: "numDays", numTravelers: "numTravelers" })) {
      this.calculate()
    }
  }

  calculate() {
    const dailyBudget = parseFloat(this.dailyBudgetTarget.value) || 0
    const numDays = parseInt(this.numDaysTarget.value) || 1
    const numTravelers = parseInt(this.numTravelersTarget.value) || 1

    const dailyTotal = dailyBudget * numTravelers
    const tripTotal = dailyTotal * numDays

    this.resultDailyTotalTarget.textContent = this.fmt(dailyTotal)
    this.resultTripTotalTarget.textContent = this.fmt(tripTotal)
    this.resultAccommodationTarget.textContent = this.fmt(tripTotal * 0.40)
    this.resultFoodTarget.textContent = this.fmt(tripTotal * 0.25)
    this.resultTransportTarget.textContent = this.fmt(tripTotal * 0.15)
    this.resultActivitiesTarget.textContent = this.fmt(tripTotal * 0.20)
  }

  fmt(n) {
    return "$" + Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  copy() {
    const lines = [
      `Daily Total: ${this.resultDailyTotalTarget.textContent}`,
      `Trip Total: ${this.resultTripTotalTarget.textContent}`,
      `Accommodation (40%): ${this.resultAccommodationTarget.textContent}`,
      `Food (25%): ${this.resultFoodTarget.textContent}`,
      `Transport (15%): ${this.resultTransportTarget.textContent}`,
      `Activities (20%): ${this.resultActivitiesTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
