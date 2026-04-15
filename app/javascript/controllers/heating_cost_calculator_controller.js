import { Controller } from "@hotwired/stimulus"
import { BTU_TO_W } from "utils/units"

const FUELS = {
  natural_gas: { label: "Natural gas",    btuPerUnit: 100_000,  unit: "therm" },
  propane:     { label: "Propane",        btuPerUnit: 91_500,   unit: "gallon" },
  oil:         { label: "Heating oil #2", btuPerUnit: 138_500,  unit: "gallon" },
  electric:    { label: "Electric",       btuPerUnit: 3412,     unit: "kWh" },
  wood:        { label: "Wood (hardwood)", btuPerUnit: 24_000_000, unit: "cord" },
  pellet:      { label: "Wood pellets",    btuPerUnit: 16_000_000, unit: "ton" }
}

const fToC = (f) => (f - 32) * 5 / 9

export default class extends Controller {
  static targets = [
    "heatLoss", "hdd", "designDt", "fuel", "efficiency", "fuelCost",
    "unitSystem", "heatLossLabel", "hddLabel", "designDtLabel",
    "resultFuelUnits", "resultAnnualCost", "resultCostPerMBtu", "resultKwh"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    // Heat loss BTU/hr ↔ W
    const hl = parseFloat(this.heatLossTarget.value)
    if (Number.isFinite(hl)) this.heatLossTarget.value = (toMetric ? hl * BTU_TO_W : hl / BTU_TO_W).toFixed(0)
    // HDD °F → HDD °C (K-days) conversion is a factor of 5/9
    const hdd = parseFloat(this.hddTarget.value)
    if (Number.isFinite(hdd)) this.hddTarget.value = (toMetric ? hdd * 5 / 9 : hdd * 9 / 5).toFixed(0)
    // Design dT: same 5/9 factor
    const dt = parseFloat(this.designDtTarget.value)
    if (Number.isFinite(dt)) this.designDtTarget.value = (toMetric ? dt * 5 / 9 : dt * 9 / 5).toFixed(0)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.heatLossLabelTarget.textContent = metric ? "Design heat loss (W)" : "Design heat loss (BTU/hr)"
    this.hddLabelTarget.textContent = metric ? "Heating degree days (K·days base 18°C)" : "Heating degree days (°F-days base 65°F)"
    this.designDtLabelTarget.textContent = metric ? "Design ΔT (K)" : "Design ΔT (°F)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const hlInput = parseFloat(this.heatLossTarget.value) || 0
    const hddInput = parseFloat(this.hddTarget.value) || 0
    const dtInput = parseFloat(this.designDtTarget.value) || 0
    const fuel = this.fuelTarget.value
    const eff = parseFloat(this.efficiencyTarget.value) || 0
    const fuelCost = parseFloat(this.fuelCostTarget.value) || 0

    if (hlInput <= 0 || hddInput <= 0 || dtInput <= 0 || eff <= 0 || !FUELS[fuel]) {
      this.clear()
      return
    }

    const heatLossBtu = metric ? hlInput / BTU_TO_W : hlInput
    const hddF = metric ? hddInput * 9 / 5 : hddInput
    const dtF = metric ? dtInput * 9 / 5 : dtInput

    const info = FUELS[fuel]
    const annualOutputBtu = heatLossBtu * 24 * hddF / dtF
    const fuelInputBtu = annualOutputBtu / (eff / 100)
    const fuelUnits = fuelInputBtu / info.btuPerUnit
    const annualCost = fuelUnits * fuelCost
    const costPerMBtu = annualCost * 1_000_000 / annualOutputBtu
    const annualKwh = annualOutputBtu / 3412

    this.resultFuelUnitsTarget.textContent = `${fuelUnits.toFixed(2)} ${info.unit}${fuelUnits !== 1 ? "s" : ""}`
    this.resultAnnualCostTarget.textContent = `$${annualCost.toFixed(2)}`
    this.resultCostPerMBtuTarget.textContent = `$${costPerMBtu.toFixed(2)} / million BTU delivered`
    this.resultKwhTarget.textContent = metric
      ? `${(annualKwh).toFixed(0)} kWh delivered (${(annualOutputBtu / 1_000_000).toFixed(1)} million BTU)`
      : `${(annualOutputBtu / 1_000_000).toFixed(1)} million BTU delivered (${annualKwh.toFixed(0)} kWh)`
  }

  clear() {
    ["FuelUnits","AnnualCost","CostPerMBtu","Kwh"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Annual heating cost:",
      `Fuel used: ${this.resultFuelUnitsTarget.textContent}`,
      `Annual cost: ${this.resultAnnualCostTarget.textContent}`,
      `Energy delivered: ${this.resultKwhTarget.textContent}`,
      `Cost per million BTU: ${this.resultCostPerMBtuTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
