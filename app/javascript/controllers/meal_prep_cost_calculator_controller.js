import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "servings", "ingredientRows",
    "results", "totalCost", "costPerServing", "dailyCost", "weeklyCost", "ingredientBreakdown"
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
      <input type="text" placeholder="Ingredient" class="col-span-3 text-sm" data-field="name">
      <input type="number" inputmode="decimal" placeholder="Cost ($)" step="0.01" min="0" class="col-span-2 text-sm" data-field="cost" data-action="input->meal-prep-cost-calculator#calculate">
      <input type="number" inputmode="decimal" placeholder="Qty used" step="0.01" min="0" class="col-span-2 text-sm" data-field="qty_used" data-action="input->meal-prep-cost-calculator#calculate">
      <input type="number" inputmode="decimal" placeholder="Qty bought" step="0.01" min="0" class="col-span-2 text-sm" data-field="qty_purchased" data-action="input->meal-prep-cost-calculator#calculate">
      <input type="text" placeholder="Unit" class="col-span-2 text-sm" data-field="unit">
      <button type="button" data-action="click->meal-prep-cost-calculator#removeIngredient" class="col-span-1 text-red-500 hover:text-red-700 text-lg font-bold">&times;</button>
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
    let totalCost = 0
    let breakdownHtml = ""

    rows.forEach(row => {
      const name = row.querySelector('[data-field="name"]').value || "Unnamed"
      const cost = parseFloat(row.querySelector('[data-field="cost"]').value) || 0
      const qtyUsed = parseFloat(row.querySelector('[data-field="qty_used"]').value) || 0
      const qtyPurchased = parseFloat(row.querySelector('[data-field="qty_purchased"]').value) || 0

      if (cost > 0 && qtyUsed > 0 && qtyPurchased > 0) {
        const costPerUnit = cost / qtyPurchased
        const costUsed = costPerUnit * qtyUsed
        totalCost += costUsed

        breakdownHtml += `<div class="flex justify-between py-1 border-b border-gray-100 dark:border-gray-700 text-sm">
          <span class="text-gray-600 dark:text-gray-400">${name}</span>
          <span class="font-medium text-gray-800 dark:text-gray-200">$${costUsed.toFixed(2)}</span>
        </div>`
      }
    })

    if (totalCost <= 0) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const costPerServing = totalCost / servings

    this.totalCostTarget.textContent = `$${totalCost.toFixed(2)}`
    this.costPerServingTarget.textContent = `$${costPerServing.toFixed(2)}`
    this.dailyCostTarget.textContent = `$${(costPerServing * 3).toFixed(2)}`
    this.weeklyCostTarget.textContent = `$${(costPerServing * 21).toFixed(2)}`
    this.ingredientBreakdownTarget.innerHTML = breakdownHtml
    this.resultsTarget.classList.remove("hidden")
  }

  copy() {
    const text = [
      `Meal Prep Cost:`,
      `Total: ${this.totalCostTarget.textContent}`,
      `Per Serving: ${this.costPerServingTarget.textContent}`,
      `Daily (3 meals): ${this.dailyCostTarget.textContent}`,
      `Weekly (21 meals): ${this.weeklyCostTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
