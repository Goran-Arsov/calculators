import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["petType", "size", "sizeGroup", "ownershipYears",
                     "resultFirstYear", "resultAnnual", "resultLifetime",
                     "resultFood", "resultVet", "resultOther"]

  static values = {
    costs: { type: Object, default: {
      dog_small:  { food: 360, vet: 400, grooming: 200, insurance: 240, supplies: 150, total: 1350 },
      dog_medium: { food: 540, vet: 500, grooming: 280, insurance: 240, supplies: 140, total: 1700 },
      dog_large:  { food: 780, vet: 600, grooming: 320, insurance: 240, supplies: 160, total: 2100 },
      cat:        { food: 300, vet: 350, litter: 200, insurance: 200, supplies: 100, total: 1150 }
    }}
  }

  connect() {
    prefillFromUrl(this, { petType: "petType", size: "size", ownershipYears: "ownershipYears" })
    this.calculate()
    this.toggleSize()
  }

  toggleSize() {
    const petType = this.petTypeTarget.value
    if (this.hasSizeGroupTarget) {
      this.sizeGroupTarget.classList.toggle("hidden", petType !== "dog")
    }
    this.calculate()
  }

  calculate() {
    const petType = this.petTypeTarget.value
    const size = this.sizeTarget.value
    const years = parseInt(this.ownershipYearsTarget.value) || 1

    const key = petType === "dog" ? `dog_${size}` : "cat"
    const costs = this.costsValue[key]
    if (!costs) return

    const annual = costs.total
    const firstYear = annual + 500
    const lifetime = years >= 2 ? firstYear + annual * (years - 1) : firstYear

    this.resultFirstYearTarget.textContent = this.fmt(firstYear)
    this.resultAnnualTarget.textContent = this.fmt(annual)
    this.resultLifetimeTarget.textContent = this.fmt(lifetime)
    this.resultFoodTarget.textContent = this.fmt(costs.food)
    this.resultVetTarget.textContent = this.fmt(costs.vet)
    this.resultOtherTarget.textContent = this.fmt(annual - costs.food - costs.vet)
  }

  fmt(n) {
    return "$" + Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  copy() {
    const lines = [
      `First Year Cost: ${this.resultFirstYearTarget.textContent}`,
      `Annual Cost: ${this.resultAnnualTarget.textContent}`,
      `Lifetime Cost: ${this.resultLifetimeTarget.textContent}`,
      `Food (Annual): ${this.resultFoodTarget.textContent}`,
      `Vet (Annual): ${this.resultVetTarget.textContent}`,
      `Other (Annual): ${this.resultOtherTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
