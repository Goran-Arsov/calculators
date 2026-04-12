import { Controller } from "@hotwired/stimulus"

const BAR_SIZES = {
  "#3": { diameter: 0.375, weightPerFt: 0.376 },
  "#4": { diameter: 0.500, weightPerFt: 0.668 },
  "#5": { diameter: 0.625, weightPerFt: 1.043 },
  "#6": { diameter: 0.750, weightPerFt: 1.502 },
  "#7": { diameter: 0.875, weightPerFt: 2.044 },
  "#8": { diameter: 1.000, weightPerFt: 2.670 }
}

const WASTE_FACTOR = 1.10

export default class extends Controller {
  static targets = ["length", "width", "spacing", "barSize",
    "resultBarsLength", "resultBarsWidth", "resultTotalBars",
    "resultLinearFt", "resultWeight", "resultSticks"]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const spacing = parseFloat(this.spacingTarget.value) || 12
    const barSize = this.barSizeTarget.value || "#4"

    if (length <= 0 || width <= 0 || spacing <= 0 || !BAR_SIZES[barSize]) {
      this.clearResults()
      return
    }

    const barInfo = BAR_SIZES[barSize]

    const barsAlongLength = Math.floor((width * 12) / spacing) + 1
    const barsAlongWidth = Math.floor((length * 12) / spacing) + 1
    const totalBars = barsAlongLength + barsAlongWidth

    const linearFtLengthBars = barsAlongLength * length
    const linearFtWidthBars = barsAlongWidth * width
    const totalLinearFt = ((linearFtLengthBars + linearFtWidthBars) * WASTE_FACTOR).toFixed(1)

    const totalWeight = (totalLinearFt * barInfo.weightPerFt).toFixed(1)
    const sticks20ft = Math.ceil(totalLinearFt / 20)

    this.resultBarsLengthTarget.textContent = barsAlongLength
    this.resultBarsWidthTarget.textContent = barsAlongWidth
    this.resultTotalBarsTarget.textContent = totalBars
    this.resultLinearFtTarget.textContent = `${totalLinearFt} ft`
    this.resultWeightTarget.textContent = `${totalWeight} lbs`
    this.resultSticksTarget.textContent = sticks20ft
  }

  clearResults() {
    this.resultBarsLengthTarget.textContent = "0"
    this.resultBarsWidthTarget.textContent = "0"
    this.resultTotalBarsTarget.textContent = "0"
    this.resultLinearFtTarget.textContent = "0 ft"
    this.resultWeightTarget.textContent = "0 lbs"
    this.resultSticksTarget.textContent = "0"
  }

  copy() {
    const total = this.resultTotalBarsTarget.textContent
    const linear = this.resultLinearFtTarget.textContent
    const weight = this.resultWeightTarget.textContent
    const sticks = this.resultSticksTarget.textContent
    const text = `Rebar Estimate:\nTotal Bars: ${total}\nLinear Feet: ${linear}\nWeight: ${weight}\n20ft Sticks: ${sticks}`
    navigator.clipboard.writeText(text)
  }
}
