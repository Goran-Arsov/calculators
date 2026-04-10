import { Controller } from "@hotwired/stimulus"

const YARDAGE_TABLE = {
  "scarf":     { "small":  [500, 400, 350, 300, 250, 200, 180, 150],
                 "medium": [700, 600, 500, 450, 400, 350, 300, 250],
                 "large":  [900, 800, 700, 600, 550, 500, 400, 350] },
  "hat":       { "small":  [300, 250, 200, 180, 150, 130, 110, 90],
                 "medium": [400, 350, 300, 250, 200, 180, 150, 130],
                 "large":  [500, 450, 400, 350, 280, 250, 200, 180] },
  "mittens":   { "small":  [250, 200, 180, 150, 130, 110, 100, 80],
                 "medium": [350, 300, 250, 200, 180, 150, 130, 110],
                 "large":  [450, 400, 350, 280, 230, 200, 170, 140] },
  "socks":     { "small":  [250, 200, 180, 150, 130, 100, 90, 70],
                 "medium": [400, 350, 300, 250, 200, 180, 150, 130],
                 "large":  [500, 450, 400, 330, 280, 250, 210, 180] },
  "baby_blanket": { "small":  [700, 600, 500, 450, 400, 350, 300, 250],
                    "medium": [900, 800, 700, 600, 550, 500, 450, 400],
                    "large":  [1200, 1050, 950, 850, 800, 700, 600, 500] },
  "throw":     { "small":  [1200, 1050, 950, 850, 800, 700, 600, 500],
                 "medium": [1600, 1450, 1300, 1200, 1100, 1000, 900, 800],
                 "large":  [2000, 1800, 1650, 1500, 1400, 1250, 1100, 1000] },
  "sweater":   { "small":  [1200, 1000, 900, 800, 700, 650, 550, 450],
                 "medium": [1500, 1300, 1150, 1000, 900, 800, 700, 600],
                 "large":  [2000, 1750, 1550, 1400, 1250, 1100, 950, 800] },
  "cardigan":  { "small":  [1300, 1100, 1000, 900, 800, 700, 600, 500],
                 "medium": [1700, 1500, 1350, 1200, 1050, 950, 800, 700],
                 "large":  [2200, 1950, 1750, 1550, 1400, 1250, 1100, 900] },
  "shawl":     { "small":  [500, 450, 400, 350, 300, 280, 250, 200],
                 "medium": [800, 700, 650, 600, 550, 500, 450, 400],
                 "large":  [1200, 1100, 1000, 900, 850, 750, 650, 550] }
}

const WEIGHT_NAMES = ["Lace (0)", "Fingering (1)", "Sport (2)", "DK (3)", "Worsted (4)", "Aran (5)", "Bulky (6)", "Super Bulky (7)"]

export default class extends Controller {
  static targets = [
    "project", "size", "weightCategory",
    "resultYards", "resultMeters", "resultSkeins100", "resultSkeins200"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const project = this.projectTarget.value
    const size = this.selectedSize()
    const weightCategory = parseInt(this.weightCategoryTarget.value)

    if (!YARDAGE_TABLE[project] || !YARDAGE_TABLE[project][size] || isNaN(weightCategory) || weightCategory < 0 || weightCategory > 7) {
      this.clearResults()
      return
    }

    const yards = YARDAGE_TABLE[project][size][weightCategory]
    const meters = yards * 0.9144
    const skeins100 = Math.ceil(yards / 100)
    const skeins200 = Math.ceil(yards / 200)

    this.resultYardsTarget.textContent = `${yards} yd`
    this.resultMetersTarget.textContent = `${meters.toFixed(1)} m`
    this.resultSkeins100Target.textContent = skeins100
    this.resultSkeins200Target.textContent = skeins200
  }

  selectedSize() {
    const checked = this.sizeTargets.find(el => el.checked)
    return checked ? checked.value : "medium"
  }

  clearResults() {
    this.resultYardsTarget.textContent = "0"
    this.resultMetersTarget.textContent = "0"
    this.resultSkeins100Target.textContent = "0"
    this.resultSkeins200Target.textContent = "0"
  }

  copy() {
    const text = `Yarn Yardage Estimate:\nYards Needed: ${this.resultYardsTarget.textContent}\nMeters Needed: ${this.resultMetersTarget.textContent}\nSkeins (100 yd): ${this.resultSkeins100Target.textContent}\nSkeins (200 yd): ${this.resultSkeins200Target.textContent}`
    navigator.clipboard.writeText(text)
  }
}
