import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM } from "utils/units"

export default class extends Controller {
  static targets = [
    "length", "height", "spacing", "corners", "openings",
    "unitSystem", "lengthLabel", "heightLabel", "spacingLabel",
    "plateHeading", "stockHeading",
    "resultFieldStuds", "resultCornerStuds", "resultOpeningStuds", "resultTotal",
    "resultPlate", "resultStock"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convertFt = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * FT_TO_M : n / FT_TO_M).toFixed(2)
    }
    convertFt(this.lengthTarget)
    convertFt(this.heightTarget)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Wall length (m)" : "Wall length (ft)"
    this.heightLabelTarget.textContent = metric ? "Wall height (m)" : "Wall height (ft)"
    this.spacingLabelTarget.textContent = metric ? "Stud spacing (mm OC, shown as inches)" : 'Stud spacing (inches OC)'
    this.plateHeadingTarget.textContent = metric ? "Plate stock (m)" : "Plate stock (ft)"
    this.stockHeadingTarget.textContent = metric ? "Stud stock (m)" : "Stud stock (ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const heightInput = parseFloat(this.heightTarget.value) || 0
    const spacingIn = parseFloat(this.spacingTarget.value) || 16
    const corners = parseInt(this.cornersTarget.value, 10) || 0
    const openings = parseInt(this.openingsTarget.value, 10) || 0

    if (lengthInput <= 0 || heightInput <= 0 || spacingIn <= 0 || corners < 0 || openings < 0) {
      this.clear()
      return
    }

    // Work in imperial internally (ft + inch spacing).
    const lengthFt = metric ? lengthInput / FT_TO_M : lengthInput
    const heightFt = metric ? heightInput / FT_TO_M : heightInput
    const lengthIn = lengthFt * 12

    const fieldStuds = Math.ceil(lengthIn / spacingIn) + 1
    const cornerStuds = corners * 2
    const openingStuds = openings * 4
    const totalStuds = fieldStuds + cornerStuds + openingStuds
    const plateLinearFt = lengthFt * 3
    const stockLinearFt = totalStuds * heightFt

    this.resultFieldStudsTarget.textContent = fieldStuds
    this.resultCornerStudsTarget.textContent = cornerStuds
    this.resultOpeningStudsTarget.textContent = openingStuds
    this.resultTotalTarget.textContent = totalStuds

    if (metric) {
      this.resultPlateTarget.textContent = `${(plateLinearFt * FT_TO_M).toFixed(2)} m (${plateLinearFt.toFixed(1)} ft)`
      this.resultStockTarget.textContent = `${(stockLinearFt * FT_TO_M).toFixed(2)} m (${stockLinearFt.toFixed(1)} ft)`
    } else {
      this.resultPlateTarget.textContent = `${plateLinearFt.toFixed(1)} ft (${(plateLinearFt * FT_TO_M).toFixed(2)} m)`
      this.resultStockTarget.textContent = `${stockLinearFt.toFixed(1)} ft (${(stockLinearFt * FT_TO_M).toFixed(2)} m)`
    }
  }

  clear() {
    this.resultFieldStudsTarget.textContent = "—"
    this.resultCornerStudsTarget.textContent = "—"
    this.resultOpeningStudsTarget.textContent = "—"
    this.resultTotalTarget.textContent = "—"
    this.resultPlateTarget.textContent = "—"
    this.resultStockTarget.textContent = "—"
  }

  copy() {
    const text = [
      "Stud Count:",
      `Field studs: ${this.resultFieldStudsTarget.textContent}`,
      `Corner studs: ${this.resultCornerStudsTarget.textContent}`,
      `Opening studs: ${this.resultOpeningStudsTarget.textContent}`,
      `Total studs: ${this.resultTotalTarget.textContent}`,
      `${this.plateHeadingTarget.textContent}: ${this.resultPlateTarget.textContent}`,
      `${this.stockHeadingTarget.textContent}: ${this.resultStockTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
