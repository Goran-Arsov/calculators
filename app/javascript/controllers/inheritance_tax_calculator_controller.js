import { Controller } from "@hotwired/stimulus"
import { formatCurrency, formatPercent } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "estateValue", "state", "relationship",
    "exemptAmount", "taxableAmount", "taxRate",
    "estimatedTax", "effectiveRate"
  ]

  // Simplified state inheritance tax tables.
  // Structure: { [relationship]: { exemption, rates: [[threshold, rate], ...] } }
  static stateTables = {
    iowa: {
      spouse:  { exemption: Infinity, rates: [] },
      child:   { exemption: Infinity, rates: [] },
      sibling: { exemption: 0, rates: [[12500, 0.05], [12500, 0.06], [25000, 0.07], [Infinity, 0.08]] },
      other:   { exemption: 0, rates: [[12500, 0.10], [12500, 0.12], [25000, 0.14], [Infinity, 0.15]] }
    },
    kentucky: {
      spouse:  { exemption: Infinity, rates: [] },
      child:   { exemption: Infinity, rates: [] },
      sibling: { exemption: 1000, rates: [[10000, 0.04], [10000, 0.05], [10000, 0.06], [10000, 0.07], [Infinity, 0.08]] },
      other:   { exemption: 500, rates: [[10000, 0.06], [10000, 0.08], [10000, 0.10], [10000, 0.12], [10000, 0.14], [Infinity, 0.16]] }
    },
    maryland: {
      spouse:  { exemption: Infinity, rates: [] },
      child:   { exemption: Infinity, rates: [] },
      sibling: { exemption: 0, rates: [[Infinity, 0.10]] },
      other:   { exemption: 0, rates: [[Infinity, 0.10]] }
    },
    nebraska: {
      spouse:  { exemption: Infinity, rates: [] },
      child:   { exemption: 100000, rates: [[Infinity, 0.01]] },
      sibling: { exemption: 40000, rates: [[Infinity, 0.11]] },
      other:   { exemption: 25000, rates: [[Infinity, 0.15]] }
    },
    new_jersey: {
      spouse:  { exemption: Infinity, rates: [] },
      child:   { exemption: Infinity, rates: [] },
      sibling: { exemption: 25000, rates: [[Infinity, 0.11]] },
      other:   { exemption: 0, rates: [[700000, 0.15], [Infinity, 0.16]] }
    },
    pennsylvania: {
      spouse:  { exemption: Infinity, rates: [] },
      child:   { exemption: 0, rates: [[Infinity, 0.045]] },
      sibling: { exemption: 0, rates: [[Infinity, 0.12]] },
      other:   { exemption: 0, rates: [[Infinity, 0.15]] }
    }
  }

  connect() {
    prefillFromUrl(this, { estate_value: "estateValue", state: "state", relationship: "relationship" })
    this.calculate()
  }

  calculate() {
    const estateValue = parseFloat(this.estateValueTarget.value) || 0
    const state = this.stateTarget.value || "none"
    const relationship = this.relationshipTarget.value || "other"

    if (estateValue <= 0) {
      this.clearResults()
      return
    }

    if (state === "none") {
      this.exemptAmountTarget.textContent = formatCurrency(estateValue)
      this.taxableAmountTarget.textContent = formatCurrency(0)
      this.taxRateTarget.textContent = "0.00%"
      this.estimatedTaxTarget.textContent = formatCurrency(0)
      this.effectiveRateTarget.textContent = "0.00%"
      return
    }

    const table = this.constructor.stateTables[state]
    if (!table) { this.clearResults(); return }

    const info = table[relationship]
    if (!info) { this.clearResults(); return }

    if (info.exemption === Infinity) {
      this.exemptAmountTarget.textContent = formatCurrency(estateValue)
      this.taxableAmountTarget.textContent = formatCurrency(0)
      this.taxRateTarget.textContent = "0.00%"
      this.estimatedTaxTarget.textContent = formatCurrency(0)
      this.effectiveRateTarget.textContent = "0.00%"
      return
    }

    const taxable = Math.max(estateValue - info.exemption, 0)
    const tax = this.calculateMarginalTax(taxable, info.rates)
    const effectiveRate = estateValue > 0 ? (tax / estateValue * 100) : 0
    const topRate = info.rates.length > 0 ? info.rates[info.rates.length - 1][1] * 100 : 0

    this.exemptAmountTarget.textContent = formatCurrency(Math.min(info.exemption, estateValue))
    this.taxableAmountTarget.textContent = formatCurrency(taxable)
    this.taxRateTarget.textContent = topRate.toFixed(2) + "%"
    this.estimatedTaxTarget.textContent = formatCurrency(tax)
    this.effectiveRateTarget.textContent = effectiveRate.toFixed(2) + "%"
  }

  calculateMarginalTax(taxable, rates) {
    if (taxable <= 0 || rates.length === 0) return 0
    let remaining = taxable
    let totalTax = 0

    for (const [threshold, rate] of rates) {
      if (remaining <= 0) break
      const bracketWidth = Math.min(threshold, remaining)
      totalTax += bracketWidth * rate
      remaining -= bracketWidth
    }

    return totalTax
  }

  clearResults() {
    this.exemptAmountTarget.textContent = "$0.00"
    this.taxableAmountTarget.textContent = "$0.00"
    this.taxRateTarget.textContent = "0.00%"
    this.estimatedTaxTarget.textContent = "$0.00"
    this.effectiveRateTarget.textContent = "0.00%"
  }

  copy() {
    const text = `Inheritance Tax Calculator Results\nEstate Value: ${formatCurrency(parseFloat(this.estateValueTarget.value) || 0)}\nState: ${this.stateTarget.value}\nRelationship: ${this.relationshipTarget.value}\nExempt Amount: ${this.exemptAmountTarget.textContent}\nTaxable Amount: ${this.taxableAmountTarget.textContent}\nTop Tax Rate: ${this.taxRateTarget.textContent}\nEstimated Tax: ${this.estimatedTaxTarget.textContent}\nEffective Rate: ${this.effectiveRateTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
