import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["datePicker", "sections", "basalInput", "fatBalanceCard", "balanceSection", "balanceCalc", "balanceResult", "consumedTotal"]
  static values = { date: String }

  connect() {
    if (!this.dateValue) {
      this.dateValue = new Date().toISOString().split("T")[0]
    }
    this.datePickerTarget.value = this.dateValue
    this.render()
  }

  changeDate() {
    this.dateValue = this.datePickerTarget.value
    this.render()
  }

  prevDay() {
    const d = new Date(this.dateValue + "T00:00:00")
    d.setDate(d.getDate() - 1)
    this.dateValue = d.toISOString().split("T")[0]
    this.datePickerTarget.value = this.dateValue
    this.render()
  }

  nextDay() {
    const d = new Date(this.dateValue + "T00:00:00")
    d.setDate(d.getDate() + 1)
    this.dateValue = d.toISOString().split("T")[0]
    this.datePickerTarget.value = this.dateValue
    this.render()
  }

  today() {
    this.dateValue = new Date().toISOString().split("T")[0]
    this.datePickerTarget.value = this.dateValue
    this.render()
  }

  // --- Data persistence ---

  loadAll() {
    try {
      return JSON.parse(localStorage.getItem("calchammer_calorie_log") || "{}")
    } catch { return {} }
  }

  loadDay(date) {
    const all = this.loadAll()
    return all[date] || { basal: 0, night: [], morning: [], day: [], evening: [] }
  }

  static MAX_DAYS = 365

  saveDay(date, dayData) {
    const all = this.loadAll()
    const hasEntries = (dayData.basal > 0) || ["night", "morning", "day", "evening"].some(k => (dayData[k] || []).length > 0)
    if (hasEntries) {
      all[date] = dayData
    } else {
      delete all[date]
    }
    // Prune oldest days beyond the limit
    const dates = Object.keys(all).sort()
    while (dates.length > this.constructor.MAX_DAYS) {
      delete all[dates.shift()]
    }
    localStorage.setItem("calchammer_calorie_log", JSON.stringify(all))
  }

  updateBasal() {
    const dayData = this.loadDay(this.dateValue)
    dayData.basal = parseFloat(this.basalInputTarget.value) || 0
    this.saveDay(this.dateValue, dayData)
    this.updateTotals()
  }

  // --- Entry management ---

  addEntry(event) {
    const section = event.currentTarget.dataset.section
    const dayData = this.loadDay(this.dateValue)
    const maxId = Object.values(dayData).flat().reduce((max, e) => Math.max(max, e.id || 0), 0)
    dayData[section].push({ id: maxId + 1, description: "", amount: "", calories: 0 })
    this.saveDay(this.dateValue, dayData)
    this.render()
    // Focus the new description input
    const sectionEl = this.sectionsTarget.querySelector(`[data-section="${section}"]`)
    const inputs = sectionEl.querySelectorAll('input[data-field="description"]')
    if (inputs.length > 0) inputs[inputs.length - 1].focus()
  }

  quickAdd(event) {
    const { section, name, amount, calories } = event.currentTarget.dataset
    const dayData = this.loadDay(this.dateValue)
    const maxId = Object.values(dayData).flat().reduce((max, e) => Math.max(max, e.id || 0), 0)
    dayData[section].push({
      id: maxId + 1,
      description: name,
      amount: amount || "",
      calories: parseFloat(calories) || 0
    })
    this.saveDay(this.dateValue, dayData)
    this.render()
  }

  updateEntry(event) {
    const { section, entryId, field } = event.currentTarget.dataset
    const dayData = this.loadDay(this.dateValue)
    const entry = dayData[section].find(e => e.id === parseInt(entryId))
    if (!entry) return
    entry[field] = field === "calories" ? (parseFloat(event.currentTarget.value) || 0) : event.currentTarget.value
    this.saveDay(this.dateValue, dayData)
    this.updateTotals()
  }

  removeEntry(event) {
    const { section, entryId } = event.currentTarget.dataset
    const dayData = this.loadDay(this.dateValue)
    dayData[section] = dayData[section].filter(e => e.id !== parseInt(entryId))
    this.saveDay(this.dateValue, dayData)
    this.render()
  }

  // --- Catalog of previously-entered foods ---

  buildCatalog() {
    const all = this.loadAll()
    const sortedDates = Object.keys(all).sort().reverse()
    const byName = {}
    for (const date of sortedDates) {
      const day = all[date] || {}
      for (const sectionKey of ["night", "morning", "day", "evening"]) {
        for (const entry of (day[sectionKey] || [])) {
          const name = (entry.description || "").trim()
          const cal = parseFloat(entry.calories) || 0
          if (!name || cal <= 0) continue
          const lower = name.toLowerCase()
          if (byName[lower]) {
            byName[lower].count += 1
          } else {
            byName[lower] = { name, amount: entry.amount || "", calories: cal, lastUsed: date, count: 1 }
          }
        }
      }
    }
    this.catalogList = Object.values(byName)
      .sort((a, b) => b.count - a.count || b.lastUsed.localeCompare(a.lastUsed))
      .slice(0, 12)
  }

  // --- Rendering ---

  render() {
    this.buildCatalog()
    const dayData = this.loadDay(this.dateValue)
    const sections = [
      { key: "night", label: "Night", time: "0-6 hrs", gradient: "from-indigo-500 to-blue-600", bg: "bg-indigo-50 dark:bg-indigo-900/20", iconColor: "text-indigo-500 dark:text-indigo-400", icon: "M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" },
      { key: "morning", label: "Morning", time: "6-12 hrs", gradient: "from-amber-400 to-orange-500", bg: "bg-amber-50 dark:bg-amber-900/20", iconColor: "text-amber-500 dark:text-amber-400", icon: "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" },
      { key: "day", label: "Afternoon", time: "12-18 hrs", gradient: "from-blue-500 to-cyan-500", bg: "bg-blue-50 dark:bg-blue-900/20", iconColor: "text-blue-500 dark:text-blue-400", icon: "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" },
      { key: "evening", label: "Evening", time: "18-24 hrs", gradient: "from-violet-500 to-purple-600", bg: "bg-violet-50 dark:bg-violet-900/20", iconColor: "text-violet-500 dark:text-violet-400", icon: "M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" }
    ]

    let html = ""
    sections.forEach(s => {
      const entries = dayData[s.key] || []
      const subtotal = entries.reduce((sum, e) => sum + (parseFloat(e.calories) || 0), 0)
      html += this.renderSection(s, entries, subtotal)
    })

    this.sectionsTarget.innerHTML = html
    this.basalInputTarget.value = dayData.basal || ""
    this.updateTotals()
  }

  renderSection(section, entries, subtotal) {
    const pillStrip = (this.catalogList && this.catalogList.length > 0) ? `
      <div class="flex flex-wrap gap-1.5 mb-4 pb-3 border-b border-gray-100 dark:border-gray-800">
        ${this.catalogList.map(f => `
          <button data-section="${section.key}"
                  data-name="${this.escapeAttr(f.name)}"
                  data-amount="${this.escapeAttr(f.amount)}"
                  data-calories="${f.calories}"
                  data-action="click->calorie-tracker#quickAdd"
                  class="text-xs px-2.5 py-1 rounded-full bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 hover:border-blue-400 hover:text-blue-600 dark:hover:border-blue-500 dark:hover:text-blue-400 transition-colors cursor-pointer whitespace-nowrap">
            + ${this.escapeAttr(f.name)} <span class="text-gray-400 dark:text-gray-500">${f.amount ? `· ${this.escapeAttr(f.amount)} ` : ""}· ${f.calories}</span>
          </button>
        `).join("")}
      </div>
    ` : ""

    const entryRows = entries.map(e => `
      <div class="grid grid-cols-12 gap-2 items-center mb-2" data-entry-id="${e.id}">
        <div class="col-span-5">
          <input type="text" value="${this.escapeAttr(e.description)}" placeholder="Food or drink..."
            data-field="description" data-section="${section.key}" data-entry-id="${e.id}"
            data-action="input->calorie-tracker#updateEntry"
            class="w-full text-sm">
        </div>
        <div class="col-span-3">
          <input type="text" value="${this.escapeAttr(e.amount)}" placeholder="e.g. 200ml, 1 cup"
            data-field="amount" data-section="${section.key}" data-entry-id="${e.id}"
            data-action="input->calorie-tracker#updateEntry"
            class="w-full text-sm">
        </div>
        <div class="col-span-3">
          <input type="number" value="${e.calories || ''}" placeholder="kcal" min="0" step="1"
            data-field="calories" data-section="${section.key}" data-entry-id="${e.id}"
            data-action="input->calorie-tracker#updateEntry"
            class="w-full text-sm">
        </div>
        <div class="col-span-1 text-center">
          <button data-section="${section.key}" data-entry-id="${e.id}"
            data-action="click->calorie-tracker#removeEntry"
            class="text-red-400 hover:text-red-600 transition-colors p-1 cursor-pointer" title="Remove">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
          </button>
        </div>
      </div>
    `).join("")

    return `
      <div class="mb-4 rounded-xl border border-gray-200/80 dark:border-gray-700 overflow-hidden" data-section="${section.key}">
        <div class="flex items-center justify-between px-5 py-3.5 ${section.bg}">
          <div class="flex items-center gap-2.5">
            <div class="w-8 h-8 bg-gradient-to-br ${section.gradient} rounded-lg flex items-center justify-center shadow-sm">
              <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="${section.icon}"/></svg>
            </div>
            <div>
              <h3 class="text-sm font-bold text-gray-900 dark:text-white">${section.label}</h3>
              <span class="text-xs text-gray-500 dark:text-gray-400">${section.time}</span>
            </div>
          </div>
          <span class="text-sm font-bold ${subtotal > 0 ? 'text-blue-600 dark:text-blue-400' : 'text-gray-400 dark:text-gray-500'}" data-subtotal="${section.key}">${subtotal} kcal</span>
        </div>
        <div class="px-5 py-4">
          ${pillStrip}
          ${entries.length > 0 ? `
            <div class="mb-3">
              <div class="grid grid-cols-12 gap-2 mb-1.5">
                <div class="col-span-5"><span class="text-xs font-semibold text-gray-400 dark:text-gray-500">Description</span></div>
                <div class="col-span-3"><span class="text-xs font-semibold text-gray-400 dark:text-gray-500">Amount</span></div>
                <div class="col-span-3"><span class="text-xs font-semibold text-gray-400 dark:text-gray-500">Calories</span></div>
                <div class="col-span-1"></div>
              </div>
              ${entryRows}
            </div>
          ` : '<p class="text-sm text-gray-400 dark:text-gray-500 mb-3 italic">No entries yet</p>'}
          <button data-section="${section.key}" data-action="click->calorie-tracker#addEntry"
            class="inline-flex items-center gap-1 text-sm font-medium text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 transition-colors cursor-pointer">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            Add entry
          </button>
        </div>
      </div>
    `
  }

  updateTotals() {
    const dayData = this.loadDay(this.dateValue)
    let dailyTotal = 0

    for (const [key, entries] of Object.entries(dayData)) {
      if (!Array.isArray(entries)) continue
      const subtotal = entries.reduce((sum, e) => sum + (parseFloat(e.calories) || 0), 0)
      dailyTotal += subtotal
      const el = this.sectionsTarget.querySelector(`[data-subtotal="${key}"]`)
      if (el) {
        el.textContent = `${Math.round(subtotal)} kcal`
        el.className = subtotal > 0
          ? "text-sm font-bold text-blue-600 dark:text-blue-400"
          : "text-sm font-bold text-gray-400 dark:text-gray-500"
      }
    }

    if (this.hasConsumedTotalTarget) {
      this.consumedTotalTarget.textContent = `${Math.round(dailyTotal)} kcal`
    }

    // Fat balance calculation: (basal - consumed) / 7.7 = grams of fat lost/gained
    const basal = parseFloat(this.basalInputTarget.value) || 0
    if (basal > 0) {
      const difference = basal - dailyTotal
      const fatGrams = Math.round(Math.abs(difference) / 7.7)

      this.balanceCalcTarget.innerHTML = `${Math.round(basal)} kcal expenditure − ${Math.round(dailyTotal)} kcal consumed = <strong>${Math.round(Math.abs(difference))} kcal ${difference >= 0 ? "deficit" : "surplus"}</strong>`

      if (difference > 0) {
        this.balanceResultTarget.innerHTML = `You will lose approximately <strong>${fatGrams} g</strong> of body fat today`
      } else if (difference < 0) {
        this.balanceResultTarget.innerHTML = `You will gain approximately <strong>${fatGrams} g</strong> of body fat today`
      } else {
        this.balanceResultTarget.innerHTML = "Exact maintenance — no fat gained or lost"
      }
      this.balanceResultTarget.className = "text-lg font-bold text-orange-600 dark:text-orange-400"
      this.balanceSectionTarget.classList.remove("hidden")
    } else {
      this.balanceSectionTarget.classList.add("hidden")
    }
  }

  // --- Helpers ---

  escapeAttr(str) {
    if (!str) return ""
    return str.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
  }
}
