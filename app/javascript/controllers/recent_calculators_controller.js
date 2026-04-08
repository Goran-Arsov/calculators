import { Controller } from "@hotwired/stimulus"

// Displays recently viewed calculators on the homepage.
// Reads visit history from localStorage and matches against a
// server-provided calculator catalog passed as a Stimulus value.
//
// Usage:
//   <section data-controller="recent-calculators"
//            data-recent-calculators-catalog-value="<%= all_calculators_json %>">
//     <div data-recent-calculators-target="grid"></div>
//   </section>
export default class extends Controller {
  static values = { catalog: Array, maxCards: { type: Number, default: 6 } }
  static targets = ["grid"]

  connect() {
    const visits = this.#loadVisits()
    if (visits.length === 0) return

    const catalogBySlug = new Map()
    this.catalogValue.forEach(c => catalogBySlug.set(c.slug, c))

    const cards = []
    for (const visit of visits) {
      const calc = catalogBySlug.get(visit.slug)
      if (calc) cards.push(calc)
      if (cards.length >= this.maxCardsValue) break
    }

    if (cards.length === 0) return

    this.gridTarget.innerHTML = cards.map(calc => this.#cardHTML(calc)).join("")
    this.element.classList.remove("hidden")
  }

  #loadVisits() {
    try {
      return JSON.parse(localStorage.getItem("calcwise_recent_visits") || "[]")
    } catch {
      return []
    }
  }

  #cardHTML(calc) {
    const iconPath = calc.icon_path || "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"

    return `<a href="${calc.path}" class="block group bg-white dark:bg-gray-900 rounded-2xl border border-gray-200/80 dark:border-gray-800 p-6 hover:shadow-lg hover:shadow-blue-500/5 dark:hover:shadow-blue-500/5 hover:border-blue-200 dark:hover:border-blue-800 hover:-translate-y-0.5 transition-all duration-300">
  <div class="flex items-start space-x-4">
    <div class="flex-shrink-0 w-12 h-12 bg-gradient-to-br from-blue-500 to-violet-600 rounded-xl flex items-center justify-center shadow-md shadow-blue-500/20 group-hover:shadow-lg group-hover:shadow-blue-500/30 group-hover:scale-105 transition-all duration-300">
      <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="${iconPath}"/></svg>
    </div>
    <div class="flex-1 min-w-0">
      <div class="flex items-center justify-between">
        <h3 class="text-base font-semibold text-gray-900 dark:text-white group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors duration-200">${this.#escapeHTML(calc.name)}</h3>
        <svg class="w-4 h-4 text-gray-400 dark:text-gray-600 group-hover:text-blue-500 dark:group-hover:text-blue-400 group-hover:translate-x-0.5 transition-all duration-200 flex-shrink-0 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
      </div>
      <p class="mt-1.5 text-sm text-gray-500 dark:text-gray-400 leading-relaxed">${this.#escapeHTML(calc.description)}</p>
    </div>
  </div>
</a>`
  }

  #escapeHTML(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }
}
