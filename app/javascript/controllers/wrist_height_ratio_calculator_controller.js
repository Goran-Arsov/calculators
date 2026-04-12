import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wrist", "height", "gender", "unit",
                     "frameSize", "ratio", "idealWeightKg", "idealWeightLbs",
                     "frameSizeRanges"]

  static maleFrames = { small: 16.5, large: 19.0 }
  static femaleFrames = { small: 14.0, large: 16.5 }

  calculate() {
    const wrist = parseFloat(this.wristTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const gender = this.genderTarget.value
    const unit = this.unitTarget.value

    if (wrist <= 0 || height <= 0 || !gender) {
      this.clearResults()
      return
    }

    const wristCm = unit === "inches" ? wrist * 2.54 : wrist
    const heightCm = unit === "inches" ? height * 2.54 : height

    const ratio = wristCm / heightCm
    const frames = gender === "male" ? this.constructor.maleFrames : this.constructor.femaleFrames
    let frameSize

    if (wristCm < frames.small) frameSize = "Small Frame"
    else if (wristCm >= frames.large) frameSize = "Large Frame"
    else frameSize = "Medium Frame"

    this.frameSizeTarget.textContent = frameSize
    this.ratioTarget.textContent = `${(ratio * 100).toFixed(2)}%`

    // Ideal weight (Hamwi)
    const heightInches = heightCm / 2.54
    let baseKg
    if (gender === "male") {
      baseKg = 48.0 + Math.max(0, (heightInches - 60) * 2.7)
    } else {
      baseKg = 45.5 + Math.max(0, (heightInches - 60) * 2.2)
    }

    let adj = 0
    if (frameSize === "Small Frame") adj = -0.10
    else if (frameSize === "Large Frame") adj = 0.10

    const minKg = (baseKg * (1 + adj) * 0.9).toFixed(1)
    const maxKg = (baseKg * (1 + adj) * 1.1).toFixed(1)
    const minLbs = (minKg * 2.20462).toFixed(1)
    const maxLbs = (maxKg * 2.20462).toFixed(1)

    this.idealWeightKgTarget.textContent = `${minKg} \u2013 ${maxKg} kg`
    this.idealWeightLbsTarget.textContent = `${minLbs} \u2013 ${maxLbs} lbs`

    this.buildFrameRanges(gender)
  }

  buildFrameRanges(gender) {
    const frames = gender === "male" ? this.constructor.maleFrames : this.constructor.femaleFrames
    const html = `
      <div class="flex justify-between text-sm py-1">
        <span class="text-gray-600 dark:text-gray-400">Small Frame</span>
        <span class="font-semibold text-gray-800 dark:text-gray-200">< ${frames.small} cm</span>
      </div>
      <div class="flex justify-between text-sm py-1">
        <span class="text-gray-600 dark:text-gray-400">Medium Frame</span>
        <span class="font-semibold text-gray-800 dark:text-gray-200">${frames.small} \u2013 ${frames.large} cm</span>
      </div>
      <div class="flex justify-between text-sm py-1">
        <span class="text-gray-600 dark:text-gray-400">Large Frame</span>
        <span class="font-semibold text-gray-800 dark:text-gray-200">> ${frames.large} cm</span>
      </div>
    `
    this.frameSizeRangesTarget.innerHTML = html
  }

  clearResults() {
    this.frameSizeTarget.textContent = "\u2014"
    this.ratioTarget.textContent = "\u2014"
    this.idealWeightKgTarget.textContent = "\u2014"
    this.idealWeightLbsTarget.textContent = "\u2014"
    this.frameSizeRangesTarget.innerHTML = ""
  }

  copy() {
    const text = [
      `Frame Size: ${this.frameSizeTarget.textContent}`,
      `Wrist-to-Height Ratio: ${this.ratioTarget.textContent}`,
      `Ideal Weight: ${this.idealWeightKgTarget.textContent} (${this.idealWeightLbsTarget.textContent})`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
