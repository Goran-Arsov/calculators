import { Controller } from "@hotwired/stimulus"

const APPLIANCES = {
  fridge:         { running: 700,  starting: 2200, label: "Refrigerator" },
  freezer:        { running: 500,  starting: 1500, label: "Chest freezer" },
  furnace_blower: { running: 800,  starting: 2400, label: "Furnace blower motor" },
  well_pump_1hp:  { running: 1200, starting: 3600, label: "Well pump (1 HP)" },
  ac_1ton:        { running: 1500, starting: 4500, label: "AC / heat pump 1-ton" },
  ac_2ton:        { running: 3000, starting: 9000, label: "AC / heat pump 2-ton" },
  ac_3ton:        { running: 4500, starting: 13500, label: "AC / heat pump 3-ton" },
  sump_pump:      { running: 800,  starting: 2400, label: "Sump pump (1/2 HP)" },
  dishwasher:     { running: 1500, starting: 1500, label: "Dishwasher" },
  microwave:      { running: 1200, starting: 1200, label: "Microwave" },
  electric_range: { running: 3000, starting: 3000, label: "Electric range (one burner)" },
  water_heater:   { running: 4500, starting: 4500, label: "Electric water heater" },
  washer:         { running: 500,  starting: 1500, label: "Washing machine" },
  dryer_electric: { running: 5500, starting: 6750, label: "Electric dryer" },
  dryer_gas:      { running: 700,  starting: 1800, label: "Gas dryer" },
  lighting:       { running: 200,  starting: 200,  label: "LED lighting (whole house)" },
  tv:             { running: 150,  starting: 150,  label: "TV + entertainment" },
  computer:       { running: 300,  starting: 300,  label: "Computer + monitor" },
  small_loads:    { running: 500,  starting: 500,  label: "Small outlets" }
}

export default class extends Controller {
  static targets = [
    "count", "headroom",
    "resultRunning", "resultSurge", "resultRecommended", "resultKw"
  ]

  connect() { this.calculate() }

  calculate() {
    let totalRunning = 0
    let biggestStartDelta = 0

    this.countTargets.forEach(input => {
      const key = input.dataset.appliance
      const count = parseInt(input.value, 10) || 0
      if (count <= 0 || !APPLIANCES[key]) return
      const app = APPLIANCES[key]
      totalRunning += app.running * count
      const delta = app.starting - app.running
      if (delta > biggestStartDelta) biggestStartDelta = delta
    })

    if (totalRunning === 0) {
      this.clear()
      return
    }

    const headroom = parseFloat(this.headroomTarget.value) || 0
    const peakSurge = totalRunning + biggestStartDelta
    const recommended = peakSurge * (1 + headroom / 100)

    this.resultRunningTarget.textContent = `${totalRunning.toLocaleString()} W (${(totalRunning / 1000).toFixed(2)} kW)`
    this.resultSurgeTarget.textContent = `${peakSurge.toLocaleString()} W (${(peakSurge / 1000).toFixed(2)} kW)`
    this.resultRecommendedTarget.textContent = `${Math.ceil(recommended).toLocaleString()} W`
    this.resultKwTarget.textContent = `${(recommended / 1000).toFixed(2)} kW (generator nameplate)`
  }

  clear() {
    ["Running","Surge","Recommended","Kw"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Generator sizing:",
      `Running load: ${this.resultRunningTarget.textContent}`,
      `Peak surge: ${this.resultSurgeTarget.textContent}`,
      `Recommended: ${this.resultRecommendedTarget.textContent}`,
      `Min generator size: ${this.resultKwTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
