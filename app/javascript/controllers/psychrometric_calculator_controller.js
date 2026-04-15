import { Controller } from "@hotwired/stimulus"

const STANDARD_PRESSURE_HPA = 1013.25
const fToC = (f) => (f - 32) * 5 / 9
const cToF = (c) => c * 9 / 5 + 32

function stullWetBulb(tC, rh) {
  return tC * Math.atan(0.151977 * Math.sqrt(rh + 8.313659)) +
         Math.atan(tC + rh) -
         Math.atan(rh - 1.676331) +
         0.00391838 * Math.pow(rh, 1.5) * Math.atan(0.023101 * rh) -
         4.686035
}

export default class extends Controller {
  static targets = [
    "dryBulb", "rh",
    "unitSystem", "dryBulbLabel",
    "resultDewPoint", "resultWetBulb", "resultHumidityRatio",
    "resultVaporPressure", "resultEnthalpy"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const t = parseFloat(this.dryBulbTarget.value)
    if (Number.isFinite(t)) this.dryBulbTarget.value = (toMetric ? fToC(t) : cToF(t)).toFixed(1)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.dryBulbLabelTarget.textContent = metric ? "Dry bulb temperature (°C)" : "Dry bulb temperature (°F)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const input = parseFloat(this.dryBulbTarget.value)
    const rh = parseFloat(this.rhTarget.value) || 0

    if (!Number.isFinite(input) || rh < 0 || rh > 100) {
      this.clear()
      return
    }

    const tC = metric ? input : fToC(input)
    const tF = metric ? cToF(input) : input

    const pws = 6.112 * Math.exp(17.62 * tC / (243.12 + tC))
    const pw = pws * rh / 100
    const w = 0.622 * pw / (STANDARD_PRESSURE_HPA - pw)
    const wGrLb = w * 7000
    const enthalpyKjKg = 1.006 * tC + w * (2501 + 1.86 * tC)
    const enthalpyBtuLb = enthalpyKjKg * 0.4299

    let dpC
    if (pw <= 0) {
      dpC = tC
    } else {
      const ln = Math.log(pw / 6.112)
      dpC = 243.12 * ln / (17.62 - ln)
    }
    const dpF = cToF(dpC)

    const wbC = stullWetBulb(tC, rh)
    const wbF = cToF(wbC)

    if (metric) {
      this.resultDewPointTarget.textContent = `${dpC.toFixed(2)} °C (${dpF.toFixed(1)} °F)`
      this.resultWetBulbTarget.textContent = `${wbC.toFixed(2)} °C (${wbF.toFixed(1)} °F)`
      this.resultHumidityRatioTarget.textContent = `${w.toFixed(5)} kg/kg (${wGrLb.toFixed(1)} gr/lb)`
      this.resultVaporPressureTarget.textContent = `${pw.toFixed(2)} hPa (${(pw * 0.0145).toFixed(3)} psi)`
      this.resultEnthalpyTarget.textContent = `${enthalpyKjKg.toFixed(2)} kJ/kg (${enthalpyBtuLb.toFixed(2)} BTU/lb)`
    } else {
      this.resultDewPointTarget.textContent = `${dpF.toFixed(1)} °F (${dpC.toFixed(2)} °C)`
      this.resultWetBulbTarget.textContent = `${wbF.toFixed(1)} °F (${wbC.toFixed(2)} °C)`
      this.resultHumidityRatioTarget.textContent = `${wGrLb.toFixed(1)} gr/lb (${w.toFixed(5)} kg/kg)`
      this.resultVaporPressureTarget.textContent = `${(pw * 0.0145).toFixed(3)} psi (${pw.toFixed(2)} hPa)`
      this.resultEnthalpyTarget.textContent = `${enthalpyBtuLb.toFixed(2)} BTU/lb (${enthalpyKjKg.toFixed(2)} kJ/kg)`
    }
  }

  clear() {
    ["DewPoint","WetBulb","HumidityRatio","VaporPressure","Enthalpy"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Psychrometric properties:",
      `Dew point: ${this.resultDewPointTarget.textContent}`,
      `Wet bulb: ${this.resultWetBulbTarget.textContent}`,
      `Humidity ratio: ${this.resultHumidityRatioTarget.textContent}`,
      `Vapor pressure: ${this.resultVaporPressureTarget.textContent}`,
      `Enthalpy: ${this.resultEnthalpyTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
