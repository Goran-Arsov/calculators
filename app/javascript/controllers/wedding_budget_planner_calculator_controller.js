import { Controller } from "@hotwired/stimulus"

const ALLOCATION = {
  "Venue": 0.37, "Catering": 0.22, "Photography": 0.10, "Attire": 0.05,
  "Flowers": 0.08, "Music": 0.06, "Rings": 0.03, "Invitations": 0.02,
  "Transport": 0.02, "Favors & Misc": 0.05
}

export default class extends Controller {
  static targets = ["total", "guests", "resultCostPerGuest", "breakdownList"]

  connect() { this.calculate() }

  calculate() {
    const total = parseFloat(this.totalTarget.value)
    const guests = parseInt(this.guestsTarget.value)
    if (!Number.isFinite(total) || total <= 0 || !Number.isFinite(guests) || guests < 1) { this.clear(); return }

    this.resultCostPerGuestTarget.textContent = this.money(total / guests)
    this.breakdownListTarget.innerHTML = Object.entries(ALLOCATION)
      .map(([k, v]) => `<li class="flex justify-between"><span>${k}</span><span class="font-bold">${this.money(total * v)}</span></li>`)
      .join("")
  }

  money(n) {
    return `$${n.toLocaleString("en-US", { maximumFractionDigits: 0 })}`
  }

  clear() {
    this.resultCostPerGuestTarget.textContent = "—"
    this.breakdownListTarget.innerHTML = ""
  }

  copy() {
    const lines = [...this.breakdownListTarget.querySelectorAll("li")].map(li => li.textContent.trim()).join("\n")
    navigator.clipboard.writeText(`Wedding budget breakdown:\n${lines}`)
  }
}
