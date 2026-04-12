import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "servings", "ingredientRows",
    "results", "totalCalories", "totalProtein", "totalCarbs", "totalFat",
    "perCalories", "perProtein", "perCarbs", "perFat",
    "proteinPct", "carbsPct", "fatPct"
  ]

  connect() {
    if (this.ingredientRowsTarget.children.length === 0) {
      this.addIngredient()
    }
  }

  addIngredient() {
    const row = document.createElement("div")
    row.className = "grid grid-cols-12 gap-2 items-center mb-2"
    row.innerHTML = `
      <input type="text" placeholder="Ingredient" class="col-span-2 text-sm" data-field="name">
      <input type="number" inputmode="decimal" placeholder="Qty" step="0.1" min="0" class="col-span-2 text-sm" data-field="quantity" data-action="input->macros-per-recipe-calculator#calculate" value="1">
      <input type="number" inputmode="decimal" placeholder="Cal" step="1" min="0" class="col-span-2 text-sm" data-field="calories" data-action="input->macros-per-recipe-calculator#calculate">
      <input type="number" inputmode="decimal" placeholder="Protein(g)" step="0.1" min="0" class="col-span-2 text-sm" data-field="protein" data-action="input->macros-per-recipe-calculator#calculate">
      <input type="number" inputmode="decimal" placeholder="Carbs(g)" step="0.1" min="0" class="col-span-2 text-sm" data-field="carbs" data-action="input->macros-per-recipe-calculator#calculate">
      <input type="number" inputmode="decimal" placeholder="Fat(g)" step="0.1" min="0" class="col-span-1 text-sm" data-field="fat" data-action="input->macros-per-recipe-calculator#calculate">
      <button type="button" data-action="click->macros-per-recipe-calculator#removeIngredient" class="col-span-1 text-red-500 hover:text-red-700 text-lg font-bold">&times;</button>
    `
    this.ingredientRowsTarget.appendChild(row)
  }

  removeIngredient(event) {
    const row = event.currentTarget.closest(".grid")
    if (this.ingredientRowsTarget.children.length > 1) {
      row.remove()
      this.calculate()
    }
  }

  calculate() {
    const servings = parseInt(this.servingsTarget.value) || 0
    if (servings <= 0) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const rows = this.ingredientRowsTarget.querySelectorAll(".grid")
    let totalCal = 0, totalPro = 0, totalCarbs = 0, totalFat = 0

    rows.forEach(row => {
      const qty = parseFloat(row.querySelector('[data-field="quantity"]').value) || 1
      const cal = (parseFloat(row.querySelector('[data-field="calories"]').value) || 0) * qty
      const pro = (parseFloat(row.querySelector('[data-field="protein"]').value) || 0) * qty
      const carbs = (parseFloat(row.querySelector('[data-field="carbs"]').value) || 0) * qty
      const fat = (parseFloat(row.querySelector('[data-field="fat"]').value) || 0) * qty

      totalCal += cal
      totalPro += pro
      totalCarbs += carbs
      totalFat += fat
    })

    const perCal = totalCal / servings
    const perPro = totalPro / servings
    const perCarbs = totalCarbs / servings
    const perFat = totalFat / servings

    // Macro percentages by calorie
    const totalMacroCals = (perPro * 4) + (perCarbs * 4) + (perFat * 9)
    const proPct = totalMacroCals > 0 ? ((perPro * 4) / totalMacroCals * 100) : 0
    const carbsPct = totalMacroCals > 0 ? ((perCarbs * 4) / totalMacroCals * 100) : 0
    const fatPct = totalMacroCals > 0 ? ((perFat * 9) / totalMacroCals * 100) : 0

    this.totalCaloriesTarget.textContent = totalCal.toFixed(0)
    this.totalProteinTarget.textContent = totalPro.toFixed(1) + " g"
    this.totalCarbsTarget.textContent = totalCarbs.toFixed(1) + " g"
    this.totalFatTarget.textContent = totalFat.toFixed(1) + " g"

    this.perCaloriesTarget.textContent = perCal.toFixed(0)
    this.perProteinTarget.textContent = perPro.toFixed(1) + " g"
    this.perCarbsTarget.textContent = perCarbs.toFixed(1) + " g"
    this.perFatTarget.textContent = perFat.toFixed(1) + " g"

    this.proteinPctTarget.textContent = proPct.toFixed(1) + "%"
    this.carbsPctTarget.textContent = carbsPct.toFixed(1) + "%"
    this.fatPctTarget.textContent = fatPct.toFixed(1) + "%"

    this.resultsTarget.classList.remove("hidden")
  }

  copy() {
    const text = [
      `Recipe Macros (per serving):`,
      `Calories: ${this.perCaloriesTarget.textContent}`,
      `Protein: ${this.perProteinTarget.textContent}`,
      `Carbs: ${this.perCarbsTarget.textContent}`,
      `Fat: ${this.perFatTarget.textContent}`,
      `Macro Split: P ${this.proteinPctTarget.textContent} / C ${this.carbsPctTarget.textContent} / F ${this.fatPctTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
