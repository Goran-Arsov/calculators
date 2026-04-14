import { Controller } from "@hotwired/stimulus"
import { LB_TO_KG, fToC, cToF } from "utils/units"

export default class extends Controller {
  static targets = [
    "meatType", "weight", "smokerTemp",
    "unitSystem", "weightLabel", "smokerTempLabel",
    "results", "totalTime", "targetTemp", "tempRange",
    "minutesPerLb", "stallTime", "restTime", "totalWithStall"
  ]

  get smokeData() {
    return {
      beef_brisket: { target: 200, mpl: { low: 90, standard: 75, hot: 60 } },
      pork_butt: { target: 200, mpl: { low: 90, standard: 75, hot: 60 } },
      pork_ribs: { target: 190, mpl: { low: 75, standard: 60, hot: 45 } },
      whole_chicken: { target: 165, mpl: { low: 45, standard: 30, hot: 25 } },
      turkey_breast: { target: 165, mpl: { low: 40, standard: 35, hot: 25 } },
      whole_turkey: { target: 165, mpl: { low: 35, standard: 30, hot: 20 } },
      salmon: { target: 145, mpl: { low: 45, standard: 35, hot: 25 } },
      pork_loin: { target: 145, mpl: { low: 50, standard: 40, hot: 30 } },
      lamb_shoulder: { target: 190, mpl: { low: 75, standard: 60, hot: 45 } },
      beef_chuck_roast: { target: 200, mpl: { low: 75, standard: 60, hot: 50 } },
      sausage: { target: 165, mpl: { low: 50, standard: 40, hot: 30 } }
    }
  }

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const weight = parseFloat(this.weightTarget.value)
    if (Number.isFinite(weight) && weight > 0) {
      this.weightTarget.value = (toMetric ? weight * LB_TO_KG : weight / LB_TO_KG).toFixed(2)
    }
    const temp = parseFloat(this.smokerTempTarget.value)
    if (Number.isFinite(temp)) {
      this.smokerTempTarget.value = Math.round(toMetric ? fToC(temp) : cToF(temp))
    }
    if (toMetric) {
      this.smokerTempTarget.min = 90
      this.smokerTempTarget.max = 205
      this.smokerTempTarget.placeholder = "110"
    } else {
      this.smokerTempTarget.min = 180
      this.smokerTempTarget.max = 400
      this.smokerTempTarget.placeholder = "225"
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    if (this.hasWeightLabelTarget) {
      this.weightLabelTarget.textContent = metric ? "Weight (kg)" : "Weight (lbs)"
    }
    if (this.hasSmokerTempLabelTarget) {
      this.smokerTempLabelTarget.textContent = metric ? "Smoker Temperature (°C)" : "Smoker Temperature (°F)"
    }
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const meatType = this.meatTypeTarget.value
    const weightInput = parseFloat(this.weightTarget.value) || 0
    const tempInput = parseFloat(this.smokerTempTarget.value) || 0

    // Math internally in lbs / °F
    const weightLbs = metric ? weightInput / LB_TO_KG : weightInput
    const smokerTempF = metric ? cToF(tempInput) : tempInput

    if (!meatType || weightLbs <= 0 || smokerTempF < 180 || smokerTempF > 400) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const data = this.smokeData[meatType]
    if (!data) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const tempRange = this.determineTempRange(smokerTempF)
    const baseMpl = data.mpl[tempRange]

    // Fine-tune based on exact temp
    const ranges = { low: { min: 200, max: 225 }, standard: { min: 225, max: 275 }, hot: { min: 275, max: 350 } }
    const range = ranges[tempRange]
    const midpoint = (range.min + range.max) / 2
    const adjustment = 1.0 + (midpoint - smokerTempF) * 0.003
    const adjustedMpl = parseFloat((baseMpl * adjustment).toFixed(1))

    const totalMinutes = Math.round(adjustedMpl * weightLbs)
    const hours = Math.floor(totalMinutes / 60)
    const minutes = totalMinutes % 60

    const stallMinutes = this.getStallTime(meatType, weightLbs)
    const restMinutes = this.getRestTime(meatType, weightLbs)
    const totalWithStall = totalMinutes + stallMinutes

    const twsHours = Math.floor(totalWithStall / 60)
    const twsMinutes = totalWithStall % 60

    const rangeLabels = metric ? {
      low: "Low & Slow (93-107 °C)",
      standard: "Standard (107-135 °C)",
      hot: "Hot & Fast (135-177 °C)"
    } : {
      low: "Low & Slow (200-225 °F)",
      standard: "Standard (225-275 °F)",
      hot: "Hot & Fast (275-350 °F)"
    }

    this.totalTimeTarget.textContent = hours > 0 ? `${hours}h ${minutes}m` : `${minutes} min`

    if (metric) {
      this.targetTempTarget.textContent = `${Math.round(fToC(data.target))} °C`
      const mplKg = adjustedMpl / LB_TO_KG
      this.minutesPerLbTarget.textContent = `${mplKg.toFixed(1)} min/kg`
    } else {
      this.targetTempTarget.textContent = `${data.target} °F`
      this.minutesPerLbTarget.textContent = `${adjustedMpl} min/lb`
    }

    this.tempRangeTarget.textContent = rangeLabels[tempRange]
    this.stallTimeTarget.textContent = stallMinutes > 0 ? `~${stallMinutes} min` : "None expected"
    this.restTimeTarget.textContent = `${restMinutes} min`
    this.totalWithStallTarget.textContent = twsHours > 0 ? `${twsHours}h ${twsMinutes}m` : `${twsMinutes} min`
    this.resultsTarget.classList.remove("hidden")
  }

  determineTempRange(temp) {
    if (temp < 225) return "low"
    if (temp < 275) return "standard"
    return "hot"
  }

  getStallTime(meatType, weightLbs) {
    const stallCuts = ["beef_brisket", "pork_butt", "beef_chuck_roast", "lamb_shoulder"]
    if (!stallCuts.includes(meatType) || weightLbs < 3) return 0
    return Math.min(120, Math.max(30, Math.round(weightLbs * 8)))
  }

  getRestTime(meatType, weightLbs) {
    if (["beef_brisket", "pork_butt", "lamb_shoulder", "beef_chuck_roast"].includes(meatType)) {
      return weightLbs >= 8 ? 60 : 30
    }
    if (meatType === "whole_turkey") return 30
    if (meatType === "pork_ribs") return 15
    return 15
  }

  copy() {
    const text = [
      `BBQ Smoke Time Results:`,
      `Cook Time: ${this.totalTimeTarget.textContent}`,
      `With Stall: ${this.totalWithStallTarget.textContent}`,
      `Target Temp: ${this.targetTempTarget.textContent}`,
      `Rest Time: ${this.restTimeTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
