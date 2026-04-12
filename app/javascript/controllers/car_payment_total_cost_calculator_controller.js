import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "vehiclePrice", "downPayment", "loanRate", "loanTerm",
    "annualInsurance", "monthlyFuel", "annualMaintenance",
    "annualRegistration", "salesTaxRate", "ownershipYears",
    "monthlyPayment", "totalInterest", "totalLoan",
    "totalInsurance", "totalFuel", "totalMaintenance",
    "totalRegistration", "totalCost", "monthlyCost"
  ]

  calculate() {
    const price = parseFloat(this.vehiclePriceTarget.value) || 0
    const down = parseFloat(this.downPaymentTarget.value) || 0
    const rate = (parseFloat(this.loanRateTarget.value) || 0) / 100
    const term = parseInt(this.loanTermTarget.value) || 60
    const insurance = parseFloat(this.annualInsuranceTarget.value) || 0
    const fuel = parseFloat(this.monthlyFuelTarget.value) || 0
    const maintenance = parseFloat(this.annualMaintenanceTarget.value) || 0
    const registration = parseFloat(this.annualRegistrationTarget.value) || 0
    const taxRate = (parseFloat(this.salesTaxRateTarget.value) || 0) / 100
    const years = parseInt(this.ownershipYearsTarget.value) || 5

    if (price <= 0 || term <= 0 || years <= 0) {
      this.clearResults()
      return
    }

    const salesTax = price * taxRate
    const loanAmount = price + salesTax - down
    const monthlyRate = rate / 12

    let monthlyPayment
    if (monthlyRate === 0) {
      monthlyPayment = loanAmount / term
    } else {
      monthlyPayment = loanAmount * (monthlyRate * Math.pow(1 + monthlyRate, term)) /
                        (Math.pow(1 + monthlyRate, term) - 1)
    }

    const totalLoan = monthlyPayment * term
    const totalInterest = totalLoan - loanAmount
    const ownershipMonths = years * 12
    const totalInsurance = insurance * years
    const totalFuel = fuel * ownershipMonths
    const totalMaintenance = maintenance * years
    const totalRegistration = registration * years

    const totalCost = down + totalLoan + totalInsurance + totalFuel + totalMaintenance + totalRegistration
    const monthlyCost = ownershipMonths > 0 ? totalCost / ownershipMonths : 0

    this.monthlyPaymentTarget.textContent = this.fmt(monthlyPayment)
    this.totalInterestTarget.textContent = this.fmt(totalInterest)
    this.totalLoanTarget.textContent = this.fmt(totalLoan)
    this.totalInsuranceTarget.textContent = this.fmt(totalInsurance)
    this.totalFuelTarget.textContent = this.fmt(totalFuel)
    this.totalMaintenanceTarget.textContent = this.fmt(totalMaintenance)
    this.totalRegistrationTarget.textContent = this.fmt(totalRegistration)
    this.totalCostTarget.textContent = this.fmt(totalCost)
    this.monthlyCostTarget.textContent = this.fmt(monthlyCost)
  }

  clearResults() {
    const zero = "$0.00"
    this.monthlyPaymentTarget.textContent = zero
    this.totalInterestTarget.textContent = zero
    this.totalLoanTarget.textContent = zero
    this.totalInsuranceTarget.textContent = zero
    this.totalFuelTarget.textContent = zero
    this.totalMaintenanceTarget.textContent = zero
    this.totalRegistrationTarget.textContent = zero
    this.totalCostTarget.textContent = zero
    this.monthlyCostTarget.textContent = zero
  }

  fmt(n) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(n)
  }

  copy() {
    const text = `Monthly Payment: ${this.monthlyPaymentTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}\nTotal Insurance: ${this.totalInsuranceTarget.textContent}\nTotal Fuel: ${this.totalFuelTarget.textContent}\nTotal Maintenance: ${this.totalMaintenanceTarget.textContent}\nTotal Cost of Ownership: ${this.totalCostTarget.textContent}\nMonthly Cost: ${this.monthlyCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
