import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "meatType", "weight", "smokerTemp",
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

  calculate() {
    const meatType = this.meatTypeTarget.value
    const weight = parseFloat(this.weightTarget.value) || 0
    const smokerTemp = parseInt(this.smokerTempTarget.value) || 0

    if (!meatType || weight <= 0 || smokerTemp < 180 || smokerTemp > 400) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const data = this.smokeData[meatType]
    if (!data) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const tempRange = this.determineTempRange(smokerTemp)
    const baseMpl = data.mpl[tempRange]

    // Fine-tune based on exact temp
    const ranges = { low: { min: 200, max: 225 }, standard: { min: 225, max: 275 }, hot: { min: 275, max: 350 } }
    const range = ranges[tempRange]
    const midpoint = (range.min + range.max) / 2
    const adjustment = 1.0 + (midpoint - smokerTemp) * 0.003
    const adjustedMpl = (baseMpl * adjustment).toFixed(1)

    const totalMinutes = Math.round(adjustedMpl * weight)
    const hours = Math.floor(totalMinutes / 60)
    const minutes = totalMinutes % 60

    const stallMinutes = this.getStallTime(meatType, weight)
    const restMinutes = this.getRestTime(meatType, weight)
    const totalWithStall = totalMinutes + stallMinutes

    const twsHours = Math.floor(totalWithStall / 60)
    const twsMinutes = totalWithStall % 60

    const rangeLabels = {
      low: "Low & Slow (200-225 °F)",
      standard: "Standard (225-275 °F)",
      hot: "Hot & Fast (275-350 °F)"
    }

    this.totalTimeTarget.textContent = hours > 0 ? `${hours}h ${minutes}m` : `${minutes} min`
    this.targetTempTarget.textContent = `${data.target} °F`
    this.tempRangeTarget.textContent = rangeLabels[tempRange]
    this.minutesPerLbTarget.textContent = `${adjustedMpl} min/lb`
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

  getStallTime(meatType, weight) {
    const stallCuts = ["beef_brisket", "pork_butt", "beef_chuck_roast", "lamb_shoulder"]
    if (!stallCuts.includes(meatType) || weight < 3) return 0
    return Math.min(120, Math.max(30, Math.round(weight * 8)))
  }

  getRestTime(meatType, weight) {
    if (["beef_brisket", "pork_butt", "lamb_shoulder", "beef_chuck_roast"].includes(meatType)) {
      return weight >= 8 ? 60 : 30
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
