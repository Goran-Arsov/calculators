import { Controller } from "@hotwired/stimulus"

const TIERS = {
  minor: { label: "Minor (cosmetic refresh)", perSqft: 125 },
  midrange: { label: "Midrange", perSqft: 275 },
  major: { label: "Major (full gut)", perSqft: 425 },
  luxury: { label: "Luxury", perSqft: 650 }
}

const MOVE_PLUMBING = 1500
const ADD_SHOWER = 3000
const WALK_IN_TUB = 5000

const BREAKDOWN = [
  ["fixtures", 0.20],
  ["cabinetry", 0.15],
  ["tile_and_flooring", 0.20],
  ["labor", 0.25],
  ["plumbing", 0.10],
  ["lighting_electrical", 0.05],
  ["other", 0.05]
]

const fmt = n => `$${Math.round(n).toLocaleString()}`

export default class extends Controller {
  static targets = ["size", "tier", "movePlumbing", "addShower", "walkInTub",
                    "resultTotal", "resultLow", "resultHigh", "resultBase", "resultAddOns",
                    "breakdownList"]

  connect() { this.calculate() }

  calculate() {
    const size = parseFloat(this.sizeTarget.value)
    const tier = TIERS[this.tierTarget.value]
    const plumb = this.movePlumbingTarget.checked
    const shower = this.addShowerTarget.checked
    const tub = this.walkInTubTarget.checked

    if (!Number.isFinite(size) || size <= 0 || !tier) {
      this.clear()
      return
    }

    const base = size * tier.perSqft
    let addOns = 0
    if (plumb) addOns += MOVE_PLUMBING
    if (shower) addOns += ADD_SHOWER
    if (tub) addOns += WALK_IN_TUB
    const total = base + addOns

    this.resultTotalTarget.textContent = fmt(total)
    this.resultLowTarget.textContent = fmt(total * 0.85)
    this.resultHighTarget.textContent = fmt(total * 1.15)
    this.resultBaseTarget.textContent = fmt(base)
    this.resultAddOnsTarget.textContent = fmt(addOns)

    this.breakdownListTarget.innerHTML = BREAKDOWN.map(([label, pct]) =>
      `<li class="flex justify-between"><span class="capitalize">${label.replace(/_/g, " ")}</span><span class="font-semibold">${fmt(base * pct)}</span></li>`
    ).join("")
  }

  clear() {
    ["resultTotal", "resultLow", "resultHigh", "resultBase", "resultAddOns"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
    this.breakdownListTarget.innerHTML = ""
  }

  copy() {
    const text = `Bathroom remodel estimate:\nTotal: ${this.resultTotalTarget.textContent}\nLow: ${this.resultLowTarget.textContent}\nHigh: ${this.resultHighTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
