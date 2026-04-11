import { Controller } from "@hotwired/stimulus"

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
  static targets = ["people", "bathrooms", "showers", "baths", "dishwasher", "clothesWasher",
                    "resultPeak", "resultTank", "resultFhr", "resultTankless"]

  connect() { this.calculate() }

  calculate() {
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
    let peak = showerCount * FIXTURE.shower
    peak += baths * FIXTURE.bath
    peak += people * FIXTURE.handWash
    peak += FIXTURE.kitchenSink
    if (dishwasher) peak += FIXTURE.dishwasher
    if (clothesWasher) peak += FIXTURE.clothesWasher

    const row = TANK_TABLE.find(r => people >= r.people[0] && people <= r.people[1] &&
                                     bathrooms >= r.baths[0] && bathrooms <= r.baths[1])
    const tank = row ? row.gal : 80
    let tankless = 5.0
    if (dishwasher || clothesWasher) tankless += 1.5

    this.resultPeakTarget.textContent = `${peak.toFixed(0)} gal`
    this.resultTankTarget.textContent = `${tank} gal`
    this.resultFhrTarget.textContent = `${peak.toFixed(0)} gal / hr`
    this.resultTanklessTarget.textContent = `${tankless.toFixed(1)} GPM`
  }

  clear() {
    ["resultPeak", "resultTank", "resultFhr", "resultTankless"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Water heater sizing:\nPeak-hour demand: ${this.resultPeakTarget.textContent}\nRecommended tank: ${this.resultTankTarget.textContent}\nRequired FHR: ${this.resultFhrTarget.textContent}\nTankless GPM: ${this.resultTanklessTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
