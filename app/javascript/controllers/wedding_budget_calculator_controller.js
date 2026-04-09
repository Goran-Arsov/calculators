import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["totalBudget", "guestCount",
                     "resultPerGuest", "resultVenue", "resultCatering",
                     "resultPhotography", "resultFlowers", "resultMusic",
                     "resultAttire", "resultStationery", "resultOther"]

  connect() {
    if (prefillFromUrl(this, { totalBudget: "totalBudget", guestCount: "guestCount" })) {
      this.calculate()
    }
  }

  calculate() {
    const budget = parseFloat(this.totalBudgetTarget.value) || 0
    const guests = parseInt(this.guestCountTarget.value) || 1

    const perGuest = guests > 0 ? budget / guests : 0

    this.resultPerGuestTarget.textContent = this.fmt(perGuest)
    this.resultVenueTarget.textContent = this.fmt(budget * 0.30)
    this.resultCateringTarget.textContent = this.fmt(budget * 0.25)
    this.resultPhotographyTarget.textContent = this.fmt(budget * 0.12)
    this.resultFlowersTarget.textContent = this.fmt(budget * 0.08)
    this.resultMusicTarget.textContent = this.fmt(budget * 0.07)
    this.resultAttireTarget.textContent = this.fmt(budget * 0.06)
    this.resultStationeryTarget.textContent = this.fmt(budget * 0.03)
    this.resultOtherTarget.textContent = this.fmt(budget * 0.09)
  }

  fmt(n) {
    return "$" + Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  copy() {
    const lines = [
      `Per Guest: ${this.resultPerGuestTarget.textContent}`,
      `Venue (30%): ${this.resultVenueTarget.textContent}`,
      `Catering (25%): ${this.resultCateringTarget.textContent}`,
      `Photography (12%): ${this.resultPhotographyTarget.textContent}`,
      `Flowers (8%): ${this.resultFlowersTarget.textContent}`,
      `Music/Entertainment (7%): ${this.resultMusicTarget.textContent}`,
      `Attire (6%): ${this.resultAttireTarget.textContent}`,
      `Stationery (3%): ${this.resultStationeryTarget.textContent}`,
      `Other (9%): ${this.resultOtherTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
