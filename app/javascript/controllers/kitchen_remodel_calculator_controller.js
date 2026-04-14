import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM } from "utils/units"

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
                    "unitSystem", "sizeLabel",
                    "resultTotal", "resultLow", "resultHigh", "resultBase", "resultAddOns",
                    "breakdownList"]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(2)
    }
    convert(this.sizeTarget, SQFT_TO_SQM)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.sizeLabelTarget.textContent = metric ? "Kitchen size (m²)" : "Kitchen size (sq ft)"
    // Rebuild tier select labels.
    const current = this.tierTarget.value
    const unit = metric ? "m²" : "sq ft"
    const options = [
      ["minor", `Minor (cosmetic refresh) — $${metric ? Math.round(150 / SQFT_TO_SQM) : 150}/${unit}`],
      ["midrange", `Midrange — $${metric ? Math.round(225 / SQFT_TO_SQM) : 225}/${unit}`],
      ["major", `Major (full remodel) — $${metric ? Math.round(350 / SQFT_TO_SQM) : 350}/${unit}`],
      ["luxury", `Luxury — $${metric ? Math.round(550 / SQFT_TO_SQM) : 550}/${unit}`]
    ]
    this.tierTarget.innerHTML = options.map(([v, label]) =>
      `<option value="${v}"${v === current ? " selected" : ""}>${label}</option>`
    ).join("")
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const sizeInput = parseFloat(this.sizeTarget.value)
    const tier = TIERS[this.tierTarget.value]
    const custom = this.customCabinetsTarget.checked
    const plumb = this.movePlumbingTarget.checked
    const elec = this.moveElectricalTarget.checked

    if (!Number.isFinite(sizeInput) || sizeInput <= 0 || !tier) {
      this.clear()
      return
    }

    // Imperial math internally.
    const sizeSqft = metric ? sizeInput / SQFT_TO_SQM : sizeInput

    let base = sizeSqft * tier.perSqft
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
