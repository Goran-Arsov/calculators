import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "beforeLength", "afterLength", "beforeWidth", "afterWidth",
    "projectLength", "projectWidth",
    "resultLengthPct", "resultWidthPct", "resultAvgPct", "resultClassification",
    "resultCutLength", "resultCutWidth", "resultExtraLength", "resultExtraWidth",
    "projectResults"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const beforeLength = parseFloat(this.beforeLengthTarget.value) || 0
    const afterLength = parseFloat(this.afterLengthTarget.value) || 0
    const beforeWidth = parseFloat(this.beforeWidthTarget.value) || 0
    const afterWidth = parseFloat(this.afterWidthTarget.value) || 0

    if (beforeLength <= 0 || afterLength <= 0 || beforeWidth <= 0 || afterWidth <= 0) {
      this.clearResults()
      return
    }

    const lengthPct = ((beforeLength - afterLength) / beforeLength) * 100
    const widthPct = ((beforeWidth - afterWidth) / beforeWidth) * 100
    const avgPct = (lengthPct + widthPct) / 2

    this.resultLengthPctTarget.textContent = `${lengthPct.toFixed(2)}%`
    this.resultWidthPctTarget.textContent = `${widthPct.toFixed(2)}%`
    this.resultAvgPctTarget.textContent = `${avgPct.toFixed(2)}%`
    this.resultClassificationTarget.textContent = this.classify(avgPct)

    const projectLengthVal = this.hasProjectLengthTarget ? parseFloat(this.projectLengthTarget.value) : NaN
    const projectWidthVal = this.hasProjectWidthTarget ? parseFloat(this.projectWidthTarget.value) : NaN
    const projectMode = !isNaN(projectLengthVal) && projectLengthVal > 0 && !isNaN(projectWidthVal) && projectWidthVal > 0

    if (projectMode) {
      const lengthFactor = 1 - (lengthPct / 100)
      const widthFactor = 1 - (widthPct / 100)

      if (lengthFactor > 0 && widthFactor > 0) {
        const cutLength = projectLengthVal / lengthFactor
        const cutWidth = projectWidthVal / widthFactor
        const extraLength = cutLength - projectLengthVal
        const extraWidth = cutWidth - projectWidthVal

        this.resultCutLengthTarget.textContent = cutLength.toFixed(3)
        this.resultCutWidthTarget.textContent = cutWidth.toFixed(3)
        this.resultExtraLengthTarget.textContent = extraLength.toFixed(3)
        this.resultExtraWidthTarget.textContent = extraWidth.toFixed(3)
        if (this.hasProjectResultsTarget) this.projectResultsTarget.classList.remove("hidden")
      } else {
        if (this.hasProjectResultsTarget) this.projectResultsTarget.classList.add("hidden")
      }
    } else {
      if (this.hasProjectResultsTarget) this.projectResultsTarget.classList.add("hidden")
    }
  }

  classify(avgPct) {
    const abs = Math.abs(avgPct)
    if (avgPct < 0) return "Negative shrinkage — fabric stretched when washed"
    if (abs < 2) return "Minimal shrinkage (likely synthetic or pre-shrunk)"
    if (abs < 5) return "Low shrinkage (typical for treated cottons)"
    if (abs < 10) return "Moderate shrinkage (standard untreated cotton)"
    if (abs < 15) return "High shrinkage (linen, flannel, some wovens)"
    return "Very high shrinkage (some knits, unwashed linen, wool)"
  }

  clearResults() {
    this.resultLengthPctTarget.textContent = "0%"
    this.resultWidthPctTarget.textContent = "0%"
    this.resultAvgPctTarget.textContent = "0%"
    this.resultClassificationTarget.textContent = "—"
    if (this.hasProjectResultsTarget) this.projectResultsTarget.classList.add("hidden")
  }

  copy() {
    let text = `Fabric Shrinkage Results:\nLength Shrinkage: ${this.resultLengthPctTarget.textContent}\nWidth Shrinkage: ${this.resultWidthPctTarget.textContent}\nAverage: ${this.resultAvgPctTarget.textContent}\nClassification: ${this.resultClassificationTarget.textContent}`
    if (this.hasProjectResultsTarget && !this.projectResultsTarget.classList.contains("hidden")) {
      text += `\nCut Length: ${this.resultCutLengthTarget.textContent}\nCut Width: ${this.resultCutWidthTarget.textContent}\nExtra Length: ${this.resultExtraLengthTarget.textContent}\nExtra Width: ${this.resultExtraWidthTarget.textContent}`
    }
    navigator.clipboard.writeText(text)
  }
}
