import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "annualMiles", "gasMpg", "gasPrice", "evEfficiency",
    "electricityRate", "evMaintenance", "gasMaintenance",
    "comparisonYears", "evPurchasePrice", "gasPurchasePrice",
    "gasFuelAnnual", "evFuelAnnual", "fuelSavingsAnnual",
    "gasTotalCost", "evTotalCost", "totalSavings",
    "gasCostPerMile", "evCostPerMile", "breakEvenYears",
    "gasMonthlyFuel", "evMonthlyFuel",
    "gasCo2", "evCo2", "co2Savings"
  ]

  calculate() {
    const miles = parseFloat(this.annualMilesTarget.value) || 0
    const mpg = parseFloat(this.gasMpgTarget.value) || 0
    const gasPrice = parseFloat(this.gasPriceTarget.value) || 0
    const evEff = parseFloat(this.evEfficiencyTarget.value) || 0
    const elecRate = parseFloat(this.electricityRateTarget.value) || 0
    const evMaint = parseFloat(this.evMaintenanceTarget.value) || 500
    const gasMaint = parseFloat(this.gasMaintenanceTarget.value) || 1200
    const years = parseInt(this.comparisonYearsTarget.value) || 5
    const evPrice = parseFloat(this.evPurchasePriceTarget.value) || 0
    const gasPurchasePrice = parseFloat(this.gasPurchasePriceTarget.value) || 0

    if (miles <= 0 || mpg <= 0 || gasPrice <= 0 || evEff <= 0 || elecRate <= 0 || years <= 0) {
      this.clearResults()
      return
    }

    const gasGallons = miles / mpg
    const gasFuelAnnual = gasGallons * gasPrice
    const evKwh = (miles / 100) * evEff
    const evFuelAnnual = evKwh * elecRate
    const fuelSavings = gasFuelAnnual - evFuelAnnual

    const gasTotalFuel = gasFuelAnnual * years
    const evTotalFuel = evFuelAnnual * years
    const gasTotalCost = gasPurchasePrice + gasTotalFuel + gasMaint * years
    const evTotalCost = evPrice + evTotalFuel + evMaint * years
    const totalSavings = gasTotalCost - evTotalCost

    const gasCPM = gasPrice / mpg
    const evCPM = (evEff / 100) * elecRate

    const gasMonthly = gasFuelAnnual / 12
    const evMonthly = evFuelAnnual / 12

    const priceDiff = evPrice - gasPurchasePrice
    const annualOpSavings = fuelSavings + (gasMaint - evMaint)
    const breakEven = annualOpSavings > 0 && priceDiff > 0 ? priceDiff / annualOpSavings : 0

    // CO2
    const gasCo2 = gasGallons * 19.6
    const evCo2 = evKwh * 0.92
    const co2Savings = gasCo2 - evCo2

    this.gasFuelAnnualTarget.textContent = this.fmt(gasFuelAnnual)
    this.evFuelAnnualTarget.textContent = this.fmt(evFuelAnnual)
    this.fuelSavingsAnnualTarget.textContent = this.fmt(fuelSavings)
    this.gasTotalCostTarget.textContent = this.fmt(gasTotalCost)
    this.evTotalCostTarget.textContent = this.fmt(evTotalCost)
    this.totalSavingsTarget.textContent = this.fmt(totalSavings)
    this.gasCostPerMileTarget.textContent = "$" + gasCPM.toFixed(3)
    this.evCostPerMileTarget.textContent = "$" + evCPM.toFixed(3)
    this.gasMonthlyFuelTarget.textContent = this.fmt(gasMonthly)
    this.evMonthlyFuelTarget.textContent = this.fmt(evMonthly)
    this.breakEvenYearsTarget.textContent = breakEven > 0 ? breakEven.toFixed(1) + " years" : "N/A"
    this.gasCo2Target.textContent = Math.round(gasCo2).toLocaleString() + " lbs"
    this.evCo2Target.textContent = Math.round(evCo2).toLocaleString() + " lbs"
    this.co2SavingsTarget.textContent = Math.round(co2Savings).toLocaleString() + " lbs"
  }

  clearResults() {
    const zero = "$0.00"
    this.gasFuelAnnualTarget.textContent = zero
    this.evFuelAnnualTarget.textContent = zero
    this.fuelSavingsAnnualTarget.textContent = zero
    this.gasTotalCostTarget.textContent = zero
    this.evTotalCostTarget.textContent = zero
    this.totalSavingsTarget.textContent = zero
    this.gasCostPerMileTarget.textContent = "$0.000"
    this.evCostPerMileTarget.textContent = "$0.000"
    this.gasMonthlyFuelTarget.textContent = zero
    this.evMonthlyFuelTarget.textContent = zero
    this.breakEvenYearsTarget.textContent = "N/A"
    this.gasCo2Target.textContent = "0 lbs"
    this.evCo2Target.textContent = "0 lbs"
    this.co2SavingsTarget.textContent = "0 lbs"
  }

  fmt(n) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(n)
  }

  copy() {
    const text = `Gas Annual Fuel: ${this.gasFuelAnnualTarget.textContent}\nEV Annual Fuel: ${this.evFuelAnnualTarget.textContent}\nAnnual Savings: ${this.fuelSavingsAnnualTarget.textContent}\nGas Total (${this.comparisonYearsTarget.value}yr): ${this.gasTotalCostTarget.textContent}\nEV Total (${this.comparisonYearsTarget.value}yr): ${this.evTotalCostTarget.textContent}\nTotal Savings: ${this.totalSavingsTarget.textContent}\nCO2 Savings: ${this.co2SavingsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
