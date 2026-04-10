import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "method",
    "ing1Vol", "ing1Abv",
    "ing2Vol", "ing2Abv",
    "ing3Vol", "ing3Abv",
    "ing4Vol", "ing4Abv",
    "resultPreAbv", "resultFinalAbv", "resultDilution",
    "resultVolumeOz", "resultVolumeMl", "resultStandardDrinks", "resultStrength"
  ]

  static dilution = { built: 0.00, rocks: 0.10, stirred: 0.22, shaken: 0.28 }

  connect() {
    this.calculate()
  }

  calculate() {
    const method = this.methodTarget.value
    const dilutionMap = { built: 0.00, rocks: 0.10, stirred: 0.22, shaken: 0.28 }
    const dilution = dilutionMap[method] ?? 0.22

    const ings = [
      [this.ing1VolTarget, this.ing1AbvTarget],
      [this.ing2VolTarget, this.ing2AbvTarget],
      [this.ing3VolTarget, this.ing3AbvTarget],
      [this.ing4VolTarget, this.ing4AbvTarget]
    ]

    let totalVolume = 0
    let totalAlcohol = 0
    ings.forEach(([v, a]) => {
      const vol = parseFloat(v.value) || 0
      const abv = parseFloat(a.value) || 0
      if (vol > 0 && abv >= 0 && abv <= 100) {
        totalVolume += vol
        totalAlcohol += vol * (abv / 100)
      }
    })

    if (totalVolume <= 0) {
      this.clearResults()
      return
    }

    const preAbv = (totalAlcohol / totalVolume) * 100
    const finalAbv = preAbv / (1 + dilution)
    const finalVolume = totalVolume * (1 + dilution)
    const standardDrinks = (finalVolume * 29.5735 * (finalAbv / 100) * 0.789) / 14.0

    this.resultPreAbvTarget.textContent = preAbv.toFixed(2) + "%"
    this.resultFinalAbvTarget.textContent = finalAbv.toFixed(2) + "%"
    this.resultDilutionTarget.textContent = (dilution * 100).toFixed(0) + "%"
    this.resultVolumeOzTarget.textContent = finalVolume.toFixed(2) + " oz"
    this.resultVolumeMlTarget.textContent = (finalVolume * 29.5735).toFixed(0) + " mL"
    this.resultStandardDrinksTarget.textContent = standardDrinks.toFixed(2)
    this.resultStrengthTarget.textContent = this.strength(finalAbv)
  }

  strength(abv) {
    if (abv < 8) return "Light (low ABV, session)"
    if (abv < 14) return "Medium (most classic cocktails)"
    if (abv < 22) return "Strong (Manhattan, Negroni)"
    if (abv < 30) return "Very strong (martinis)"
    return "Extreme (neat spirit)"
  }

  clearResults() {
    this.resultPreAbvTarget.textContent = "—"
    this.resultFinalAbvTarget.textContent = "—"
    this.resultDilutionTarget.textContent = "—"
    this.resultVolumeOzTarget.textContent = "—"
    this.resultVolumeMlTarget.textContent = "—"
    this.resultStandardDrinksTarget.textContent = "—"
    this.resultStrengthTarget.textContent = "—"
  }

  copy() {
    const text = `Cocktail ABV:\nPre-Dilution ABV: ${this.resultPreAbvTarget.textContent}\nFinal ABV: ${this.resultFinalAbvTarget.textContent}\nDilution: ${this.resultDilutionTarget.textContent}\nFinal Volume: ${this.resultVolumeOzTarget.textContent} (${this.resultVolumeMlTarget.textContent})\nUS Standard Drinks: ${this.resultStandardDrinksTarget.textContent}\nStrength: ${this.resultStrengthTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
