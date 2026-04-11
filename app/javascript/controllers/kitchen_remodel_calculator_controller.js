import { Controller } from "@hotwired/stimulus"

const TIERS = {
  minor: { label: "Minor (cosmetic refresh)", perSqft: 150 },
  midrange: { label: "Midrange", perSqft: 225 },
  major: { label: "Major", perSqft: 350 },
  luxury: { label: "Luxury", perSqft: 550 }
}

const CUSTOM_MULT = 1.20
const MOVE_PLUMBING = 2500
const MOVE_ELECTRICAL = 1500

const BREAKDOWN = [
  ["cabinets", 0.35],
  ["appliances", 0.15],
  ["countertops", 0.15],
  ["labor", 0.20],
  ["flooring", 0.07],
  ["lighting", 0.05],
  ["other", 0.03]
]

const fmt = n => `$${Math.round(n).toLocaleString()}`

export default class extends Controller {
  static targets = ["size", "tier", "customCabinets", "movePlumbing", "moveElectrical",
                    "resultTotal", "resultLow", "resultHigh", "resultBase", "resultAddOns",
                    "breakdownList"]

  connect() { this.calculate() }

  calculate() {
    const size = parseFloat(this.sizeTarget.value)
    const tier = TIERS[this.tierTarget.value]
    const custom = this.customCabinetsTarget.checked
    const plumb = this.movePlumbingTarget.checked
    const elec = this.moveElectricalTarget.checked

    if (!Number.isFinite(size) || size <= 0 || !tier) {
      this.clear()
      return
    }

    let base = size * tier.perSqft
    if (custom) base *= CUSTOM_MULT
    let addOns = 0
    if (plumb) addOns += MOVE_PLUMBING
    if (elec) addOns += MOVE_ELECTRICAL
    const total = base + addOns

    this.resultTotalTarget.textContent = fmt(total)
    this.resultLowTarget.textContent = fmt(total * 0.85)
    this.resultHighTarget.textContent = fmt(total * 1.15)
    this.resultBaseTarget.textContent = fmt(base)
    this.resultAddOnsTarget.textContent = fmt(addOns)

    this.breakdownListTarget.innerHTML = BREAKDOWN.map(([label, pct]) =>
      `<li class="flex justify-between"><span class="capitalize">${label}</span><span class="font-semibold">${fmt(base * pct)}</span></li>`
    ).join("")
  }

  clear() {
    ["resultTotal", "resultLow", "resultHigh", "resultBase", "resultAddOns"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
    this.breakdownListTarget.innerHTML = ""
  }

  copy() {
    const text = `Kitchen remodel estimate:\nTotal: ${this.resultTotalTarget.textContent}\nLow: ${this.resultLowTarget.textContent}\nHigh: ${this.resultHighTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
