import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "originalServings", "desiredServings",
    "ingredientRows", "ingredientTemplate",
    "results", "multiplier", "scaledList"
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
      <input type="text" placeholder="Ingredient name" class="col-span-5 text-sm" data-field="name">
      <input type="number" inputmode="decimal" placeholder="Amount" step="0.01" min="0" class="col-span-3 text-sm" data-field="amount" data-action="input->recipe-scaler-calculator#calculate">
      <input type="text" placeholder="Unit" class="col-span-3 text-sm" data-field="unit">
      <button type="button" data-action="click->recipe-scaler-calculator#removeIngredient" class="col-span-1 text-red-500 hover:text-red-700 text-lg font-bold">&times;</button>
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
    const original = parseInt(this.originalServingsTarget.value) || 0
    const desired = parseInt(this.desiredServingsTarget.value) || 0

    if (original <= 0 || desired <= 0) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const multiplier = desired / original
    this.multiplierTarget.textContent = multiplier.toFixed(2) + "x"

    const rows = this.ingredientRowsTarget.querySelectorAll(".grid")
    let html = ""
    rows.forEach(row => {
      const name = row.querySelector('[data-field="name"]').value || "Unnamed"
      const amount = parseFloat(row.querySelector('[data-field="amount"]').value) || 0
      const unit = row.querySelector('[data-field="unit"]').value || ""

      if (amount > 0) {
        const scaled = (amount * multiplier).toFixed(2)
        html += `<div class="flex justify-between py-1.5 border-b border-gray-100 dark:border-gray-700">
          <span class="text-gray-700 dark:text-gray-300">${name}</span>
          <span class="font-semibold text-green-700 dark:text-green-400">${scaled} ${unit}</span>
        </div>`
      }
    })

    this.scaledListTarget.innerHTML = html
    this.resultsTarget.classList.remove("hidden")
  }

  copy() {
    const original = this.originalServingsTarget.value
    const desired = this.desiredServingsTarget.value
    const rows = this.ingredientRowsTarget.querySelectorAll(".grid")
    const multiplier = desired / original

    let text = `Recipe Scaler Results (${original} -> ${desired} servings, ${multiplier.toFixed(2)}x)\n\n`
    rows.forEach(row => {
      const name = row.querySelector('[data-field="name"]').value || "Unnamed"
      const amount = parseFloat(row.querySelector('[data-field="amount"]').value) || 0
      const unit = row.querySelector('[data-field="unit"]').value || ""
      if (amount > 0) {
        text += `${name}: ${(amount * multiplier).toFixed(2)} ${unit}\n`
      }
    })

    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const orig = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = orig }, 2000)
    })
  }
}
