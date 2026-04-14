import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM, LB_TO_KG } from "utils/units"

const BAR_SIZES = {
  "#3": { diameter: 0.375, weightPerFt: 0.376 },
  "#4": { diameter: 0.500, weightPerFt: 0.668 },
  "#5": { diameter: 0.625, weightPerFt: 1.043 },
  "#6": { diameter: 0.750, weightPerFt: 1.502 },
  "#7": { diameter: 0.875, weightPerFt: 2.044 },
  "#8": { diameter: 1.000, weightPerFt: 2.670 }
}

const WASTE_FACTOR = 1.10
const STICK_LENGTH_FT = 20

export default class extends Controller {
  static targets = [
    "length", "width", "spacing", "barSize",
    "unitSystem", "lengthLabel", "widthLabel", "spacingLabel",
    "linearHeading", "weightHeading", "sticksHeading",
    "resultBarsLength", "resultBarsWidth", "resultTotalBars",
    "resultLinearFt", "resultWeight", "resultSticks"
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
    convert(this.lengthTarget, FT_TO_M)
    convert(this.widthTarget, FT_TO_M)
    convert(this.spacingTarget, IN_TO_CM)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Slab Length (m)" : "Slab Length (ft)"
    this.widthLabelTarget.textContent = metric ? "Slab Width (m)" : "Slab Width (ft)"
    this.spacingLabelTarget.textContent = metric ? "Spacing (cm OC)" : "Spacing (inches OC)"
    this.linearHeadingTarget.textContent = metric ? "Linear Meters (+10%)" : "Linear Feet (+10%)"
    this.weightHeadingTarget.textContent = "Total Weight"
    this.sticksHeadingTarget.textContent = metric ? "6 m Sticks" : "20-ft Sticks"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const spacing = parseFloat(this.spacingTarget.value) || (metric ? 30 : 12)
    const barSize = this.barSizeTarget.value || "#4"

    if (length <= 0 || width <= 0 || spacing <= 0 || !BAR_SIZES[barSize]) {
      this.clearResults()
      return
    }

    // Convert metric to imperial internally
    const lengthFt = metric ? length / FT_TO_M : length
    const widthFt = metric ? width / FT_TO_M : width
    const spacingIn = metric ? spacing / IN_TO_CM : spacing

    const barInfo = BAR_SIZES[barSize]

    const barsAlongLength = Math.floor((widthFt * 12) / spacingIn) + 1
    const barsAlongWidth = Math.floor((lengthFt * 12) / spacingIn) + 1
    const totalBars = barsAlongLength + barsAlongWidth

    const linearFtLengthBars = barsAlongLength * lengthFt
    const linearFtWidthBars = barsAlongWidth * widthFt
    const totalLinearFt = (linearFtLengthBars + linearFtWidthBars) * WASTE_FACTOR

    const totalWeightLbs = totalLinearFt * barInfo.weightPerFt

    this.resultBarsLengthTarget.textContent = barsAlongLength
    this.resultBarsWidthTarget.textContent = barsAlongWidth
    this.resultTotalBarsTarget.textContent = totalBars

    if (metric) {
      const totalLinearM = totalLinearFt * FT_TO_M
      const totalWeightKg = totalWeightLbs * LB_TO_KG
      // Metric sticks are typically 6 m
      const sticks = Math.ceil(totalLinearM / 6)
      this.resultLinearFtTarget.textContent = `${totalLinearM.toFixed(1)} m`
      this.resultWeightTarget.textContent = `${totalWeightKg.toFixed(1)} kg`
      this.resultSticksTarget.textContent = sticks
    } else {
      const sticks = Math.ceil(totalLinearFt / STICK_LENGTH_FT)
      this.resultLinearFtTarget.textContent = `${totalLinearFt.toFixed(1)} ft`
      this.resultWeightTarget.textContent = `${totalWeightLbs.toFixed(1)} lbs`
      this.resultSticksTarget.textContent = sticks
    }
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    this.resultBarsLengthTarget.textContent = "0"
    this.resultBarsWidthTarget.textContent = "0"
    this.resultTotalBarsTarget.textContent = "0"
    this.resultLinearFtTarget.textContent = metric ? "0 m" : "0 ft"
    this.resultWeightTarget.textContent = metric ? "0 kg" : "0 lbs"
    this.resultSticksTarget.textContent = "0"
  }

  copy() {
    const total = this.resultTotalBarsTarget.textContent
    const linear = this.resultLinearFtTarget.textContent
    const weight = this.resultWeightTarget.textContent
    const sticks = this.resultSticksTarget.textContent
    const text = `Rebar Estimate:\nTotal Bars: ${total}\n${this.linearHeadingTarget.textContent}: ${linear}\n${this.weightHeadingTarget.textContent}: ${weight}\n${this.sticksHeadingTarget.textContent}: ${sticks}`
    navigator.clipboard.writeText(text)
  }
}
