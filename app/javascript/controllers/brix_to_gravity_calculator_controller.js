import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "ogBrix", "fgBrix", "wcf",
    "resultOg", "resultFg", "resultAbv", "resultAttenuation"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const ogBrix = parseFloat(this.ogBrixTarget.value) || 0
    const fgBrixRaw = this.fgBrixTarget.value.trim()
    const fgBrix = fgBrixRaw === "" ? null : parseFloat(fgBrixRaw)
    const wcf = parseFloat(this.wcfTarget.value) || 1.04

    if (ogBrix <= 0 || ogBrix > 40 || wcf < 1.0 || wcf > 1.1) {
      this.clearResults()
      return
    }

    const ogCorrected = ogBrix / wcf
    const og = 1.0 + (ogCorrected / (258.6 - ((ogCorrected / 258.2) * 227.1)))
    this.resultOgTarget.textContent = og.toFixed(4)

    if (fgBrix !== null && !isNaN(fgBrix) && fgBrix > 0 && fgBrix <= ogBrix) {
      const ob = ogBrix / wcf
      const fb = fgBrix / wcf
      const fg = 1.0 - 0.0044993 * ob + 0.011774 * fb +
                 0.00027581 * ob * ob - 0.0012717 * fb * fb -
                 0.00000728 * ob * ob * ob + 0.000063293 * fb * fb * fb
      const abv = (og - fg) * 131.25
      const attenuation = ((og - fg) / (og - 1.0)) * 100.0

      this.resultFgTarget.textContent = fg.toFixed(4)
      this.resultAbvTarget.textContent = abv.toFixed(2) + "%"
      this.resultAttenuationTarget.textContent = attenuation.toFixed(1) + "%"
    } else {
      this.resultFgTarget.textContent = "—"
      this.resultAbvTarget.textContent = "—"
      this.resultAttenuationTarget.textContent = "—"
    }
  }

  clearResults() {
    this.resultOgTarget.textContent = "—"
    this.resultFgTarget.textContent = "—"
    this.resultAbvTarget.textContent = "—"
    this.resultAttenuationTarget.textContent = "—"
  }

  copy() {
    const text = `Refractometer Brix to Gravity:\nOG: ${this.resultOgTarget.textContent}\nFG: ${this.resultFgTarget.textContent}\nABV: ${this.resultAbvTarget.textContent}\nAttenuation: ${this.resultAttenuationTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
