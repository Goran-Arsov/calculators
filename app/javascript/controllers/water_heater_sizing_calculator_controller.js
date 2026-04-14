import { Controller } from "@hotwired/stimulus"
import { GAL_TO_L } from "utils/units"

const FIXTURE = {
  shower: 10,
  bath: 20,
  handWash: 2,
  kitchenSink: 4,
  dishwasher: 6,
  clothesWasher: 7
}

const TANK_TABLE = [
  { people: [1, 2], baths: [1, 1], gal: 30 },
  { people: [1, 2], baths: [2, 99], gal: 40 },
  { people: [3, 3], baths: [1, 1], gal: 40 },
  { people: [3, 3], baths: [2, 99], gal: 50 },
  { people: [4, 4], baths: [1, 2], gal: 50 },
  { people: [4, 4], baths: [3, 99], gal: 75 },
  { people: [5, 6], baths: [1, 99], gal: 75 },
  { people: [7, 99], baths: [1, 99], gal: 80 }
]

export default class extends Controller {
  static targets = [
    "people", "bathrooms", "showers", "baths", "dishwasher", "clothesWasher",
    "unitSystem", "tanklessHeading",
    "resultPeak", "resultTank", "resultFhr", "resultTankless"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.tanklessHeadingTarget.textContent = metric ? "Tankless L/min" : "Tankless GPM"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const people = parseInt(this.peopleTarget.value, 10)
    const bathrooms = parseInt(this.bathroomsTarget.value, 10)
    const showers = parseInt(this.showersTarget.value, 10)
    const baths = parseInt(this.bathsTarget.value, 10) || 0
    const dishwasher = this.dishwasherTarget.checked
    const clothesWasher = this.clothesWasherTarget.checked

    if (!Number.isFinite(people) || people < 1 ||
        !Number.isFinite(bathrooms) || bathrooms < 1) {
      this.clear()
      return
    }

    const showerCount = Number.isFinite(showers) && showers >= 0 ? showers : people
    let peakGal = showerCount * FIXTURE.shower
    peakGal += baths * FIXTURE.bath
    peakGal += people * FIXTURE.handWash
    peakGal += FIXTURE.kitchenSink
    if (dishwasher) peakGal += FIXTURE.dishwasher
    if (clothesWasher) peakGal += FIXTURE.clothesWasher

    const row = TANK_TABLE.find(r => people >= r.people[0] && people <= r.people[1] &&
                                     bathrooms >= r.baths[0] && bathrooms <= r.baths[1])
    const tankGal = row ? row.gal : 80
    let tanklessGpm = 5.0
    if (dishwasher || clothesWasher) tanklessGpm += 1.5

    if (metric) {
      const peakL = peakGal * GAL_TO_L
      const tankL = tankGal * GAL_TO_L
      const tanklessLpm = tanklessGpm * GAL_TO_L
      this.resultPeakTarget.textContent = `${peakL.toFixed(0)} L`
      this.resultTankTarget.textContent = `${tankL.toFixed(0)} L`
      this.resultFhrTarget.textContent = `${peakL.toFixed(0)} L / hr`
      this.resultTanklessTarget.textContent = `${tanklessLpm.toFixed(1)} L/min`
    } else {
      this.resultPeakTarget.textContent = `${peakGal.toFixed(0)} gal`
      this.resultTankTarget.textContent = `${tankGal} gal`
      this.resultFhrTarget.textContent = `${peakGal.toFixed(0)} gal / hr`
      this.resultTanklessTarget.textContent = `${tanklessGpm.toFixed(1)} GPM`
    }
  }

  clear() {
    ["resultPeak", "resultTank", "resultFhr", "resultTankless"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Water heater sizing:\nPeak-hour demand: ${this.resultPeakTarget.textContent}\nRecommended tank: ${this.resultTankTarget.textContent}\nRequired FHR: ${this.resultFhrTarget.textContent}\n${this.tanklessHeadingTarget.textContent}: ${this.resultTanklessTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
