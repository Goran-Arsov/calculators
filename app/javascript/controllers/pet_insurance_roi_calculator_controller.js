import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["petType", "breedSize", "petAge", "expectedLifespan", "monthlyPremium",
                     "annualDeductible", "reimbursementRate",
                     "totalPremiums", "totalDeductibles", "totalInsuranceCost",
                     "estimatedVetBills", "estimatedEmergencies", "totalEstimatedCosts",
                     "insurancePayouts", "netSavings", "roiPercentage", "recommendation"]

  static annualVetCosts = {
    dog: { small: 800, medium: 1000, large: 1200, giant: 1500 },
    cat: { small: 600, medium: 700, large: 800, giant: 800 }
  }

  static majorEventCosts = {
    dog: { small: 3000, medium: 4000, large: 5000, giant: 6000 },
    cat: { small: 2500, medium: 3000, large: 3500, giant: 3500 }
  }

  calculate() {
    const petType = this.petTypeTarget.value
    const breedSize = this.breedSizeTarget.value
    const petAge = parseInt(this.petAgeTarget.value) || 0
    const lifespan = parseInt(this.expectedLifespanTarget.value) || 0
    const monthlyPremium = parseFloat(this.monthlyPremiumTarget.value) || 0
    const annualDeductible = parseFloat(this.annualDeductibleTarget.value) || 0
    const reimbursementRate = (parseFloat(this.reimbursementRateTarget.value) || 80) / 100

    if (petAge >= lifespan || monthlyPremium <= 0 || lifespan <= 0) {
      this.clearResults()
      return
    }

    const remainingYears = lifespan - petAge
    const totalPremiums = monthlyPremium * 12 * remainingYears
    const totalDeductibles = annualDeductible * remainingYears
    const totalInsuranceCost = totalPremiums + totalDeductibles

    const annualCost = this.constructor.annualVetCosts[petType]?.[breedSize] || 1000
    const eventCost = this.constructor.majorEventCosts[petType]?.[breedSize] || 4000

    let vetBills = 0
    let emergencies = 0
    for (let year = 0; year < remainingYears; year++) {
      const ageAtYear = petAge + year
      vetBills += annualCost * (1.0 + ageAtYear * 0.05)
      const prob = Math.min(0.15 + ageAtYear * 0.02, 0.6)
      emergencies += eventCost * prob
    }

    const totalEstimated = vetBills + emergencies
    const totalAboveDeductible = Math.max(totalEstimated - annualDeductible * remainingYears, 0)
    const payouts = totalAboveDeductible * reimbursementRate
    const netSavings = payouts - totalInsuranceCost
    const roi = totalInsuranceCost > 0 ? ((payouts - totalInsuranceCost) / totalInsuranceCost * 100) : 0

    this.totalPremiumsTarget.textContent = this.fmt(totalPremiums)
    this.totalDeductiblesTarget.textContent = this.fmt(totalDeductibles)
    this.totalInsuranceCostTarget.textContent = this.fmt(totalInsuranceCost)
    this.estimatedVetBillsTarget.textContent = this.fmt(vetBills)
    this.estimatedEmergenciesTarget.textContent = this.fmt(emergencies)
    this.totalEstimatedCostsTarget.textContent = this.fmt(totalEstimated)
    this.insurancePayoutsTarget.textContent = this.fmt(payouts)
    this.netSavingsTarget.textContent = this.fmt(netSavings)
    this.roiPercentageTarget.textContent = `${roi.toFixed(1)}%`
    this.recommendationTarget.textContent = netSavings > 0 ? "Insurance likely saves money" : "Insurance may not be cost-effective"
  }

  clearResults() {
    const targets = ["totalPremiums", "totalDeductibles", "totalInsuranceCost",
      "estimatedVetBills", "estimatedEmergencies", "totalEstimatedCosts",
      "insurancePayouts", "netSavings", "roiPercentage", "recommendation"]
    targets.forEach(t => this[`${t}Target`].textContent = "\u2014")
  }

  fmt(n) {
    return `$${Math.round(n).toLocaleString()}`
  }

  copy() {
    const text = [
      `Total Insurance Cost: ${this.totalInsuranceCostTarget.textContent}`,
      `Estimated Vet Bills: ${this.totalEstimatedCostsTarget.textContent}`,
      `Insurance Payouts: ${this.insurancePayoutsTarget.textContent}`,
      `Net Savings: ${this.netSavingsTarget.textContent}`,
      `ROI: ${this.roiPercentageTarget.textContent}`,
      `Recommendation: ${this.recommendationTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
