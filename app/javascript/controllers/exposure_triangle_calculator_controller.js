import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "currentIso", "currentAperture", "currentShutter",
    "newIso", "newAperture", "newShutter",
    "solveFor",
    "resultIso", "resultAperture", "resultShutter", "resultEv", "resultStops"
  ]

  calculate() {
    const curIso = parseFloat(this.currentIsoTarget.value) || 0
    const curAperture = parseFloat(this.currentApertureTarget.value) || 0
    const curShutter = parseFloat(this.currentShutterTarget.value) || 0
    const solveFor = this.solveForTarget.value

    if (curIso <= 0 || curAperture <= 0 || curShutter <= 0) {
      this.clearResults()
      return
    }

    // For equivalent exposure: N^2 / (t * ISO) = constant
    const currentEv = Math.log2(curAperture * curAperture / curShutter)
    const k = (curAperture * curAperture) / (curShutter * curIso)

    let newIso, newAperture, newShutter

    if (solveFor === "shutter") {
      newIso = parseFloat(this.newIsoTarget.value) || 0
      newAperture = parseFloat(this.newApertureTarget.value) || 0
      if (newIso <= 0 || newAperture <= 0) { this.clearResults(); return }
      // t = N^2 / (k * ISO)
      newShutter = (newAperture * newAperture) / (k * newIso)
    } else if (solveFor === "aperture") {
      newIso = parseFloat(this.newIsoTarget.value) || 0
      newShutter = parseFloat(this.newShutterTarget.value) || 0
      if (newIso <= 0 || newShutter <= 0) { this.clearResults(); return }
      // N^2 = k * t * ISO
      const apertureSq = k * newShutter * newIso
      newAperture = Math.sqrt(apertureSq)
    } else if (solveFor === "iso") {
      newAperture = parseFloat(this.newApertureTarget.value) || 0
      newShutter = parseFloat(this.newShutterTarget.value) || 0
      if (newAperture <= 0 || newShutter <= 0) { this.clearResults(); return }
      // ISO = N^2 / (k * t)
      newIso = (newAperture * newAperture) / (k * newShutter)
    } else {
      return
    }

    this.resultEvTarget.textContent = currentEv.toFixed(1)
    this.resultIsoTarget.textContent = Math.round(newIso)
    this.resultApertureTarget.textContent = `f/${newAperture.toFixed(1)}`
    this.resultShutterTarget.textContent = this.formatShutter(newShutter)
  }

  formatShutter(seconds) {
    if (seconds >= 1) return `${seconds.toFixed(1)}s`
    const denom = Math.round(1 / seconds)
    return `1/${denom}s`
  }

  clearResults() {
    this.resultEvTarget.textContent = "—"
    this.resultIsoTarget.textContent = "—"
    this.resultApertureTarget.textContent = "—"
    this.resultShutterTarget.textContent = "—"
  }

  copy() {
    const text = `Exposure Triangle Results:\nEV: ${this.resultEvTarget.textContent}\nISO: ${this.resultIsoTarget.textContent}\nAperture: ${this.resultApertureTarget.textContent}\nShutter: ${this.resultShutterTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
