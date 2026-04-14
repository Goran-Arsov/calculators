import { Controller } from "@hotwired/stimulus"
import { formatCurrency, formatPercent } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "grossSalary", "country", "filingStatus", "payFrequency",
    "netAnnual", "netPerPeriod", "totalDeductions",
    "effectiveTaxRate", "deductionsBreakdown"
  ]

  connect() {
    prefillFromUrl(this, { grossSalary: "grossSalary" })
    this.calculate()
  }

  calculate() {
    const gross = parseFloat(this.grossSalaryTarget.value) || 0
    const country = this.countryTarget.value || "us"
    const filingStatus = this.filingStatusTarget.value || "single"
    const payFrequency = this.payFrequencyTarget.value || "annual"

    if (gross <= 0) {
      this.clearResults()
      return
    }

    const deductions = this.calculateDeductions(gross, country, filingStatus)
    const totalDeductions = Object.values(deductions).reduce((s, v) => s + v, 0)
    const netAnnual = gross - totalDeductions
    const effectiveRate = (totalDeductions / gross) * 100

    const periods = { annual: 1, monthly: 12, biweekly: 26, weekly: 52 }
    const p = periods[payFrequency] || 1
    const netPerPeriod = netAnnual / p

    this.netAnnualTarget.textContent = formatCurrency(netAnnual)
    this.netPerPeriodTarget.textContent = formatCurrency(netPerPeriod)
    this.totalDeductionsTarget.textContent = formatCurrency(totalDeductions)
    this.effectiveTaxRateTarget.textContent = formatPercent(effectiveRate)

    // Build deductions breakdown
    let html = ""
    for (const [key, value] of Object.entries(deductions)) {
      const label = key.replace(/_/g, " ").replace(/\b\w/g, l => l.toUpperCase())
      html += `<div class="flex justify-between items-center">
        <span class="text-sm text-gray-600 dark:text-gray-400">${label}</span>
        <span class="text-sm font-medium text-red-600 dark:text-red-400">-${formatCurrency(value)}</span>
      </div>`
    }
    this.deductionsBreakdownTarget.innerHTML = html
  }

  calculateDeductions(gross, country, filingStatus) {
    switch (country) {
      case "us": return this.usDeductions(gross, filingStatus)
      case "uk": return this.ukDeductions(gross)
      case "ca": return this.caDeductions(gross)
      case "au": return this.auDeductions(gross)
      default: return this.usDeductions(gross, filingStatus)
    }
  }

  usDeductions(gross, filingStatus) {
    const brackets = filingStatus === "married"
      ? [[23200, 0], [23200, 0.10], [71100, 0.12], [106750, 0.22], [182850, 0.24], [103550, 0.32], [243750, 0.35], [Infinity, 0.37]]
      : [[11600, 0], [11600, 0.10], [35550, 0.12], [53375, 0.22], [91425, 0.24], [51775, 0.32], [365625, 0.35], [Infinity, 0.37]]

    let federalTax = 0, remaining = gross
    for (const [width, rate] of brackets) {
      const taxable = Math.min(remaining, width)
      federalTax += taxable * rate
      remaining -= taxable
      if (remaining <= 0) break
    }

    const socialSecurity = Math.min(gross * 0.062, 168600 * 0.062)
    let medicare = gross * 0.0145
    if (gross > 200000) medicare += (gross - 200000) * 0.009

    return { federal_tax: federalTax, social_security: socialSecurity, medicare: medicare }
  }

  ukDeductions(gross) {
    const personalAllowance = 12570
    const taxable = Math.max(gross - personalAllowance, 0)
    const brackets = [[37700, 0.20], [99730, 0.40], [Infinity, 0.45]]

    let incomeTax = 0, remaining = taxable
    for (const [width, rate] of brackets) {
      const amount = Math.min(remaining, width)
      incomeTax += amount * rate
      remaining -= amount
      if (remaining <= 0) break
    }

    const weekly = gross / 52
    let ni = 0
    if (weekly > 242) {
      if (weekly <= 967) ni = (weekly - 242) * 0.08 * 52
      else ni = ((967 - 242) * 0.08 + (weekly - 967) * 0.02) * 52
    }

    return { income_tax: incomeTax, national_insurance: ni }
  }

  caDeductions(gross) {
    const personalAmount = 15705
    const taxable = Math.max(gross - personalAmount, 0)
    const brackets = [[55867, 0.15], [55866, 0.205], [43173, 0.26], [65094, 0.29], [Infinity, 0.33]]

    let federalTax = 0, remaining = taxable
    for (const [width, rate] of brackets) {
      const amount = Math.min(remaining, width)
      federalTax += amount * rate
      remaining -= amount
      if (remaining <= 0) break
    }

    const cpp = Math.min(Math.max((gross - 3500) * 0.0595, 0), 3867.50)
    const ei = Math.min(gross * 0.0166, 1049.12)

    return { federal_tax: federalTax, cpp: cpp, ei: ei }
  }

  auDeductions(gross) {
    const brackets = [[18200, 0], [26800, 0.16], [90000, 0.30], [55000, 0.37], [Infinity, 0.45]]

    let incomeTax = 0, remaining = gross
    for (const [width, rate] of brackets) {
      const amount = Math.min(remaining, width)
      incomeTax += amount * rate
      remaining -= amount
      if (remaining <= 0) break
    }

    const medicareLev = gross * 0.02
    return { income_tax: incomeTax, medicare_levy: medicareLev }
  }

  clearResults() {
    this.netAnnualTarget.textContent = "$0.00"
    this.netPerPeriodTarget.textContent = "$0.00"
    this.totalDeductionsTarget.textContent = "$0.00"
    this.effectiveTaxRateTarget.textContent = "0.00%"
    this.deductionsBreakdownTarget.innerHTML = ""
  }

  copy(event) {
    const text = `Net Annual Pay: ${this.netAnnualTarget.textContent}\nNet Per Period: ${this.netPerPeriodTarget.textContent}\nTotal Deductions: ${this.totalDeductionsTarget.textContent}\nEffective Tax Rate: ${this.effectiveTaxRateTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
