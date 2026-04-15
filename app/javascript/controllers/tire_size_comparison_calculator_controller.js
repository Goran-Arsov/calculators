import { Controller } from "@hotwired/stimulus"

const IN_TO_MM = 25.4
const MPH_TO_KMH = 1.609344

const formatInches = (v) => `${v.toFixed(2)}" (${(v * IN_TO_MM).toFixed(0)} mm)`
const formatInchesDelta = (v) => {
  const sign = v >= 0 ? "+" : ""
  return `${sign}${v.toFixed(2)}" (${sign}${(v * IN_TO_MM).toFixed(0)} mm)`
}

export default class extends Controller {
  static targets = [
    "tire1Width", "tire1Aspect", "tire1Rim",
    "tire2Width", "tire2Aspect", "tire2Rim",
    "tire1Diameter", "tire1Circumference", "tire1Sidewall", "tire1Revs",
    "tire2Diameter", "tire2Circumference", "tire2Sidewall", "tire2Revs",
    "diameterDiff", "circumferenceDiff", "speedoDiff", "actualSpeed"
  ]

  calculate() {
    const t1w = parseFloat(this.tire1WidthTarget.value) || 0
    const t1a = parseFloat(this.tire1AspectTarget.value) || 0
    const t1r = parseFloat(this.tire1RimTarget.value) || 0
    const t2w = parseFloat(this.tire2WidthTarget.value) || 0
    const t2a = parseFloat(this.tire2AspectTarget.value) || 0
    const t2r = parseFloat(this.tire2RimTarget.value) || 0

    if (t1w <= 0 || t1a <= 0 || t1r <= 0 || t2w <= 0 || t2a <= 0 || t2r <= 0) {
      this.clearResults()
      return
    }

    const tire1 = this.computeTire(t1w, t1a, t1r)
    const tire2 = this.computeTire(t2w, t2a, t2r)

    this.tire1DiameterTarget.textContent = formatInches(tire1.diameter)
    this.tire1CircumferenceTarget.textContent = formatInches(tire1.circumference)
    this.tire1SidewallTarget.textContent = formatInches(tire1.sidewall)
    this.tire1RevsTarget.textContent = tire1.revs.toFixed(0)

    this.tire2DiameterTarget.textContent = formatInches(tire2.diameter)
    this.tire2CircumferenceTarget.textContent = formatInches(tire2.circumference)
    this.tire2SidewallTarget.textContent = formatInches(tire2.sidewall)
    this.tire2RevsTarget.textContent = tire2.revs.toFixed(0)

    const dDiff = tire2.diameter - tire1.diameter
    const cDiff = tire2.circumference - tire1.circumference
    const speedoPct = (dDiff / tire1.diameter) * 100
    const actualAt60 = 60 * (1 + speedoPct / 100)

    this.diameterDiffTarget.textContent = formatInchesDelta(dDiff)
    this.circumferenceDiffTarget.textContent = formatInchesDelta(cDiff)
    this.speedoDiffTarget.textContent = (speedoPct >= 0 ? "+" : "") + speedoPct.toFixed(2) + "%"
    this.actualSpeedTarget.textContent = `${actualAt60.toFixed(1)} mph (${(actualAt60 * MPH_TO_KMH).toFixed(1)} km/h)`
  }

  computeTire(widthMm, aspect, rimIn) {
    const sidewallMm = widthMm * (aspect / 100)
    const sidewallIn = sidewallMm / 25.4
    const diameter = rimIn + 2 * sidewallIn
    const circumference = Math.PI * diameter
    const revs = 63360 / circumference
    return { diameter, circumference, sidewall: sidewallIn, revs }
  }

  clearResults() {
    const zero = formatInches(0)
    this.tire1DiameterTarget.textContent = zero
    this.tire1CircumferenceTarget.textContent = zero
    this.tire1SidewallTarget.textContent = zero
    this.tire1RevsTarget.textContent = "0"
    this.tire2DiameterTarget.textContent = zero
    this.tire2CircumferenceTarget.textContent = zero
    this.tire2SidewallTarget.textContent = zero
    this.tire2RevsTarget.textContent = "0"
    this.diameterDiffTarget.textContent = zero
    this.circumferenceDiffTarget.textContent = zero
    this.speedoDiffTarget.textContent = "0.00%"
    this.actualSpeedTarget.textContent = `60.0 mph (${(60 * MPH_TO_KMH).toFixed(1)} km/h)`
  }

  copy() {
    const text = `Tire 1 Diameter: ${this.tire1DiameterTarget.textContent}\nTire 2 Diameter: ${this.tire2DiameterTarget.textContent}\nDiameter Diff: ${this.diameterDiffTarget.textContent}\nSpeedometer Diff: ${this.speedoDiffTarget.textContent}\nActual Speed at 60: ${this.actualSpeedTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
