import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, SQFT_TO_SQM } from "utils/units"

const PANEL_WIDTH_M = 1.0
const PANEL_HEIGHT_M = 1.7
const PANEL_WATTAGE = 400
const EFFICIENCY_FACTOR = 0.80
const DAYS_PER_YEAR = 365

export default class extends Controller {
  static targets = [
    "roofLength", "roofWidth", "peakSunHours", "panelOrientation",
    "unitSystem", "roofLengthLabel", "roofWidthLabel",
    "resultTotalPanels", "resultCapacityKw", "resultAnnualKwh",
    "resultPanelArea", "resultRoofArea", "resultCoverage",
    "resultPanelsLength", "resultPanelsWidth"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toImperial = this.unitSystemTarget.value === "imperial"
    const convert = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toImperial ? n / FT_TO_M : n * FT_TO_M).toFixed(2)
    }
    convert(this.roofLengthTarget)
    convert(this.roofWidthTarget)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const imperial = this.unitSystemTarget.value === "imperial"
    this.roofLengthLabelTarget.textContent = imperial ? "Roof Length (feet)" : "Roof Length (meters)"
    this.roofWidthLabelTarget.textContent = imperial ? "Roof Width (feet)" : "Roof Width (meters)"
  }

  calculate() {
    const imperial = this.unitSystemTarget.value === "imperial"
    const roofLength = parseFloat(this.roofLengthTarget.value) || 0
    const roofWidth = parseFloat(this.roofWidthTarget.value) || 0
    const peakSunHours = parseFloat(this.peakSunHoursTarget.value) || 5.0
    const orientation = this.panelOrientationTarget.value || "portrait"

    if (roofLength <= 0 || roofWidth <= 0 || peakSunHours <= 0) {
      this.clearResults()
      return
    }

    // Canonical math in meters
    const roofLengthM = imperial ? roofLength * FT_TO_M : roofLength
    const roofWidthM = imperial ? roofWidth * FT_TO_M : roofWidth

    let panelW, panelH
    if (orientation === "landscape") {
      panelW = PANEL_HEIGHT_M
      panelH = PANEL_WIDTH_M
    } else {
      panelW = PANEL_WIDTH_M
      panelH = PANEL_HEIGHT_M
    }

    const panelsAlongLength = Math.floor(roofLengthM / panelW)
    const panelsAlongWidth = Math.floor(roofWidthM / panelH)
    const totalPanels = panelsAlongLength * panelsAlongWidth

    const capacityKw = (totalPanels * PANEL_WATTAGE / 1000)
    const annualKwh = Math.round(capacityKw * peakSunHours * DAYS_PER_YEAR * EFFICIENCY_FACTOR)

    const panelAreaM2 = totalPanels * PANEL_WIDTH_M * PANEL_HEIGHT_M
    const roofAreaM2 = roofLengthM * roofWidthM
    const coverage = roofAreaM2 > 0 ? ((panelAreaM2 / roofAreaM2) * 100).toFixed(1) : "0.0"

    this.resultTotalPanelsTarget.textContent = totalPanels
    this.resultCapacityKwTarget.textContent = `${capacityKw.toFixed(2)} kW`
    this.resultAnnualKwhTarget.textContent = `${annualKwh.toLocaleString()} kWh`
    this.resultCoverageTarget.textContent = `${coverage}%`
    this.resultPanelsLengthTarget.textContent = panelsAlongLength
    this.resultPanelsWidthTarget.textContent = panelsAlongWidth

    if (imperial) {
      const panelAreaSqft = panelAreaM2 / SQFT_TO_SQM
      const roofAreaSqft = roofAreaM2 / SQFT_TO_SQM
      this.resultPanelAreaTarget.textContent = `${panelAreaSqft.toFixed(2)} sq ft`
      this.resultRoofAreaTarget.textContent = `${roofAreaSqft.toFixed(2)} sq ft`
    } else {
      this.resultPanelAreaTarget.textContent = `${panelAreaM2.toFixed(2)} m²`
      this.resultRoofAreaTarget.textContent = `${roofAreaM2.toFixed(2)} m²`
    }
  }

  clearResults() {
    const imperial = this.unitSystemTarget.value === "imperial"
    const unit = imperial ? "sq ft" : "m²"
    this.resultTotalPanelsTarget.textContent = "0"
    this.resultCapacityKwTarget.textContent = "0 kW"
    this.resultAnnualKwhTarget.textContent = "0 kWh"
    this.resultPanelAreaTarget.textContent = `0 ${unit}`
    this.resultRoofAreaTarget.textContent = `0 ${unit}`
    this.resultCoverageTarget.textContent = "0%"
    this.resultPanelsLengthTarget.textContent = "0"
    this.resultPanelsWidthTarget.textContent = "0"
  }

  copy() {
    const panels = this.resultTotalPanelsTarget.textContent
    const capacity = this.resultCapacityKwTarget.textContent
    const annual = this.resultAnnualKwhTarget.textContent
    const coverage = this.resultCoverageTarget.textContent
    const text = `Solar Panel Layout Estimate:\nTotal Panels: ${panels}\nCapacity: ${capacity}\nAnnual Output: ${annual}\nRoof Coverage: ${coverage}`
    navigator.clipboard.writeText(text)
  }
}
