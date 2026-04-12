import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "scholarshipAmount", "hoursSpent", "numApplications", "successRate", "applicationCosts",
    "expectedValue", "netGain", "hourlyReturn", "roiPercentage",
    "hoursPerApplication", "partTimeEquivalent", "scholarshipAdvantage", "worthIt"
  ]

  calculate() {
    const amount = parseFloat(this.scholarshipAmountTarget.value) || 0
    const hours = parseFloat(this.hoursSpentTarget.value) || 0
    const numApps = parseInt(this.numApplicationsTarget.value) || 1
    const successRate = (parseFloat(this.successRateTarget.value) || 0) / 100
    const costs = parseFloat(this.applicationCostsTarget.value) || 0

    if (amount <= 0 || hours <= 0) {
      this.clearResults()
      return
    }

    const expectedValue = amount * successRate
    const netGain = expectedValue - costs
    const hourlyReturn = hours > 0 ? netGain / hours : 0
    const roiPct = costs > 0 ? (netGain / costs) * 100 : (netGain > 0 ? Infinity : 0)
    const hoursPerApp = numApps > 0 ? hours / numApps : 0

    const minWage = 15.0
    const partTimeEquiv = hours * minWage
    const advantage = netGain - partTimeEquiv

    this.expectedValueTarget.textContent = this.formatCurrency(expectedValue)
    this.netGainTarget.textContent = this.formatCurrency(netGain)
    this.hourlyReturnTarget.textContent = this.formatCurrency(hourlyReturn) + "/hr"
    this.roiPercentageTarget.textContent = roiPct === Infinity ? "Infinite" : roiPct.toFixed(1) + "%"
    this.hoursPerApplicationTarget.textContent = hoursPerApp.toFixed(1) + " hrs"
    this.partTimeEquivalentTarget.textContent = this.formatCurrency(partTimeEquiv)
    this.scholarshipAdvantageTarget.textContent = this.formatCurrency(advantage)
    this.worthItTarget.textContent = hourlyReturn > minWage ? "Yes - better than part-time work" : "Consider part-time work instead"
    this.worthItTarget.classList.toggle("text-green-600", hourlyReturn > minWage)
    this.worthItTarget.classList.toggle("dark:text-green-400", hourlyReturn > minWage)
    this.worthItTarget.classList.toggle("text-amber-600", hourlyReturn <= minWage)
    this.worthItTarget.classList.toggle("dark:text-amber-400", hourlyReturn <= minWage)
  }

  clearResults() {
    this.expectedValueTarget.textContent = "$0.00"
    this.netGainTarget.textContent = "$0.00"
    this.hourlyReturnTarget.textContent = "$0.00/hr"
    this.roiPercentageTarget.textContent = "0%"
    this.hoursPerApplicationTarget.textContent = "0 hrs"
    this.partTimeEquivalentTarget.textContent = "$0.00"
    this.scholarshipAdvantageTarget.textContent = "$0.00"
    this.worthItTarget.textContent = "N/A"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Scholarship ROI Results\nExpected Value: ${this.expectedValueTarget.textContent}\nNet Gain: ${this.netGainTarget.textContent}\nHourly Return: ${this.hourlyReturnTarget.textContent}\nWorth It: ${this.worthItTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
