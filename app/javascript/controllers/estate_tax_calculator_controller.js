import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "estateValue", "filingStatus", "deductions",
    "exemption", "taxableEstate", "estateTax",
    "effectiveRate", "netToHeirs"
  ]

  static exemptions = { single: 13610000, married: 27220000 }

  static brackets = [
    { min: 0, max: 10000, rate: 0.18 },
    { min: 10001, max: 20000, rate: 0.20 },
    { min: 20001, max: 40000, rate: 0.22 },
    { min: 40001, max: 60000, rate: 0.24 },
    { min: 60001, max: 80000, rate: 0.26 },
    { min: 80001, max: 100000, rate: 0.28 },
    { min: 100001, max: 150000, rate: 0.30 },
    { min: 150001, max: 250000, rate: 0.32 },
    { min: 250001, max: 500000, rate: 0.34 },
    { min: 500001, max: 750000, rate: 0.37 },
    { min: 750001, max: 1000000, rate: 0.39 },
    { min: 1000001, max: Infinity, rate: 0.40 }
  ]

  calculate() {
    const estateValue = parseFloat(this.estateValueTarget.value) || 0
    const filingStatus = this.filingStatusTarget.value || "single"
    const deductions = parseFloat(this.deductionsTarget.value) || 0

    if (estateValue <= 0) {
      this.clearResults()
      return
    }

    const exemption = this.constructor.exemptions[filingStatus] || this.constructor.exemptions.single
    const taxableEstate = Math.max(estateValue - deductions - exemption, 0)
    const estateTax = this.calculateEstateTax(taxableEstate)
    const effectiveRate = estateValue > 0 ? (estateTax / estateValue * 100) : 0
    const netToHeirs = estateValue - estateTax - deductions

    this.exemptionTarget.textContent = this.formatCurrency(exemption)
    this.taxableEstateTarget.textContent = this.formatCurrency(taxableEstate)
    this.estateTaxTarget.textContent = this.formatCurrency(estateTax)
    this.effectiveRateTarget.textContent = effectiveRate.toFixed(2) + "%"
    this.netToHeirsTarget.textContent = this.formatCurrency(netToHeirs)
  }

  calculateEstateTax(taxableAmount) {
    if (taxableAmount <= 0) return 0
    let remaining = taxableAmount
    let tax = 0

    for (const bracket of this.constructor.brackets) {
      if (remaining <= 0) break
      const width = bracket.max === Infinity ? remaining : (bracket.min === 0 ? bracket.max + 1 : bracket.max - bracket.min + 1)
      const taxable = Math.min(remaining, width)
      tax += taxable * bracket.rate
      remaining -= taxable
    }
    return tax
  }

  clearResults() {
    this.exemptionTarget.textContent = "$0.00"
    this.taxableEstateTarget.textContent = "$0.00"
    this.estateTaxTarget.textContent = "$0.00"
    this.effectiveRateTarget.textContent = "0.00%"
    this.netToHeirsTarget.textContent = "$0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Estate Tax Calculator Results\nEstate Value: ${this.formatCurrency(parseFloat(this.estateValueTarget.value) || 0)}\nExemption: ${this.exemptionTarget.textContent}\nTaxable Estate: ${this.taxableEstateTarget.textContent}\nEstate Tax: ${this.estateTaxTarget.textContent}\nEffective Rate: ${this.effectiveRateTarget.textContent}\nNet to Heirs: ${this.netToHeirsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
