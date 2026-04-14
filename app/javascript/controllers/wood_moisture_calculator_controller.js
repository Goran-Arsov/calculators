import { Controller } from "@hotwired/stimulus"

// Wood moisture content is a weight ratio, so both weights must use the same
// unit and the resulting percentage is unit-independent. The toggle only
// changes label hints (g vs oz) so users know which unit to enter.

export default class extends Controller {
  static targets = [
    "wetWeight", "dryWeight",
    "unitSystem", "wetLabel", "dryLabel",
    "resultMc", "resultWater", "resultCategory", "resultSuitable"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.wetLabelTarget.textContent = metric ? "Wet Weight (g)" : "Wet Weight (oz)"
    this.dryLabelTarget.textContent = metric ? "Oven-Dry Weight (g)" : "Oven-Dry Weight (oz)"
  }

  calculate() {
    const wet = parseFloat(this.wetWeightTarget.value) || 0
    const dry = parseFloat(this.dryWeightTarget.value) || 0

    if (wet <= 0 || dry <= 0 || wet < dry) {
      this.clearResults()
      return
    }

    const mc = ((wet - dry) / dry) * 100
    const water = wet - dry
    const category = this.categorize(mc)
    const suitable = this.suitability(category)

    const metric = this.unitSystemTarget.value === "metric"
    const unit = metric ? " g" : " oz"

    this.resultMcTarget.textContent = `${mc.toFixed(2)}%`
    this.resultWaterTarget.textContent = `${water.toFixed(2)}${unit}`
    this.resultCategoryTarget.textContent = category
    this.resultSuitableTarget.textContent = suitable
  }

  clearResults() {
    this.resultMcTarget.textContent = "0.00%"
    this.resultWaterTarget.textContent = "0.00"
    this.resultCategoryTarget.textContent = "—"
    this.resultSuitableTarget.textContent = "—"
  }

  copy() {
    const text = `Wood Moisture Estimate:\nMoisture Content: ${this.resultMcTarget.textContent}\nWater Weight: ${this.resultWaterTarget.textContent}\nCategory: ${this.resultCategoryTarget.textContent}\nSuitability: ${this.resultSuitableTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  categorize(mc) {
    if (mc > 30) return "Green (above fiber saturation point)"
    if (mc >= 19 && mc <= 30) return "Wet / shipping dry"
    if (mc >= 14 && mc < 19) return "Air-dry"
    if (mc >= 6 && mc < 14) return "Kiln-dry (interior use)"
    return "Very dry / over-dried"
  }

  suitability(category) {
    switch (category) {
      case "Green (above fiber saturation point)":
        return "Not ready for use — continue drying before milling or joinery"
      case "Wet / shipping dry":
        return "Not ready for interior use — continue drying"
      case "Air-dry":
        return "Suitable for exterior use, outdoor furniture, and rough carpentry"
      case "Kiln-dry (interior use)":
        return "Suitable for indoor furniture, cabinetry, and flooring"
      case "Very dry / over-dried":
        return "Risk of checking and cracking — allow to re-equilibrate with ambient humidity"
      default:
        return "—"
    }
  }
}
