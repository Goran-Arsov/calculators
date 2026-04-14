import { Controller } from "@hotwired/stimulus"
import { MI_TO_KM, LB_TO_KG } from "utils/units"

const MPG_TO_L100KM = 235.214583

export default class extends Controller {
  static targets = [
    "annualMiles", "gasMpg", "gasPrice", "evEfficiency",
    "electricityRate", "evMaintenance", "gasMaintenance",
    "comparisonYears", "evPurchasePrice", "gasPurchasePrice",
    "unitSystem",
    "annualMilesLabel", "gasMpgLabel", "evEfficiencyLabel",
    "gasCostPerMileHeading", "evCostPerMileHeading",
    "gasFuelAnnual", "evFuelAnnual", "fuelSavingsAnnual",
    "gasTotalCost", "evTotalCost", "totalSavings",
    "gasCostPerMile", "evCostPerMile", "breakEvenYears",
    "gasMonthlyFuel", "evMonthlyFuel",
    "gasCo2", "evCo2", "co2Savings"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const miles = parseFloat(this.annualMilesTarget.value)
    if (Number.isFinite(miles) && miles > 0) {
      const km = toMetric ? miles * MI_TO_KM : miles / MI_TO_KM
      this.annualMilesTarget.value = Math.round(km)
    }
    const mpgOrL = parseFloat(this.gasMpgTarget.value)
    if (Number.isFinite(mpgOrL) && mpgOrL > 0) {
      // mpg -> L/100km is reciprocal, L/100km -> mpg is reciprocal
      this.gasMpgTarget.value = (MPG_TO_L100KM / mpgOrL).toFixed(1)
    }
    const evEff = parseFloat(this.evEfficiencyTarget.value)
    if (Number.isFinite(evEff) && evEff > 0) {
      // kWh/100mi <-> kWh/100km
      this.evEfficiencyTarget.value = (toMetric ? evEff / MI_TO_KM : evEff * MI_TO_KM).toFixed(1)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    if (this.hasAnnualMilesLabelTarget) {
      this.annualMilesLabelTarget.textContent = metric ? "Annual Kilometers" : "Annual Miles"
    }
    if (this.hasGasMpgLabelTarget) {
      this.gasMpgLabelTarget.textContent = metric ? "Gas Consumption (L/100km)" : "Gas MPG"
    }
    if (this.hasEvEfficiencyLabelTarget) {
      this.evEfficiencyLabelTarget.textContent = metric ? "EV Efficiency (kWh/100km)" : "EV Efficiency (kWh/100mi)"
    }
    if (this.hasGasCostPerMileHeadingTarget) {
      this.gasCostPerMileHeadingTarget.textContent = metric ? "Gas $/km" : "Gas $/Mile"
    }
    if (this.hasEvCostPerMileHeadingTarget) {
      this.evCostPerMileHeadingTarget.textContent = metric ? "EV $/km" : "EV $/Mile"
    }
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const distance = parseFloat(this.annualMilesTarget.value) || 0
    const mpgOrL = parseFloat(this.gasMpgTarget.value) || 0
    const gasPrice = parseFloat(this.gasPriceTarget.value) || 0
    const evEff = parseFloat(this.evEfficiencyTarget.value) || 0
    const elecRate = parseFloat(this.electricityRateTarget.value) || 0
    const evMaint = parseFloat(this.evMaintenanceTarget.value) || 500
    const gasMaint = parseFloat(this.gasMaintenanceTarget.value) || 1200
    const years = parseInt(this.comparisonYearsTarget.value) || 5
    const evPrice = parseFloat(this.evPurchasePriceTarget.value) || 0
    const gasPurchasePrice = parseFloat(this.gasPurchasePriceTarget.value) || 0

    if (distance <= 0 || mpgOrL <= 0 || gasPrice <= 0 || evEff <= 0 || elecRate <= 0 || years <= 0) {
      this.clearResults()
      return
    }

    // Math internally in imperial: miles, MPG, kWh per 100 mi
    const miles = metric ? distance / MI_TO_KM : distance
    const mpg = metric ? MPG_TO_L100KM / mpgOrL : mpgOrL
    const evEffImperial = metric ? evEff * MI_TO_KM : evEff // kWh/100mi

    const gasGallons = miles / mpg
    const gasFuelAnnual = gasGallons * gasPrice
    const evKwh = (miles / 100) * evEffImperial
    const evFuelAnnual = evKwh * elecRate
    const fuelSavings = gasFuelAnnual - evFuelAnnual

    const gasTotalFuel = gasFuelAnnual * years
    const evTotalFuel = evFuelAnnual * years
    const gasTotalCost = gasPurchasePrice + gasTotalFuel + gasMaint * years
    const evTotalCost = evPrice + evTotalFuel + evMaint * years
    const totalSavings = gasTotalCost - evTotalCost

    const gasCPM = gasPrice / mpg // $/mile
    const evCPM = (evEffImperial / 100) * elecRate // $/mile

    const gasMonthly = gasFuelAnnual / 12
    const evMonthly = evFuelAnnual / 12

    const priceDiff = evPrice - gasPurchasePrice
    const annualOpSavings = fuelSavings + (gasMaint - evMaint)
    const breakEven = annualOpSavings > 0 && priceDiff > 0 ? priceDiff / annualOpSavings : 0

    // CO2
    const gasCo2Lbs = gasGallons * 19.6
    const evCo2Lbs = evKwh * 0.92
    const co2SavingsLbs = gasCo2Lbs - evCo2Lbs

    this.gasFuelAnnualTarget.textContent = this.fmt(gasFuelAnnual)
    this.evFuelAnnualTarget.textContent = this.fmt(evFuelAnnual)
    this.fuelSavingsAnnualTarget.textContent = this.fmt(fuelSavings)
    this.gasTotalCostTarget.textContent = this.fmt(gasTotalCost)
    this.evTotalCostTarget.textContent = this.fmt(evTotalCost)
    this.totalSavingsTarget.textContent = this.fmt(totalSavings)

    if (metric) {
      const gasCPKm = gasCPM / MI_TO_KM
      const evCPKm = evCPM / MI_TO_KM
      this.gasCostPerMileTarget.textContent = "$" + gasCPKm.toFixed(3)
      this.evCostPerMileTarget.textContent = "$" + evCPKm.toFixed(3)
      const gasCo2Kg = gasCo2Lbs * LB_TO_KG
      const evCo2Kg = evCo2Lbs * LB_TO_KG
      const co2SavingsKg = co2SavingsLbs * LB_TO_KG
      this.gasCo2Target.textContent = Math.round(gasCo2Kg).toLocaleString() + " kg"
      this.evCo2Target.textContent = Math.round(evCo2Kg).toLocaleString() + " kg"
      this.co2SavingsTarget.textContent = Math.round(co2SavingsKg).toLocaleString() + " kg"
    } else {
      this.gasCostPerMileTarget.textContent = "$" + gasCPM.toFixed(3)
      this.evCostPerMileTarget.textContent = "$" + evCPM.toFixed(3)
      this.gasCo2Target.textContent = Math.round(gasCo2Lbs).toLocaleString() + " lbs"
      this.evCo2Target.textContent = Math.round(evCo2Lbs).toLocaleString() + " lbs"
      this.co2SavingsTarget.textContent = Math.round(co2SavingsLbs).toLocaleString() + " lbs"
    }

    this.gasMonthlyFuelTarget.textContent = this.fmt(gasMonthly)
    this.evMonthlyFuelTarget.textContent = this.fmt(evMonthly)
    this.breakEvenYearsTarget.textContent = breakEven > 0 ? breakEven.toFixed(1) + " years" : "N/A"
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
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
    const massUnit = metric ? "kg" : "lbs"
    this.gasCo2Target.textContent = "0 " + massUnit
    this.evCo2Target.textContent = "0 " + massUnit
    this.co2SavingsTarget.textContent = "0 " + massUnit
  }

  fmt(n) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(n)
  }

  copy() {
    const text = `Gas Annual Fuel: ${this.gasFuelAnnualTarget.textContent}\nEV Annual Fuel: ${this.evFuelAnnualTarget.textContent}\nAnnual Savings: ${this.fuelSavingsAnnualTarget.textContent}\nGas Total (${this.comparisonYearsTarget.value}yr): ${this.gasTotalCostTarget.textContent}\nEV Total (${this.comparisonYearsTarget.value}yr): ${this.evTotalCostTarget.textContent}\nTotal Savings: ${this.totalSavingsTarget.textContent}\nCO2 Savings: ${this.co2SavingsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
