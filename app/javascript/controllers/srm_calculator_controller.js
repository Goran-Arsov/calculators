import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "batchVolume",
    "malt1Weight", "malt1Lov",
    "malt2Weight", "malt2Lov",
    "malt3Weight", "malt3Lov",
    "malt4Weight", "malt4Lov",
    "resultMcu", "resultSrm", "resultEbc", "resultStyle", "resultSwatch"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const volume = parseFloat(this.batchVolumeTarget.value) || 0
    if (volume <= 0) { this.clearResults(); return }

    const malts = [
      [this.malt1WeightTarget, this.malt1LovTarget],
      [this.malt2WeightTarget, this.malt2LovTarget],
      [this.malt3WeightTarget, this.malt3LovTarget],
      [this.malt4WeightTarget, this.malt4LovTarget]
    ]

    let totalColor = 0
    malts.forEach(([w, l]) => {
      const weight = parseFloat(w.value) || 0
      const lov = parseFloat(l.value) || 0
      if (weight > 0 && lov > 0) totalColor += weight * lov
    })

    if (totalColor <= 0) { this.clearResults(); return }

    const mcu = totalColor / volume
    const srm = 1.4922 * Math.pow(mcu, 0.6859)
    const ebc = srm * 1.97

    this.resultMcuTarget.textContent = mcu.toFixed(2)
    this.resultSrmTarget.textContent = srm.toFixed(1)
    this.resultEbcTarget.textContent = ebc.toFixed(1)
    this.resultStyleTarget.textContent = this.style(srm)
    this.resultSwatchTarget.style.backgroundColor = this.hex(srm)
  }

  style(srm) {
    if (srm < 3) return "Pale straw (light lager, witbier)"
    if (srm < 6) return "Straw (pilsner, kölsch, helles)"
    if (srm < 9) return "Pale gold (blonde ale, weissbier)"
    if (srm < 14) return "Deep gold (pale ale, saison)"
    if (srm < 17) return "Amber (amber ale, ESB, märzen)"
    if (srm < 22) return "Copper (amber ale, bock)"
    if (srm < 30) return "Brown (brown ale, dunkel)"
    if (srm < 40) return "Dark brown (porter, doppelbock)"
    return "Black (stout, imperial stout)"
  }

  hex(srm) {
    const table = {
      1: "#FFE699", 2: "#FFD878", 3: "#FFCA5A", 4: "#FFBF42",
      5: "#FBB123", 6: "#F8A600", 7: "#F39C00", 8: "#EA8F00",
      9: "#E58500", 10: "#DE7C00", 11: "#D77200", 12: "#CF6900",
      13: "#CB6200", 14: "#C35900", 15: "#BB5100", 16: "#B54C00",
      17: "#B04500", 18: "#A63E00", 19: "#A13700", 20: "#9B3200",
      21: "#952D00", 22: "#8E2900", 23: "#882300", 24: "#821E00",
      25: "#7B1A00", 26: "#771900", 27: "#701400", 28: "#6A0E00",
      29: "#660D00", 30: "#5E0B00", 35: "#4E0900", 40: "#3D0708"
    }
    const keys = Object.keys(table).map(Number)
    const closest = keys.reduce((a, b) => Math.abs(b - srm) < Math.abs(a - srm) ? b : a)
    return table[closest]
  }

  clearResults() {
    this.resultMcuTarget.textContent = "0"
    this.resultSrmTarget.textContent = "0"
    this.resultEbcTarget.textContent = "0"
    this.resultStyleTarget.textContent = "—"
    this.resultSwatchTarget.style.backgroundColor = "#FFE699"
  }

  copy() {
    const text = `Beer Color (SRM):\nMCU: ${this.resultMcuTarget.textContent}\nSRM: ${this.resultSrmTarget.textContent}\nEBC: ${this.resultEbcTarget.textContent}\nStyle: ${this.resultStyleTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
