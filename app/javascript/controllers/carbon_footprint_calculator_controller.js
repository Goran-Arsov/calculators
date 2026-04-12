import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "drivingKm", "electricityKwh", "shortFlights", "longFlights",
    "diet", "naturalGas",
    "resultDriving", "resultElectricity", "resultFlights",
    "resultDiet", "resultGas", "resultTotal", "resultTonnes",
    "resultVsGlobal", "resultVsUs", "resultVsEu", "resultVsParis",
    "drivingBar", "electricityBar", "flightsBar", "dietBar", "gasBar"
  ]

  static factors = {
    driving: 0.21,     // kg CO2 per km
    electricity: 0.42, // kg CO2 per kWh
    flight: 0.255,     // kg CO2 per km
    gas: 5.3           // kg CO2 per therm
  }

  static dietFactors = {
    meat_heavy: 3300, average: 2500, low_meat: 1900, vegetarian: 1700, vegan: 1500
  }

  calculate() {
    const drivingKm = parseFloat(this.drivingKmTarget.value) || 0
    const electricityKwh = parseFloat(this.electricityKwhTarget.value) || 0
    const shortFlights = parseInt(this.shortFlightsTarget.value) || 0
    const longFlights = parseInt(this.longFlightsTarget.value) || 0
    const diet = this.dietTarget.value || "average"
    const naturalGas = parseFloat(this.naturalGasTarget.value) || 0

    const f = this.constructor.factors
    const driving = drivingKm * 52 * f.driving
    const electricity = electricityKwh * 12 * f.electricity
    const flights = (shortFlights * 1500 * 2 * f.flight) + (longFlights * 7000 * 2 * f.flight)
    const dietKg = this.constructor.dietFactors[diet] || 2500
    const gas = naturalGas * 12 * f.gas
    const total = driving + electricity + flights + dietKg + gas
    const tonnes = (total / 1000).toFixed(2)

    this.resultDrivingTarget.textContent = `${Math.round(driving).toLocaleString()} kg`
    this.resultElectricityTarget.textContent = `${Math.round(electricity).toLocaleString()} kg`
    this.resultFlightsTarget.textContent = `${Math.round(flights).toLocaleString()} kg`
    this.resultDietTarget.textContent = `${Math.round(dietKg).toLocaleString()} kg`
    this.resultGasTarget.textContent = `${Math.round(gas).toLocaleString()} kg`
    this.resultTotalTarget.textContent = `${Math.round(total).toLocaleString()} kg`
    this.resultTonnesTarget.textContent = `${tonnes} tonnes`

    // Comparisons
    this.resultVsGlobalTarget.textContent = `${Math.round(tonnes / 4.0 * 100)}% of global avg`
    this.resultVsUsTarget.textContent = `${Math.round(tonnes / 16.0 * 100)}% of US avg`
    this.resultVsEuTarget.textContent = `${Math.round(tonnes / 6.0 * 100)}% of EU avg`
    this.resultVsParisTarget.textContent = `${Math.round(tonnes / 2.0 * 100)}% of Paris target`

    // Bars
    if (total > 0) {
      this.updateBar("drivingBar", driving, total)
      this.updateBar("electricityBar", electricity, total)
      this.updateBar("flightsBar", flights, total)
      this.updateBar("dietBar", dietKg, total)
      this.updateBar("gasBar", gas, total)
    }
  }

  updateBar(targetName, value, total) {
    const target = this[`has${targetName.charAt(0).toUpperCase() + targetName.slice(1)}Target`]
      ? this[`${targetName}Target`] : null
    if (target) {
      const pct = Math.round(value / total * 100)
      target.style.width = `${pct}%`
      target.textContent = `${pct}%`
    }
  }

  copy() {
    const lines = [
      `Driving: ${this.resultDrivingTarget.textContent}`,
      `Electricity: ${this.resultElectricityTarget.textContent}`,
      `Flights: ${this.resultFlightsTarget.textContent}`,
      `Diet: ${this.resultDietTarget.textContent}`,
      `Natural Gas: ${this.resultGasTarget.textContent}`,
      `Total: ${this.resultTotalTarget.textContent} (${this.resultTonnesTarget.textContent})`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
