import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "annualSalary", "stateTaxLevel", "payFrequency", "preTaxDeductions",
    "annualGross", "annualNet", "paycheckGross", "paycheckNet",
    "federalTax", "stateTax", "socialSecurity", "medicare",
    "fica", "totalDeductions", "effectiveTaxRate", "payPeriods"
  ]

  // 2024 federal tax brackets (single)
  static federalBrackets = [
    { min: 0, max: 11600, rate: 0.10 },
    { min: 11601, max: 47150, rate: 0.12 },
    { min: 47151, max: 100525, rate: 0.22 },
    { min: 100526, max: 191950, rate: 0.24 },
    { min: 191951, max: 243725, rate: 0.32 },
    { min: 243726, max: 609350, rate: 0.35 },
    { min: 609351, max: Infinity, rate: 0.37 }
  ]

  static stateTaxRates = { none: 0, low: 0.03, medium: 0.05, high: 0.07, very_high: 0.10 }
  static payPeriodMap = { weekly: 52, biweekly: 26, semimonthly: 24, monthly: 12 }

  calculate() {
    const annualSalary = parseFloat(this.annualSalaryTarget.value) || 0
    const stateTaxLevel = this.stateTaxLevelTarget.value || "medium"
    const payFrequency = this.payFrequencyTarget.value || "biweekly"
    const preTaxDeductions = parseFloat(this.preTaxDeductionsTarget.value) || 0

    if (annualSalary <= 0) {
      this.clearResults()
      return
    }

    const taxableIncome = Math.max(annualSalary - preTaxDeductions, 0)
    const periods = this.constructor.payPeriodMap[payFrequency] || 26

    const federalTax = this.calculateFederalTax(taxableIncome)
    const stateRate = this.constructor.stateTaxRates[stateTaxLevel] || 0.05
    const stateTax = taxableIncome * stateRate

    const ssWageBase = 168600
    const socialSecurity = Math.min(taxableIncome, ssWageBase) * 0.062
    let medicare = taxableIncome * 0.0145
    if (taxableIncome > 200000) {
      medicare += (taxableIncome - 200000) * 0.009
    }
    const fica = socialSecurity + medicare

    const totalDeductions = federalTax + stateTax + fica + preTaxDeductions
    const annualNet = annualSalary - totalDeductions
    const paycheckGross = annualSalary / periods
    const paycheckNet = annualNet / periods

    const effectiveRate = taxableIncome > 0 ? ((federalTax + stateTax) / taxableIncome * 100) : 0

    this.annualGrossTarget.textContent = this.formatCurrency(annualSalary)
    this.annualNetTarget.textContent = this.formatCurrency(annualNet)
    this.paycheckGrossTarget.textContent = this.formatCurrency(paycheckGross)
    this.paycheckNetTarget.textContent = this.formatCurrency(paycheckNet)
    this.federalTaxTarget.textContent = this.formatCurrency(federalTax)
    this.stateTaxTarget.textContent = this.formatCurrency(stateTax)
    this.socialSecurityTarget.textContent = this.formatCurrency(socialSecurity)
    this.medicareTarget.textContent = this.formatCurrency(medicare)
    this.ficaTarget.textContent = this.formatCurrency(fica)
    this.totalDeductionsTarget.textContent = this.formatCurrency(totalDeductions)
    this.effectiveTaxRateTarget.textContent = effectiveRate.toFixed(2) + "%"
    this.payPeriodsTarget.textContent = periods
  }

  calculateFederalTax(income) {
    let remaining = income
    let tax = 0
    for (const bracket of this.constructor.federalBrackets) {
      if (remaining <= 0) break
      const width = bracket.max === Infinity ? remaining : (bracket.min === 0 ? bracket.max + 1 : bracket.max - bracket.min + 1)
      const taxable = Math.min(remaining, width)
      tax += taxable * bracket.rate
      remaining -= taxable
    }
    return tax
  }

  clearResults() {
    this.annualGrossTarget.textContent = "$0.00"
    this.annualNetTarget.textContent = "$0.00"
    this.paycheckGrossTarget.textContent = "$0.00"
    this.paycheckNetTarget.textContent = "$0.00"
    this.federalTaxTarget.textContent = "$0.00"
    this.stateTaxTarget.textContent = "$0.00"
    this.socialSecurityTarget.textContent = "$0.00"
    this.medicareTarget.textContent = "$0.00"
    this.ficaTarget.textContent = "$0.00"
    this.totalDeductionsTarget.textContent = "$0.00"
    this.effectiveTaxRateTarget.textContent = "0.00%"
    this.payPeriodsTarget.textContent = "0"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Paycheck Calculator Results\nAnnual Gross: ${this.annualGrossTarget.textContent}\nAnnual Net: ${this.annualNetTarget.textContent}\nPer Paycheck (Gross): ${this.paycheckGrossTarget.textContent}\nPer Paycheck (Net): ${this.paycheckNetTarget.textContent}\nFederal Tax: ${this.federalTaxTarget.textContent}\nState Tax: ${this.stateTaxTarget.textContent}\nFICA: ${this.ficaTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
