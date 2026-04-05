import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalPrice", "volume", "unit",
    "resultPricePerLiter", "resultPricePerMl", "resultPricePerGallon",
    "resultPricePerFlOz", "resultVolumeInLiters"
  ]

  static volumeToLiters = {
    "L": 1.0,
    "mL": 0.001,
    "gal": 3.78541,
    "fl_oz": 0.0295735
  }

  calculate() {
    const totalPrice = parseFloat(this.totalPriceTarget.value) || 0
    const volume = parseFloat(this.volumeTarget.value) || 0
    const unit = this.unitTarget.value || "L"

    if (totalPrice <= 0 || volume <= 0) {
      this.clearResults()
      return
    }

    const conversion = this.constructor.volumeToLiters[unit] || 1.0
    const volumeInLiters = volume * conversion

    const pricePerLiter = totalPrice / volumeInLiters
    const pricePerMl = pricePerLiter / 1000
    const pricePerGallon = pricePerLiter * 3.78541
    const pricePerFlOz = pricePerLiter * 0.0295735

    this.resultPricePerLiterTarget.textContent = "$" + pricePerLiter.toFixed(4)
    this.resultPricePerMlTarget.textContent = "$" + pricePerMl.toFixed(6)
    this.resultPricePerGallonTarget.textContent = this.formatCurrency(pricePerGallon)
    this.resultPricePerFlOzTarget.textContent = "$" + pricePerFlOz.toFixed(4)
    this.resultVolumeInLitersTarget.textContent = volumeInLiters.toFixed(4) + " L"
  }

  clearResults() {
    const targets = [
      "resultPricePerLiter", "resultPricePerMl", "resultPricePerGallon",
      "resultPricePerFlOz", "resultVolumeInLiters"
    ]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "\u2014"
      }
    })
  }

  copy() {
    const text = [
      `Price Per Liter: ${this.resultPricePerLiterTarget.textContent}`,
      `Price Per mL: ${this.resultPricePerMlTarget.textContent}`,
      `Price Per Gallon: ${this.resultPricePerGallonTarget.textContent}`,
      `Price Per fl oz: ${this.resultPricePerFlOzTarget.textContent}`,
      `Volume in Liters: ${this.resultVolumeInLitersTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}
