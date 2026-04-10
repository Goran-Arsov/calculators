import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "grainWeight", "grainTemp", "targetTemp", "ratio",
    "resultStrikeF", "resultStrikeC", "resultVolumeQt", "resultVolumeGal", "resultVolumeL"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const grainWeight = parseFloat(this.grainWeightTarget.value) || 0
    const grainTemp = parseFloat(this.grainTempTarget.value) || 0
    const targetTemp = parseFloat(this.targetTempTarget.value) || 0
    const ratio = parseFloat(this.ratioTarget.value) || 0

    if (grainWeight <= 0 || ratio <= 0 || targetTemp <= grainTemp) {
      this.clearResults()
      return
    }

    const strikeF = (0.2 / ratio) * (targetTemp - grainTemp) + targetTemp
    const strikeC = (strikeF - 32) * 5.0 / 9.0
    const volumeQt = grainWeight * ratio
    const volumeGal = volumeQt / 4.0
    const volumeL = volumeQt * 0.946353

    this.resultStrikeFTarget.textContent = strikeF.toFixed(1) + " °F"
    this.resultStrikeCTarget.textContent = strikeC.toFixed(1) + " °C"
    this.resultVolumeQtTarget.textContent = volumeQt.toFixed(2) + " qt"
    this.resultVolumeGalTarget.textContent = volumeGal.toFixed(2) + " gal"
    this.resultVolumeLTarget.textContent = volumeL.toFixed(2) + " L"
  }

  clearResults() {
    this.resultStrikeFTarget.textContent = "0 °F"
    this.resultStrikeCTarget.textContent = "0 °C"
    this.resultVolumeQtTarget.textContent = "0 qt"
    this.resultVolumeGalTarget.textContent = "0 gal"
    this.resultVolumeLTarget.textContent = "0 L"
  }

  copy() {
    const text = `Strike Water Temperature:\nStrike Temp: ${this.resultStrikeFTarget.textContent} (${this.resultStrikeCTarget.textContent})\nWater Volume: ${this.resultVolumeQtTarget.textContent} / ${this.resultVolumeGalTarget.textContent} / ${this.resultVolumeLTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
