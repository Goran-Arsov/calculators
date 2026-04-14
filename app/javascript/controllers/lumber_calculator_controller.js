import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM, CUFT_TO_CUM } from "utils/units"

// 1 board foot = 1 in × 12 in × 1 ft = 144 cu in = 1/12 cu ft
const CUFT_PER_BF = 1 / 12
const CUM_PER_BF = CUFT_PER_BF * CUFT_TO_CUM

export default class extends Controller {
  static targets = [
    "thickness", "width", "length", "quantity", "pricePerBf",
    "unitSystem", "thicknessLabel", "widthLabel", "lengthLabel", "priceLabel",
    "bfHeading", "totalBfHeading", "linearHeading",
    "resultBfEach", "resultTotalBf", "resultLinearFt",
    "resultCostEach", "resultTotalCost"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(2)
    }
    convert(this.thicknessTarget, IN_TO_CM)
    convert(this.widthTarget, IN_TO_CM)
    convert(this.lengthTarget, FT_TO_M)
    // price is per board foot ↔ per m³
    convert(this.pricePerBfTarget, 1 / CUM_PER_BF)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.thicknessLabelTarget.textContent = metric ? "Thickness (cm)" : "Thickness (inches)"
    this.widthLabelTarget.textContent = metric ? "Width (cm)" : "Width (inches)"
    this.lengthLabelTarget.textContent = metric ? "Length (m)" : "Length (feet)"
    this.priceLabelTarget.textContent = metric ? "Price per m³ ($)" : "Price per Board Foot ($)"
    this.bfHeadingTarget.textContent = metric ? "Volume each (m³)" : "Board Feet (each)"
    this.totalBfHeadingTarget.textContent = metric ? "Total Volume (m³)" : "Total Board Feet"
    this.linearHeadingTarget.textContent = metric ? "Total Linear Meters" : "Total Linear Feet"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const thickness = parseFloat(this.thicknessTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const length = parseFloat(this.lengthTarget.value) || 0
    const quantity = parseInt(this.quantityTarget.value) || 1
    const pricePer = parseFloat(this.pricePerBfTarget.value) || 0

    if (thickness <= 0 || width <= 0 || length <= 0) {
      this.clearResults()
      return
    }

    // Convert metric inputs to imperial for canonical computation
    const thicknessIn = metric ? thickness / IN_TO_CM : thickness
    const widthIn = metric ? width / IN_TO_CM : width
    const lengthFt = metric ? length / FT_TO_M : length

    const bfEach = (thicknessIn * widthIn * lengthFt) / 12
    const totalBf = bfEach * quantity
    const linearFt = lengthFt * quantity

    if (metric) {
      const volEachM3 = bfEach * CUM_PER_BF
      const totalVolM3 = totalBf * CUM_PER_BF
      const linearM = linearFt * FT_TO_M
      // pricePer is $/m³
      const costEach = volEachM3 * pricePer
      const totalCost = totalVolM3 * pricePer
      this.resultBfEachTarget.textContent = volEachM3.toFixed(4)
      this.resultTotalBfTarget.textContent = totalVolM3.toFixed(4)
      this.resultLinearFtTarget.textContent = `${this.fmt(linearM)} m`
      this.resultCostEachTarget.textContent = this.currency(costEach)
      this.resultTotalCostTarget.textContent = this.currency(totalCost)
    } else {
      const costEach = bfEach * pricePer
      const totalCost = totalBf * pricePer
      this.resultBfEachTarget.textContent = bfEach.toFixed(4)
      this.resultTotalBfTarget.textContent = totalBf.toFixed(4)
      this.resultLinearFtTarget.textContent = `${this.fmt(linearFt)} ft`
      this.resultCostEachTarget.textContent = this.currency(costEach)
      this.resultTotalCostTarget.textContent = this.currency(totalCost)
    }
  }

  clearResults() {
    this.resultBfEachTarget.textContent = "0"
    this.resultTotalBfTarget.textContent = "0"
    this.resultLinearFtTarget.textContent = this.unitSystemTarget.value === "metric" ? "0 m" : "0 ft"
    this.resultCostEachTarget.textContent = "$0.00"
    this.resultTotalCostTarget.textContent = "$0.00"
  }

  copy() {
    const text = `Lumber Estimate:\n${this.bfHeadingTarget.textContent}: ${this.resultBfEachTarget.textContent}\n${this.totalBfHeadingTarget.textContent}: ${this.resultTotalBfTarget.textContent}\n${this.linearHeadingTarget.textContent}: ${this.resultLinearFtTarget.textContent}\nCost per Piece: ${this.resultCostEachTarget.textContent}\nTotal Cost: ${this.resultTotalCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  currency(n) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(n)
  }
}
