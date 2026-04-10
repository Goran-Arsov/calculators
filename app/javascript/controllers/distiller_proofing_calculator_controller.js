import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startAbv", "startVolume", "targetAbv",
    "resultStartProof", "resultTargetProof",
    "resultFinalL", "resultFinalGal",
    "resultWaterL", "resultWaterGal", "resultWaterMl"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const startAbv = parseFloat(this.startAbvTarget.value) || 0
    const startVolume = parseFloat(this.startVolumeTarget.value) || 0
    const targetAbv = parseFloat(this.targetAbvTarget.value) || 0

    if (startAbv <= 0 || startAbv > 95 || targetAbv <= 0 || targetAbv >= startAbv || startVolume <= 0) {
      this.clearResults()
      return
    }

    const finalL = startVolume * (startAbv / targetAbv)
    const waterL = finalL - startVolume

    this.resultStartProofTarget.textContent = (startAbv * 2).toFixed(1) + "°"
    this.resultTargetProofTarget.textContent = (targetAbv * 2).toFixed(1) + "°"
    this.resultFinalLTarget.textContent = finalL.toFixed(3) + " L"
    this.resultFinalGalTarget.textContent = (finalL / 3.78541).toFixed(3) + " gal"
    this.resultWaterLTarget.textContent = waterL.toFixed(3) + " L"
    this.resultWaterGalTarget.textContent = (waterL / 3.78541).toFixed(3) + " gal"
    this.resultWaterMlTarget.textContent = (waterL * 1000).toFixed(1) + " mL"
  }

  clearResults() {
    this.resultStartProofTarget.textContent = "—"
    this.resultTargetProofTarget.textContent = "—"
    this.resultFinalLTarget.textContent = "—"
    this.resultFinalGalTarget.textContent = "—"
    this.resultWaterLTarget.textContent = "—"
    this.resultWaterGalTarget.textContent = "—"
    this.resultWaterMlTarget.textContent = "—"
  }

  copy() {
    const text = `Distiller's Proofing:\nStart: ${this.resultStartProofTarget.textContent} → Target: ${this.resultTargetProofTarget.textContent}\nFinal Volume: ${this.resultFinalLTarget.textContent} (${this.resultFinalGalTarget.textContent})\nWater to Add: ${this.resultWaterLTarget.textContent} (${this.resultWaterGalTarget.textContent} / ${this.resultWaterMlTarget.textContent})`
    navigator.clipboard.writeText(text)
  }
}
