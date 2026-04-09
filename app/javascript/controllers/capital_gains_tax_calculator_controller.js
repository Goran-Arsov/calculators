import { Controller } from "@hotwired/stimulus"
import { formatCurrency, formatPercent } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "purchasePrice", "salePrice", "holdingPeriodMonths", "annualIncome", "filingStatus",
    "capitalGain", "isLongTerm", "taxRate", "taxOwed", "niitOwed", "netProfit", "effectiveRate"
  ]

  // 2024 long-term capital gains thresholds
  static longTermThresholds = {
    single: { zeroMax: 47025, fifteenMax: 518900 },
    married_jointly: { zeroMax: 94050, fifteenMax: 583750 },
    married_separately: { zeroMax: 47025, fifteenMax: 291850 },
    head_of_household: { zeroMax: 63000, fifteenMax: 551350 }
  }

  // NIIT thresholds
  static niitThresholds = {
    single: 200000,
    married_jointly: 250000,
    married_separately: 125000,
    head_of_household: 200000
  }

  // 2024 ordinary income tax brackets
  static ordinaryBrackets = {
    single: [
      { max: 11600, rate: 0.10 },
      { max: 47150, rate: 0.12 },
      { max: 100525, rate: 0.22 },
      { max: 191950, rate: 0.24 },
      { max: 243725, rate: 0.32 },
      { max: 609350, rate: 0.35 },
      { max: Infinity, rate: 0.37 }
    ],
    married_jointly: [
      { max: 23200, rate: 0.10 },
      { max: 94300, rate: 0.12 },
      { max: 201050, rate: 0.22 },
      { max: 383900, rate: 0.24 },
      { max: 487450, rate: 0.32 },
      { max: 731200, rate: 0.35 },
      { max: Infinity, rate: 0.37 }
    ],
    married_separately: [
      { max: 11600, rate: 0.10 },
      { max: 47150, rate: 0.12 },
      { max: 100525, rate: 0.22 },
      { max: 191950, rate: 0.24 },
      { max: 243725, rate: 0.32 },
      { max: 365600, rate: 0.35 },
      { max: Infinity, rate: 0.37 }
    ],
    head_of_household: [
      { max: 16550, rate: 0.10 },
      { max: 63100, rate: 0.12 },
      { max: 100500, rate: 0.22 },
      { max: 191950, rate: 0.24 },
      { max: 243700, rate: 0.32 },
      { max: 609350, rate: 0.35 },
      { max: Infinity, rate: 0.37 }
    ]
  }

  connect() {
    if (prefillFromUrl(this, {
      purchase: "purchasePrice",
      sale: "salePrice",
      months: "holdingPeriodMonths",
      income: "annualIncome",
      status: "filingStatus"
    })) {
      this.calculate()
    }
  }

  calculate() {
    const purchasePrice = parseFloat(this.purchasePriceTarget.value) || 0
    const salePrice = parseFloat(this.salePriceTarget.value) || 0
    const holdingMonths = parseInt(this.holdingPeriodMonthsTarget.value) || 0
    const annualIncome = parseFloat(this.annualIncomeTarget.value) || 0
    const filingStatus = this.filingStatusTarget.value

    if (purchasePrice <= 0 || salePrice <= 0 || holdingMonths <= 0) {
      this.clearResults()
      return
    }

    const capitalGain = salePrice - purchasePrice
    const isLongTerm = holdingMonths > 12

    if (capitalGain <= 0) {
      this.capitalGainTarget.textContent = formatCurrency(capitalGain)
      this.isLongTermTarget.textContent = isLongTerm ? "Yes (Long-term)" : "No (Short-term)"
      this.taxRateTarget.textContent = "0.00%"
      this.taxOwedTarget.textContent = "$0.00"
      this.niitOwedTarget.textContent = "$0.00"
      this.netProfitTarget.textContent = formatCurrency(capitalGain)
      this.effectiveRateTarget.textContent = "0.00%"
      return
    }

    let taxRate, taxOwed

    if (isLongTerm) {
      taxRate = this.longTermRate(annualIncome, capitalGain, filingStatus)
      taxOwed = capitalGain * taxRate
    } else {
      taxRate = this.marginalOrdinaryRate(annualIncome, capitalGain, filingStatus)
      taxOwed = this.calculateShortTermTax(annualIncome, capitalGain, filingStatus)
    }

    const niitOwed = this.calculateNiit(annualIncome, capitalGain, filingStatus)
    const totalTax = taxOwed + niitOwed
    const netProfit = capitalGain - totalTax
    const effectiveRate = capitalGain > 0 ? (totalTax / capitalGain * 100) : 0

    this.capitalGainTarget.textContent = formatCurrency(capitalGain)
    this.isLongTermTarget.textContent = isLongTerm ? "Yes (Long-term)" : "No (Short-term)"
    this.taxRateTarget.textContent = (taxRate * 100).toFixed(2) + "%"
    this.taxOwedTarget.textContent = formatCurrency(taxOwed)
    this.niitOwedTarget.textContent = formatCurrency(niitOwed)
    this.netProfitTarget.textContent = formatCurrency(netProfit)
    this.effectiveRateTarget.textContent = effectiveRate.toFixed(2) + "%"
  }

  longTermRate(income, gain, status) {
    const thresholds = this.constructor.longTermThresholds[status]
    if (!thresholds) return 0.15
    const taxable = income + gain

    if (taxable <= thresholds.zeroMax) return 0.0
    if (taxable <= thresholds.fifteenMax) return 0.15
    return 0.20
  }

  marginalOrdinaryRate(income, gain, status) {
    const brackets = this.constructor.ordinaryBrackets[status]
    if (!brackets) return 0.22
    const totalIncome = income + gain
    let rate = 0.10

    for (const bracket of brackets) {
      if (totalIncome <= bracket.max) {
        rate = bracket.rate
        break
      }
    }
    return rate
  }

  calculateShortTermTax(income, gain, status) {
    const brackets = this.constructor.ordinaryBrackets[status]
    if (!brackets) return gain * 0.22

    let remainingGain = gain
    let tax = 0
    let prevMax = 0

    for (const bracket of brackets) {
      if (income >= bracket.max) {
        prevMax = bracket.max
        continue
      }

      const taxableStart = Math.max(income, prevMax)
      const taxableEnd = Math.min(bracket.max, income + remainingGain)
      const taxableInBracket = taxableEnd - taxableStart

      if (taxableInBracket > 0) {
        tax += taxableInBracket * bracket.rate
        remainingGain -= taxableInBracket
      }

      prevMax = bracket.max
      if (remainingGain <= 0) break
    }

    return tax
  }

  calculateNiit(income, gain, status) {
    const threshold = this.constructor.niitThresholds[status]
    if (!threshold) return 0
    const totalIncome = income + gain

    if (totalIncome > threshold) {
      const excess = totalIncome - threshold
      const niitBase = Math.min(gain, excess)
      return niitBase * 0.038
    }
    return 0
  }

  clearResults() {
    this.capitalGainTarget.textContent = "$0.00"
    this.isLongTermTarget.textContent = "-"
    this.taxRateTarget.textContent = "0.00%"
    this.taxOwedTarget.textContent = "$0.00"
    this.niitOwedTarget.textContent = "$0.00"
    this.netProfitTarget.textContent = "$0.00"
    this.effectiveRateTarget.textContent = "0.00%"
  }

  copy(event) {
    const text = `Capital Gain: ${this.capitalGainTarget.textContent}\nTerm: ${this.isLongTermTarget.textContent}\nTax Rate: ${this.taxRateTarget.textContent}\nTax Owed: ${this.taxOwedTarget.textContent}\nNIIT: ${this.niitOwedTarget.textContent}\nNet Profit: ${this.netProfitTarget.textContent}\nEffective Rate: ${this.effectiveRateTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
