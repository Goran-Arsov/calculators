import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sourceFrequency", "sourceSpeed", "observerSpeed", "speedOfSound",
    "sourceDirection", "observerDirection",
    "results",
    "resultObservedFreq", "resultFreqShift", "resultPercentShift",
    "resultShiftDirection", "resultSourceWavelength", "resultObservedWavelength"
  ]

  calculate() {
    const fSource = parseFloat(this.sourceFrequencyTarget.value)
    const vSource = parseFloat(this.sourceSpeedTarget.value) || 0
    const vObserver = parseFloat(this.observerSpeedTarget.value) || 0
    const v = parseFloat(this.speedOfSoundTarget.value) || 343.0

    if (isNaN(fSource) || fSource <= 0 || v <= 0) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const sourceToward = this.sourceDirectionTarget.value === "toward"
    const observerToward = this.observerDirectionTarget.value === "toward"

    // f' = f * (v +/- v_observer) / (v -/+ v_source)
    const vObsSign = observerToward ? 1 : -1
    const vSrcSign = sourceToward ? -1 : 1

    const numerator = v + (vObsSign * vObserver)
    const denominator = v + (vSrcSign * vSource)

    if (denominator <= 0) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const fObserved = fSource * (numerator / denominator)
    const freqShift = fObserved - fSource
    const percentShift = (freqShift / fSource) * 100

    const sourceWavelength = v / fSource
    const observedWavelength = v / fObserved

    let shiftDir
    if (freqShift > 0.001) shiftDir = "Blueshift (higher frequency)"
    else if (freqShift < -0.001) shiftDir = "Redshift (lower frequency)"
    else shiftDir = "No shift"

    this.resultsTarget.classList.remove("hidden")
    this.resultObservedFreqTarget.textContent = this.fmt(fObserved) + " Hz"
    this.resultFreqShiftTarget.textContent = (freqShift >= 0 ? "+" : "") + this.fmt(freqShift) + " Hz"
    this.resultPercentShiftTarget.textContent = (percentShift >= 0 ? "+" : "") + percentShift.toFixed(2) + "%"
    this.resultShiftDirectionTarget.textContent = shiftDir
    this.resultSourceWavelengthTarget.textContent = this.fmt(sourceWavelength) + " m"
    this.resultObservedWavelengthTarget.textContent = this.fmt(observedWavelength) + " m"
  }

  fmt(n) {
    const abs = Math.abs(n)
    if (abs >= 1e6) return n.toExponential(4)
    if (abs >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    if (abs < 0.001 && abs > 0) return n.toExponential(4)
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const results = this.resultsTarget.querySelectorAll("[data-result]")
    const lines = Array.from(results).map(el => el.textContent)
    navigator.clipboard.writeText("Doppler Effect: " + lines.join(" | "))
  }
}
