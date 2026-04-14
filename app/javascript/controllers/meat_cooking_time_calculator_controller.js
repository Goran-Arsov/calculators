import { Controller } from "@hotwired/stimulus"
import { LB_TO_KG, fToC } from "utils/units"

export default class extends Controller {
  static targets = [
    "meatType", "cut", "weight", "doneness", "method",
    "cutOptions", "donenessOptions", "methodOptions",
    "unitSystem", "weightLabel",
    "results", "totalTime", "internalTemp", "restTime", "minutesPerLb"
  ]

  // Cooking data matching the Ruby PORO
  get cookingData() {
    return {
      beef: {
        roast: {
          rare: { oven: { mpl: 15, temp: 125 }, grill: { mpl: 13, temp: 125 } },
          medium_rare: { oven: { mpl: 18, temp: 135 }, grill: { mpl: 16, temp: 135 } },
          medium: { oven: { mpl: 20, temp: 145 }, grill: { mpl: 18, temp: 145 } },
          medium_well: { oven: { mpl: 23, temp: 155 }, grill: { mpl: 21, temp: 155 } },
          well_done: { oven: { mpl: 27, temp: 165 }, grill: { mpl: 25, temp: 165 } }
        },
        steak: {
          rare: { oven: { mpl: 12, temp: 125 }, grill: { mpl: 10, temp: 125 } },
          medium_rare: { oven: { mpl: 15, temp: 135 }, grill: { mpl: 12, temp: 135 } },
          medium: { oven: { mpl: 18, temp: 145 }, grill: { mpl: 14, temp: 145 } },
          medium_well: { oven: { mpl: 22, temp: 155 }, grill: { mpl: 17, temp: 155 } },
          well_done: { oven: { mpl: 25, temp: 165 }, grill: { mpl: 20, temp: 165 } }
        },
        brisket: {
          well_done: { oven: { mpl: 60, temp: 200 }, smoker: { mpl: 75, temp: 200 } }
        }
      },
      pork: {
        roast: {
          medium: { oven: { mpl: 20, temp: 145 }, grill: { mpl: 18, temp: 145 } },
          well_done: { oven: { mpl: 26, temp: 160 }, grill: { mpl: 24, temp: 160 } }
        },
        chops: {
          medium: { oven: { mpl: 18, temp: 145 }, grill: { mpl: 15, temp: 145 } },
          well_done: { oven: { mpl: 23, temp: 160 }, grill: { mpl: 20, temp: 160 } }
        },
        ribs: {
          well_done: { oven: { mpl: 40, temp: 190 }, smoker: { mpl: 60, temp: 190 } }
        },
        pulled_pork: {
          well_done: { oven: { mpl: 55, temp: 200 }, smoker: { mpl: 75, temp: 200 } }
        }
      },
      chicken: {
        whole: { well_done: { oven: { mpl: 20, temp: 165 }, grill: { mpl: 18, temp: 165 } } },
        breast: { well_done: { oven: { mpl: 22, temp: 165 }, grill: { mpl: 18, temp: 165 } } },
        thigh: { well_done: { oven: { mpl: 25, temp: 175 }, grill: { mpl: 22, temp: 175 } } }
      },
      turkey: {
        whole: { well_done: { oven: { mpl: 15, temp: 165 }, smoker: { mpl: 30, temp: 165 } } },
        breast: { well_done: { oven: { mpl: 20, temp: 165 }, smoker: { mpl: 35, temp: 165 } } }
      },
      lamb: {
        leg: {
          rare: { oven: { mpl: 15, temp: 125 }, grill: { mpl: 13, temp: 125 } },
          medium_rare: { oven: { mpl: 18, temp: 135 }, grill: { mpl: 16, temp: 135 } },
          medium: { oven: { mpl: 20, temp: 145 }, grill: { mpl: 18, temp: 145 } },
          well_done: { oven: { mpl: 25, temp: 170 }, grill: { mpl: 23, temp: 170 } }
        },
        rack: {
          rare: { oven: { mpl: 12, temp: 125 }, grill: { mpl: 10, temp: 125 } },
          medium_rare: { oven: { mpl: 15, temp: 135 }, grill: { mpl: 13, temp: 135 } },
          medium: { oven: { mpl: 18, temp: 145 }, grill: { mpl: 16, temp: 145 } },
          well_done: { oven: { mpl: 22, temp: 170 }, grill: { mpl: 20, temp: 170 } }
        },
        chops: {
          rare: { oven: { mpl: 10, temp: 125 }, grill: { mpl: 8, temp: 125 } },
          medium_rare: { oven: { mpl: 13, temp: 135 }, grill: { mpl: 11, temp: 135 } },
          medium: { oven: { mpl: 16, temp: 145 }, grill: { mpl: 14, temp: 145 } },
          well_done: { oven: { mpl: 20, temp: 170 }, grill: { mpl: 18, temp: 170 } }
        }
      }
    }
  }

  get labels() {
    return {
      roast: "Roast", steak: "Steak", brisket: "Brisket",
      chops: "Chops", ribs: "Ribs", pulled_pork: "Pulled Pork",
      whole: "Whole", breast: "Breast", thigh: "Thigh",
      leg: "Leg", rack: "Rack",
      rare: "Rare", medium_rare: "Medium Rare", medium: "Medium",
      medium_well: "Medium Well", well_done: "Well Done",
      oven: "Oven", grill: "Grill", smoker: "Smoker"
    }
  }

  connect() {
    this.updateLabels()
    this.updateCutOptions()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const weight = parseFloat(this.weightTarget.value)
    if (Number.isFinite(weight) && weight > 0) {
      this.weightTarget.value = (toMetric ? weight * LB_TO_KG : weight / LB_TO_KG).toFixed(2)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    if (this.hasWeightLabelTarget) {
      this.weightLabelTarget.textContent = metric ? "Weight (kg)" : "Weight (lbs)"
    }
  }

  updateCutOptions() {
    const meat = this.meatTypeTarget.value
    const cutSelect = this.cutOptionsTarget
    cutSelect.innerHTML = '<option value="">Select cut...</option>'

    if (meat && this.cookingData[meat]) {
      Object.keys(this.cookingData[meat]).forEach(cut => {
        const option = document.createElement("option")
        option.value = cut
        option.textContent = this.labels[cut] || cut.replace(/_/g, " ")
        cutSelect.appendChild(option)
      })
    }
    this.updateDonenessOptions()
  }

  updateDonenessOptions() {
    const meat = this.meatTypeTarget.value
    const cut = this.cutOptionsTarget.value
    const donenessSelect = this.donenessOptionsTarget
    donenessSelect.innerHTML = '<option value="">Select doneness...</option>'

    if (meat && cut && this.cookingData[meat] && this.cookingData[meat][cut]) {
      Object.keys(this.cookingData[meat][cut]).forEach(d => {
        const option = document.createElement("option")
        option.value = d
        option.textContent = this.labels[d] || d.replace(/_/g, " ")
        donenessSelect.appendChild(option)
      })
    }
    this.updateMethodOptions()
  }

  updateMethodOptions() {
    const meat = this.meatTypeTarget.value
    const cut = this.cutOptionsTarget.value
    const doneness = this.donenessOptionsTarget.value
    const methodSelect = this.methodOptionsTarget
    methodSelect.innerHTML = '<option value="">Select method...</option>'

    if (meat && cut && doneness && this.cookingData[meat] && this.cookingData[meat][cut] && this.cookingData[meat][cut][doneness]) {
      Object.keys(this.cookingData[meat][cut][doneness]).forEach(m => {
        const option = document.createElement("option")
        option.value = m
        option.textContent = this.labels[m] || m
        methodSelect.appendChild(option)
      })
    }
    this.calculate()
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const meat = this.meatTypeTarget.value
    const cut = this.cutOptionsTarget.value
    const doneness = this.donenessOptionsTarget.value
    const method = this.methodOptionsTarget.value
    const weightInput = parseFloat(this.weightTarget.value) || 0

    if (!meat || !cut || !doneness || !method || weightInput <= 0) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const data = this.cookingData[meat]?.[cut]?.[doneness]?.[method]
    if (!data) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    // Math internally in lbs / °F
    const weightLbs = metric ? weightInput / LB_TO_KG : weightInput
    const totalMinutes = Math.round(data.mpl * weightLbs)
    const hours = Math.floor(totalMinutes / 60)
    const minutes = totalMinutes % 60

    const restTime = this.getRestTime(meat, cut, weightLbs)

    this.totalTimeTarget.textContent = hours > 0 ? `${hours}h ${minutes}m` : `${minutes} minutes`
    if (metric) {
      this.internalTempTarget.textContent = `${Math.round(fToC(data.temp))} °C`
      // mpl is min per lb; express as min per kg for metric
      const mplKg = data.mpl / LB_TO_KG
      this.minutesPerLbTarget.textContent = `${mplKg.toFixed(1)} min/kg`
    } else {
      this.internalTempTarget.textContent = `${data.temp} °F`
      this.minutesPerLbTarget.textContent = `${data.mpl} min/lb`
    }
    this.restTimeTarget.textContent = `${restTime} minutes`
    this.resultsTarget.classList.remove("hidden")
  }

  getRestTime(meat, cut, weightLbs) {
    if (meat === "beef") return weightLbs >= 3 ? 20 : 10
    if (meat === "pork" && cut === "pulled_pork") return 30
    if (meat === "pork") return 10
    if (meat === "turkey") return weightLbs >= 10 ? 30 : 20
    if (meat === "lamb") return 15
    return 10
  }

  copy() {
    const text = [
      `Meat Cooking Time:`,
      `Total Time: ${this.totalTimeTarget.textContent}`,
      `Internal Temp: ${this.internalTempTarget.textContent}`,
      `Rest Time: ${this.restTimeTarget.textContent}`,
      `Rate: ${this.minutesPerLbTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
