import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dayList", "totalDays", "avgCalories", "emptyState"]

  connect() {
    this.render()
  }

  loadAll() {
    try {
      return JSON.parse(localStorage.getItem("calchammer_calorie_log") || "{}")
    } catch { return {} }
  }

  render() {
    const all = this.loadAll()
    const dates = Object.keys(all).sort().reverse()

    if (dates.length === 0) {
      this.dayListTarget.innerHTML = ""
      this.emptyStateTarget.classList.remove("hidden")
      this.totalDaysTarget.textContent = "0"
      this.avgCaloriesTarget.textContent = "0"
      return
    }

    this.emptyStateTarget.classList.add("hidden")

    let totalCalories = 0
    let html = ""

    dates.forEach(date => {
      const dayData = all[date]
      const sections = ["night", "morning", "day", "evening"]
      let dayTotal = 0
      let dayCount = 0
      const sectionSums = {}

      sections.forEach(s => {
        const entries = dayData[s] || []
        const sum = entries.reduce((acc, e) => acc + (parseFloat(e.calories) || 0), 0)
        sectionSums[s] = sum
        dayTotal += sum
        dayCount += entries.length
      })

      totalCalories += dayTotal

      const formatDate = (d) => {
        const parts = d.split("-")
        const dt = new Date(d + "T00:00:00")
        const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return `${days[dt.getDay()]}, ${months[dt.getMonth()]} ${parseInt(parts[2])}, ${parts[0]}`
      }

      const isToday = date === new Date().toISOString().split("T")[0]
      const badge = isToday ? '<span class="px-2 py-0.5 text-xs font-medium bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 rounded-full">Today</span>' : ""

      html += `
        <div class="bg-white dark:bg-gray-900 rounded-xl border border-gray-200/80 dark:border-gray-800 p-5 hover:shadow-md hover:border-blue-200 dark:hover:border-blue-800 transition-all duration-200">
          <div class="flex items-center justify-between mb-3">
            <div class="flex items-center gap-2">
              <a href="/everyday/calorie-tracker?date=${date}" class="text-base font-semibold text-gray-900 dark:text-white hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                ${formatDate(date)}
              </a>
              ${badge}
            </div>
            <div class="flex items-center gap-3">
              <span class="text-lg font-bold text-blue-600 dark:text-blue-400">${Math.round(dayTotal)} kcal</span>
              <button data-date="${date}" data-action="click->calorie-tracker-summary#clearDay"
                class="text-red-400 hover:text-red-600 transition-colors p-1 cursor-pointer" title="Delete this day">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
              </button>
            </div>
          </div>
          <div class="grid grid-cols-4 gap-2 text-sm">
            <div class="text-center p-2 rounded-lg bg-indigo-50 dark:bg-indigo-900/20">
              <div class="text-xs text-gray-500 dark:text-gray-400">Night</div>
              <div class="font-semibold text-gray-700 dark:text-gray-300">${Math.round(sectionSums.night)}</div>
            </div>
            <div class="text-center p-2 rounded-lg bg-amber-50 dark:bg-amber-900/20">
              <div class="text-xs text-gray-500 dark:text-gray-400">Morning</div>
              <div class="font-semibold text-gray-700 dark:text-gray-300">${Math.round(sectionSums.morning)}</div>
            </div>
            <div class="text-center p-2 rounded-lg bg-blue-50 dark:bg-blue-900/20">
              <div class="text-xs text-gray-500 dark:text-gray-400">Afternoon</div>
              <div class="font-semibold text-gray-700 dark:text-gray-300">${Math.round(sectionSums.day)}</div>
            </div>
            <div class="text-center p-2 rounded-lg bg-violet-50 dark:bg-violet-900/20">
              <div class="text-xs text-gray-500 dark:text-gray-400">Evening</div>
              <div class="font-semibold text-gray-700 dark:text-gray-300">${Math.round(sectionSums.evening)}</div>
            </div>
          </div>
          <div class="mt-2 text-xs text-gray-400 dark:text-gray-500">${dayCount} ${dayCount === 1 ? 'entry' : 'entries'}</div>
        </div>
      `
    })

    this.dayListTarget.innerHTML = html
    this.totalDaysTarget.textContent = dates.length
    this.avgCaloriesTarget.textContent = Math.round(totalCalories / dates.length)
  }

  clearDay(event) {
    const date = event.currentTarget.dataset.date
    if (!confirm(`Delete all entries for ${date}?`)) return
    const all = this.loadAll()
    delete all[date]
    localStorage.setItem("calchammer_calorie_log", JSON.stringify(all))
    this.render()
  }

  clearAll() {
    if (!confirm("Delete ALL calorie tracking data? This cannot be undone.")) return
    localStorage.removeItem("calchammer_calorie_log")
    this.render()
  }
}
