import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM } from "utils/units"

// ENERGY STAR / AHAM pints per day table.
const TABLE = [
  [500,  10, 12, 14, 16],
  [1000, 14, 17, 20, 23],
  [1500, 18, 22, 26, 30],
  [2000, 22, 27, 32, 37],
  [2500, 26, 32, 38, 44],
  [3000, 30, 36, 42, 50]
]
const CONDITION_COL = { moderate: 1, very_damp: 2, wet: 3, extreme: 4 }
const PINTS_TO_LITERS = 0.473176

function interpolate(area, col) {
  if (area <= TABLE[0][0]) return TABLE[0][col]
  if (area >= TABLE[TABLE.length - 1][0]) return TABLE[TABLE.length - 1][col]
  for (let i = 0; i < TABLE.length - 1; i++) {
    const [s1, ...v1] = TABLE[i]
    const [s2, ...v2] = TABLE[i + 1]
    if (area >= s1 && area <= s2) {
      const a = v1[col - 1]
      const b = v2[col - 1]
      return a + (b - a) * (area - s1) / (s2 - s1)
    }
  }
  return TABLE[TABLE.length - 1][col]
}

export default class extends Controller {
  static targets = [
    "area", "condition",
    "unitSystem", "areaLabel",
    "resultPints", "resultLiters", "resultCategory"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const a = parseFloat(this.areaTarget.value)
    if (Number.isFinite(a)) this.areaTarget.value = (toMetric ? a * SQFT_TO_SQM : a / SQFT_TO_SQM).toFixed(0)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.areaLabelTarget.textContent = metric ? "Room or basement area (m²)" : "Room or basement area (sq ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const aInput = parseFloat(this.areaTarget.value) || 0
    const condition = this.conditionTarget.value
    const col = CONDITION_COL[condition]

    if (aInput <= 0 || !col) {
      this.clear()
      return
    }

    const areaSqft = metric ? aInput / SQFT_TO_SQM : aInput
    const pints = interpolate(areaSqft, col)
    const liters = pints * PINTS_TO_LITERS
    const category = pints <= 20 ? "Small portable" : pints <= 30 ? "Medium portable" : pints <= 50 ? "Large portable" : "Whole-house"

    if (metric) {
      this.resultPintsTarget.textContent = `${liters.toFixed(1)} L/day (${pints.toFixed(0)} pints/day)`
      this.resultLitersTarget.textContent = `${liters.toFixed(1)} L/day`
    } else {
      this.resultPintsTarget.textContent = `${pints.toFixed(0)} pints/day (${liters.toFixed(1)} L/day)`
      this.resultLitersTarget.textContent = `${liters.toFixed(1)} L/day`
    }
    this.resultCategoryTarget.textContent = category
  }

  clear() {
    ["Pints","Liters","Category"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Dehumidifier sizing:",
      `Capacity: ${this.resultPintsTarget.textContent}`,
      `Category: ${this.resultCategoryTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
