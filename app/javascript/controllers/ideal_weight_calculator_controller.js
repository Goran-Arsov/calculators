import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["height", "gender", "frameSize", "unitSystem",
                     "devine", "robinson", "miller", "hamwi", "average",
                     "frameAdjusted", "idealMin", "idealMax", "unitLabel",
                     "heightLabel"]

  connect() {
    this.updateLabels()
  }

  updateLabels() {
    const unit = this.unitSystemTarget.value
    this.heightLabelTarget.textContent = unit === "imperial" ? "Height (inches)" : "Height (cm)"
    this.calculate()
  }

  calculate() {
    const height = parseFloat(this.heightTarget.value) || 0
    const gender = this.genderTarget.value
    const frame = this.frameSizeTarget.value
    const unit = this.unitSystemTarget.value

    if (height <= 0) {
      this.clearResults()
      return
    }

    const heightInches = unit === "imperial" ? height : height / 2.54
    const inchesOver = Math.max(heightInches - 60, 0)

    let devine, robinson, miller, hamwi
    if (gender === "male") {
      devine = (50.0 + 2.3 * inchesOver) * 2.20462
      robinson = (52.0 + 1.9 * inchesOver) * 2.20462
      miller = (56.2 + 1.41 * inchesOver) * 2.20462
      hamwi = (48.0 + 2.7 * inchesOver) * 2.20462
    } else {
      devine = (45.5 + 2.3 * inchesOver) * 2.20462
      robinson = (49.0 + 1.7 * inchesOver) * 2.20462
      miller = (53.1 + 1.36 * inchesOver) * 2.20462
      hamwi = (45.5 + 2.2 * inchesOver) * 2.20462
    }

    const avg = (devine + robinson + miller + hamwi) / 4

    const frameAdj = { small: 0.9, medium: 1.0, large: 1.1 }
    const adjusted = avg * (frameAdj[frame] || 1.0)
    const idealMin = adjusted * 0.90
    const idealMax = adjusted * 1.10

    const factor = unit === "imperial" ? 1 : 0.453592
    const unitLabel = unit === "imperial" ? "lbs" : "kg"

    this.devineTarget.textContent = `${this.fmt(devine * factor)} ${unitLabel}`
    this.robinsonTarget.textContent = `${this.fmt(robinson * factor)} ${unitLabel}`
    this.millerTarget.textContent = `${this.fmt(miller * factor)} ${unitLabel}`
    this.hamwiTarget.textContent = `${this.fmt(hamwi * factor)} ${unitLabel}`
    this.averageTarget.textContent = `${this.fmt(avg * factor)} ${unitLabel}`
    this.frameAdjustedTarget.textContent = `${this.fmt(adjusted * factor)} ${unitLabel}`
    this.idealMinTarget.textContent = `${this.fmt(idealMin * factor)} ${unitLabel}`
    this.idealMaxTarget.textContent = `${this.fmt(idealMax * factor)} ${unitLabel}`
  }

  clearResults() {
    const targets = ["devine", "robinson", "miller", "hamwi", "average", "frameAdjusted", "idealMin", "idealMax"]
    targets.forEach(t => this[`${t}Target`].textContent = "—")
  }

  copy() {
    const text = [
      `Devine: ${this.devineTarget.textContent}`,
      `Robinson: ${this.robinsonTarget.textContent}`,
      `Miller: ${this.millerTarget.textContent}`,
      `Hamwi: ${this.hamwiTarget.textContent}`,
      `Average: ${this.averageTarget.textContent}`,
      `Frame Adjusted: ${this.frameAdjustedTarget.textContent}`,
      `Ideal Range: ${this.idealMinTarget.textContent} – ${this.idealMaxTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return n.toFixed(1)
  }
}
