import { Controller } from "@hotwired/stimulus"

const PANEL_WIDTH_M = 1.0
const PANEL_HEIGHT_M = 1.7
const PANEL_WATTAGE = 400
const EFFICIENCY_FACTOR = 0.80
const DAYS_PER_YEAR = 365

export default class extends Controller {
  static targets = ["roofLength", "roofWidth", "peakSunHours", "panelOrientation",
    "resultTotalPanels", "resultCapacityKw", "resultAnnualKwh",
    "resultPanelArea", "resultRoofArea", "resultCoverage",
    "resultPanelsLength", "resultPanelsWidth"]

  calculate() {
    const roofLength = parseFloat(this.roofLengthTarget.value) || 0
    const roofWidth = parseFloat(this.roofWidthTarget.value) || 0
    const peakSunHours = parseFloat(this.peakSunHoursTarget.value) || 5.0
    const orientation = this.panelOrientationTarget.value || "portrait"

    if (roofLength <= 0 || roofWidth <= 0 || peakSunHours <= 0) {
      this.clearResults()
      return
    }

    let panelW, panelH
    if (orientation === "landscape") {
      panelW = PANEL_HEIGHT_M
      panelH = PANEL_WIDTH_M
    } else {
      panelW = PANEL_WIDTH_M
      panelH = PANEL_HEIGHT_M
    }

    const panelsAlongLength = Math.floor(roofLength / panelW)
    const panelsAlongWidth = Math.floor(roofWidth / panelH)
    const totalPanels = panelsAlongLength * panelsAlongWidth

    const capacityKw = (totalPanels * PANEL_WATTAGE / 1000).toFixed(2)
    const annualKwh = Math.round(capacityKw * peakSunHours * DAYS_PER_YEAR * EFFICIENCY_FACTOR)

    const panelArea = (totalPanels * PANEL_WIDTH_M * PANEL_HEIGHT_M).toFixed(2)
    const roofArea = (roofLength * roofWidth).toFixed(2)
    const coverage = roofArea > 0 ? ((panelArea / roofArea) * 100).toFixed(1) : "0.0"

    this.resultTotalPanelsTarget.textContent = totalPanels
    this.resultCapacityKwTarget.textContent = `${capacityKw} kW`
    this.resultAnnualKwhTarget.textContent = `${annualKwh.toLocaleString()} kWh`
    this.resultPanelAreaTarget.textContent = `${panelArea} m\u00B2`
    this.resultRoofAreaTarget.textContent = `${roofArea} m\u00B2`
    this.resultCoverageTarget.textContent = `${coverage}%`
    this.resultPanelsLengthTarget.textContent = panelsAlongLength
    this.resultPanelsWidthTarget.textContent = panelsAlongWidth
  }

  clearResults() {
    this.resultTotalPanelsTarget.textContent = "0"
    this.resultCapacityKwTarget.textContent = "0 kW"
    this.resultAnnualKwhTarget.textContent = "0 kWh"
    this.resultPanelAreaTarget.textContent = "0 m\u00B2"
    this.resultRoofAreaTarget.textContent = "0 m\u00B2"
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
