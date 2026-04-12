import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rise", "unit",
                     "adaRun", "adaLength", "adaAngle", "adaLandings",
                     "commercialRun", "commercialLength", "commercialAngle", "commercialLandings"]

  static ADA_RATIO = 12
  static COMMERCIAL_RATIO = 16
  static MAX_RUN_INCHES = 360
  static LANDING_INCHES = 60

  calculate() {
    const rise = parseFloat(this.riseTarget.value) || 0
    const unit = this.unitTarget.value

    if (rise <= 0) {
      this.clearResults()
      return
    }

    const riseInches = unit === "cm" ? rise / 2.54 : rise

    // ADA 1:12
    const adaRun = riseInches * this.constructor.ADA_RATIO
    const adaLength = Math.sqrt(riseInches ** 2 + adaRun ** 2)
    const adaAngle = Math.atan2(riseInches, adaRun) * (180 / Math.PI)
    let adaLandings = Math.ceil(adaRun / this.constructor.MAX_RUN_INCHES)
    adaLandings = Math.max(adaLandings - 1, 0)

    // Commercial 1:16
    const comRun = riseInches * this.constructor.COMMERCIAL_RATIO
    const comLength = Math.sqrt(riseInches ** 2 + comRun ** 2)
    const comAngle = Math.atan2(riseInches, comRun) * (180 / Math.PI)
    let comLandings = Math.ceil(comRun / this.constructor.MAX_RUN_INCHES)
    comLandings = Math.max(comLandings - 1, 0)

    this.adaRunTarget.textContent = `${(adaRun / 12).toFixed(1)} ft (${(adaRun * 0.0254).toFixed(2)} m)`
    this.adaLengthTarget.textContent = `${(adaLength / 12).toFixed(1)} ft`
    this.adaAngleTarget.textContent = `${adaAngle.toFixed(2)}\u00B0`
    this.adaLandingsTarget.textContent = adaLandings > 0 ? `${adaLandings} landing(s) required` : "No intermediate landings needed"

    this.commercialRunTarget.textContent = `${(comRun / 12).toFixed(1)} ft (${(comRun * 0.0254).toFixed(2)} m)`
    this.commercialLengthTarget.textContent = `${(comLength / 12).toFixed(1)} ft`
    this.commercialAngleTarget.textContent = `${comAngle.toFixed(2)}\u00B0`
    this.commercialLandingsTarget.textContent = comLandings > 0 ? `${comLandings} landing(s) required` : "No intermediate landings needed"
  }

  clearResults() {
    const targets = [this.adaRunTarget, this.adaLengthTarget, this.adaAngleTarget, this.adaLandingsTarget,
                     this.commercialRunTarget, this.commercialLengthTarget, this.commercialAngleTarget, this.commercialLandingsTarget]
    targets.forEach(t => t.textContent = "\u2014")
  }

  copy() {
    const text = [
      "ADA (1:12):",
      `  Run: ${this.adaRunTarget.textContent}`,
      `  Ramp Length: ${this.adaLengthTarget.textContent}`,
      `  Angle: ${this.adaAngleTarget.textContent}`,
      `  Landings: ${this.adaLandingsTarget.textContent}`,
      "",
      "Commercial (1:16):",
      `  Run: ${this.commercialRunTarget.textContent}`,
      `  Ramp Length: ${this.commercialLengthTarget.textContent}`,
      `  Angle: ${this.commercialAngleTarget.textContent}`,
      `  Landings: ${this.commercialLandingsTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
