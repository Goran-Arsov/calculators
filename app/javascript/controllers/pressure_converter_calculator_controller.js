import { Controller } from "@hotwired/stimulus"

const UNITS = {
  pa:    { name: "Pascal",          symbol: "Pa",        to_pa: 1 },
  kpa:   { name: "Kilopascal",     symbol: "kPa",       to_pa: 1000 },
  mpa:   { name: "Megapascal",     symbol: "MPa",       to_pa: 1e6 },
  bar:   { name: "Bar",            symbol: "bar",       to_pa: 1e5 },
  psi:   { name: "PSI",            symbol: "psi",       to_pa: 6894.757293168 },
  atm:   { name: "Atmosphere",     symbol: "atm",       to_pa: 101325 },
  mmhg:  { name: "mmHg",           symbol: "mmHg",      to_pa: 133.322387415 },
  torr:  { name: "Torr",           symbol: "Torr",      to_pa: 133.322368421 },
  inhg:  { name: "Inches of Hg",   symbol: "inHg",      to_pa: 3386.389 },
  kgcm2: { name: "kgf/cm\u00B2",  symbol: "kgf/cm\u00B2", to_pa: 98066.5 }
}

export default class extends Controller {
  static targets = [
    "value", "fromUnit",
    "resultPa", "resultKpa", "resultMpa", "resultBar",
    "resultPsi", "resultAtm", "resultMmhg", "resultTorr",
    "resultInhg", "resultKgcm2",
    "resultsContainer"
  ]

  calculate() {
    const val = parseFloat(this.valueTarget.value)
    const from = this.fromUnitTarget.value

    if (isNaN(val) || !UNITS[from]) {
      this.clearResults()
      return
    }

    const pa = val * UNITS[from].to_pa

    this.resultsContainerTarget.classList.remove("hidden")
    this.resultPaTarget.textContent = this.fmt(pa) + " Pa"
    this.resultKpaTarget.textContent = this.fmt(pa / UNITS.kpa.to_pa) + " kPa"
    this.resultMpaTarget.textContent = this.fmt(pa / UNITS.mpa.to_pa) + " MPa"
    this.resultBarTarget.textContent = this.fmt(pa / UNITS.bar.to_pa) + " bar"
    this.resultPsiTarget.textContent = this.fmt(pa / UNITS.psi.to_pa) + " psi"
    this.resultAtmTarget.textContent = this.fmt(pa / UNITS.atm.to_pa) + " atm"
    this.resultMmhgTarget.textContent = this.fmt(pa / UNITS.mmhg.to_pa) + " mmHg"
    this.resultTorrTarget.textContent = this.fmt(pa / UNITS.torr.to_pa) + " Torr"
    this.resultInhgTarget.textContent = this.fmt(pa / UNITS.inhg.to_pa) + " inHg"
    this.resultKgcm2Target.textContent = this.fmt(pa / UNITS.kgcm2.to_pa) + " kgf/cm\u00B2"
  }

  clearResults() {
    this.resultsContainerTarget.classList.add("hidden")
  }

  fmt(n) {
    if (n === 0) return "0"
    const abs = Math.abs(n)
    if (abs >= 1e6) return n.toExponential(4)
    if (abs >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    if (abs >= 1) return n.toFixed(4).replace(/\.?0+$/, "")
    return n.toFixed(6).replace(/\.?0+$/, "")
  }

  copy() {
    const lines = [
      this.resultPaTarget.textContent,
      this.resultKpaTarget.textContent,
      this.resultBarTarget.textContent,
      this.resultPsiTarget.textContent,
      this.resultAtmTarget.textContent,
      this.resultMmhgTarget.textContent,
      this.resultTorrTarget.textContent
    ]
    navigator.clipboard.writeText(lines.join(" | "))
  }
}
